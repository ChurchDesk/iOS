//
//  CHDAPIManager.m
//  ChurchDesk
//
//  Created by Mikkel Selsøe Sørensen on 20/02/15.
//  Copyright (c) 2015 Shape A/S. All rights reserved.
//

#import "CHDAPIClient.h"
#import "SHPNetworking.h"
#import <Crashlytics/Crashlytics.h>
#import "SHPAPIManager+ReactiveExtension.h"
#import "CHDInvitation.h"
#import "CHDMessage.h"
#import "CHDEnvironment.h"
#import "CHDEvent.h"
#import "CHDAccessToken.h"
#import "CHDAuthenticationManager.h"
#import "NSDateFormatter+ChurchDesk.h"
#import "CHDUser.h"
#import "CHDHoliday.h"
#import "CHDAPICreate.h"

static const CGFloat kDefaultCacheIntervalInSeconds = 60.f * 30.f; // 30 minutes
static NSString *const kAuthorizationHeaderField = @"token";

static NSString *const kClientID = @"2_3z9mhb9d9xmo8k0g00wkskckcs4444k4kkokw08gg4gs8k04ok";
static NSString *const kClientSecret = @"hlymtmodq0gs48kcwwwsccogo8sc8o4sook8sgs8040w8s44o";

#define PRODUCTION_ENVIRONMENT 1

#if PRODUCTION_ENVIRONMENT
static NSString *const kBaseUrl = @"http://api.churchdesk.com";
#else
static NSString *const kBaseUrl = @"http://private-anon-83c43a3ef-churchdeskapi.apiary-mock.com/";
#endif
static NSString *const kURLAPIPart = @"api/v1/";
static NSString *const kURLAPIOauthPart = @"oauth/v2/";


@interface CHDAPIClient ()

@property (nonatomic, strong) NSDateFormatter *dateFormatter;
@property (nonatomic, strong) SHPAPIManager *oauthManager;
@property (nonatomic, strong) RACSignal *refreshSignal;

@end

@implementation CHDAPIClient

- (id)init
{
    self = [super init];
    if (self) {
        [self setBaseURL:[[NSURL URLWithString:kBaseUrl] URLByAppendingPathComponent:kURLAPIPart]];
        
        self.oauthManager = [SHPAPIManager new];
        [self.oauthManager setBaseURL:[[NSURL URLWithString:kBaseUrl] URLByAppendingPathComponent:kURLAPIOauthPart]];
        
//        [self.manager.cache shprac_liftSelector:@selector(invalidateAllObjects) withSignal:[RACObserve([DNGAuthenticationManager sharedInstance], authenticationToken) distinctUntilChanged]];
    }
    return self;
}

- (RACSignal *)resourcesForPath:(NSString *)path resultClass:(Class)resultClass withResource:(void(^)(SHPAPIResource *))resourceBlock {
    return [self resourcesForPath:path resultClass:resultClass withResource:resourceBlock request:nil];
}

- (RACSignal *)resourcesForPath:(NSString *)path resultClass:(Class)resultClass withResource:(void(^)(SHPAPIResource *))resourceBlock request: (void(^)(SHPHTTPRequest *))requestBlock {
    [Crashlytics setObjectValue:path ?: @"" forKey:@"LastRequestPath"];
    
    SHPAPIResource *resource = [[SHPAPIResource alloc] initWithPath:path];
    resource.resultObjectClass = resultClass;
    resource.cacheInterval = kDefaultCacheIntervalInSeconds;
    if (resourceBlock) resourceBlock(resource);
    
#if INHOUSE
    BOOL onlyResult = NO;
#else
    BOOL onlyResult = YES;
#endif
    RACSignal *requestSignal = [self.manager dispatchRequest:^(SHPHTTPRequest *request) {
        NSString *auth = [CHDAuthenticationManager sharedInstance].authenticationToken.accessToken;
        if (auth) {
            [request setValue:auth forQueryParameterKey:@"access_token"];
        }
        [request addValue:@"application/json" forHeaderField:@"Accept"];
        [request addValue:@"application/json" forHeaderField:@"Content-Type"];
        if (requestBlock) {
            requestBlock(request);
        }
        
    } withBodyContent:nil toResource:resource onlyResult:onlyResult];
    
#if INHOUSE
    requestSignal = [requestSignal flattenMap:^RACStream *(SHPHTTPResponse *response) {
        [Crashlytics setObjectValue:response.body ?: @"" forKey:@"LastResponseBody"];
        [Crashlytics setObjectValue:response.headers ?: @{} forKey:@"LastResponseHeaders"];
        [Crashlytics setObjectValue:@(response.statusCode) forKey:@"LastResponseStatusCode"];
        return [RACSignal return:response.result];
    }];
#endif
    
    return [[[self tokenValidationWrapper:requestSignal] replayLazily] doError:^(NSError *error) {
        SHPHTTPResponse *response = error.userInfo[SHPAPIManagerReactiveExtensionErrorResponseKey];
        NSLog(@"Error on %@: %@\nResponse: %@", path, error, response.body);

        [[CHDAuthenticationManager sharedInstance] signOut];
    }];
}

- (RACSignal*)postBodyDictionary:(NSDictionary*)dictionary resultClass: (Class) resultClass toPath:(NSString*)path {
    return [self sendBodyDictionary:dictionary method:SHPHTTPRequestMethodPOST resultClass:resultClass toPath:path];
}

- (RACSignal*)putBodyDictionary:(NSDictionary*)dictionary resultClass: (Class) resultClass toPath:(NSString*)path {
    return [self sendBodyDictionary:dictionary method:SHPHTTPRequestMethodPUT resultClass:resultClass toPath:path];
}

- (RACSignal*)sendBodyDictionary:(NSDictionary*)dictionary method: (SHPHTTPRequestMethod) method resultClass: (Class) resultClass toPath:(NSString*)path {
    return [self resourcesForPath:path resultClass:resultClass ?: [NSDictionary class] withResource:nil request:^(SHPHTTPRequest *request) {
        request.method = method;
        request.ignoreCache = YES;
        NSError *error = nil;
        NSData *data = dictionary ? [NSJSONSerialization dataWithJSONObject:dictionary options:0 error:&error] : nil;
        request.body = data;
        if (!data && dictionary) {
            NSLog(@"Error encoding JSON: %@", error);
        }
    }];
}

- (RACSignal*)postHeaderDictionary:(NSDictionary*) dictionary resultClass: (Class) resultClass toPath:(NSString*)path {
    return [self resourcesForPath:path resultClass:resultClass ?: [NSDictionary class] withResource:nil request:^(SHPHTTPRequest *request) {
        request.method = SHPHTTPRequestMethodPOST;
        request.ignoreCache = YES;
        if(dictionary) {
            [dictionary enumerateKeysAndObjectsUsingBlock:^(NSString *key, NSString *value, BOOL *stop) {
                //Escape the value string
                [request setValue:value forQueryParameterKey:key];
            }];
        }

    }];
}



#pragma mark - User

- (RACSignal*)loginWithUserName: (NSString*) username password: (NSString*) password {
    SHPAPIResource *resource = [[SHPAPIResource alloc] initWithPath:@"token"];
    resource.resultObjectClass = [CHDAccessToken class];

    RACSignal *requestSignal = [self.oauthManager dispatchRequest:^(SHPHTTPRequest *request) {
    
        [request setValue:kClientID forQueryParameterKey:@"client_id"];
        [request setValue:kClientSecret forQueryParameterKey:@"client_secret"];
        [request setValue:@"password" forQueryParameterKey:@"grant_type"];
        [request setValue:username ?: @"" forQueryParameterKey:@"username"];
        [request setValue:password ?: @"" forQueryParameterKey:@"password"];
        
        [request addValue:@"application/json" forHeaderField:@"Accept"];
        [request addValue:@"application/json" forHeaderField:@"Content-Type"];
    } withBodyContent:nil toResource:resource];
    
    return [[requestSignal replayLazily] doError:^(NSError *error) {
        SHPHTTPResponse *response = error.userInfo[SHPAPIManagerReactiveExtensionErrorResponseKey];
        NSLog(@"Error on token: %@\nResponse: %@", error, response.body);
    }];
}

- (RACSignal*) getCurrentUser {
    return [self resourcesForPath:@"users" resultClass:[CHDUser class] withResource:nil];
}

#pragma mark - Environment

- (RACSignal*) getEnvironment {
    return [self resourcesForPath:@"dictionaries" resultClass:[CHDEnvironment class] withResource:nil];
}

#pragma mark - Calendar

- (RACSignal*) getEventsFromYear: (NSInteger) year month: (NSInteger) month {
    return [self resourcesForPath:[NSString stringWithFormat:@"events/%@/%@", @(year), @(month)] resultClass:[CHDEvent class] withResource:nil];
}

- (RACSignal*)getEventWithId:(NSNumber *)eventId siteId: (NSString*)siteId {
    return [self resourcesForPath:[NSString stringWithFormat:@"events/%@?site=%@", eventId, siteId] resultClass:[CHDEvent class] withResource:nil];
}

- (RACSignal*) getInvitations {
    return [self resourcesForPath:@"my-invites" resultClass:[CHDInvitation class] withResource:nil];
}

- (RACSignal*) getHolidaysFromYear: (NSInteger) year {
    return [self resourcesForPath:[NSString stringWithFormat:@"holydays/%@", @(year)] resultClass:[CHDHoliday class] withResource:nil];
}

- (RACSignal*) setResponseForEventWithId:(NSNumber *)eventId siteId: (NSString*)siteId response: (NSInteger) response {
    SHPAPIManager *manager = self.manager;

    return [[[self postHeaderDictionary:@{@"site" : siteId} resultClass:nil toPath:[NSString stringWithFormat:@"events/respond/%@/%li", eventId, (long) response]] map:^id(id value) {
        return eventId;
    }] doNext:^(id x) {
        [manager.cache invalidateObjectsMatchingRegex:@"*my-invites*"];
        [manager.cache invalidateObjectsMatchingRegex:[NSString stringWithFormat:@"*events/%@*?site=%@", eventId, siteId]];
    }];
}

#pragma mark - Messages

- (RACSignal*) getUnreadMessages{
  return [self resourcesForPath:@"messages/unread" resultClass:[CHDMessage class] withResource:nil];
}

- (RACSignal*) getMessagesFromDate: (NSDate*) date limit: (NSInteger) limit {
    return [[self resourcesForPath:@"messages" resultClass:[CHDMessage class] withResource:nil request:^(SHPHTTPRequest *request) {
        [request setValue:[self.dateFormatter stringFromDate:date] forQueryParameterKey:@"start_date"];
        [request setValue:[NSString stringWithFormat:@"%lu", limit] forQueryParameterKey:@"limit"];
    }] doNext:^(id x) {
        
    }];
}

- (RACSignal*)getMessageWithId:(NSNumber *)messageId siteId:(NSString*)siteId {
    return [self resourcesForPath:[NSString stringWithFormat:@"messages/%@", messageId] resultClass:[CHDMessage class] withResource:nil request:^(SHPHTTPRequest *request) {
        [request setValue:siteId forQueryParameterKey:@"site"];
    }];
}

//This will return a 200 with no content
- (RACSignal*)setMessageAsRead:(NSNumber *)messageId siteId:(NSString*)siteId {
    SHPAPIManager *manager = self.manager;
    return [[self resourcesForPath:[NSString stringWithFormat:@"messages/%@/mark-as-read?site=%@", messageId, siteId] resultClass:[NSDictionary class] withResource:nil] doNext:^(id x) {
        [manager.cache invalidateObjectsMatchingRegex:@"*messages/unread*"];
    }];
}

- (RACSignal*) createMessageWithTitle:(NSString*) title message:(NSString*) message siteId: (NSString*) siteId groupId:(NSNumber*) groupId{
    NSDictionary *body = @{@"site": siteId, @"groupId": groupId, @"title": title, @"body": message};
    return [self postBodyDictionary:body resultClass:[CHDAPICreate class] toPath:@"messages"];
}

- (RACSignal*) createCommentForMessageId:(NSNumber*) targetId siteId: (NSString*) siteId body:(NSString*) message {
    SHPAPIManager *manager = self.manager;
    NSDictionary *body = @{@"site": siteId, @"targetId": targetId, @"body": message};
    return [[self postBodyDictionary:body resultClass:[CHDAPICreate class] toPath:@"comments"] doNext:^(id x) {
        [manager.cache invalidateObjectsMatchingRegex:[NSString stringWithFormat:@"*messages/%@*", targetId]];
    }];
}

#pragma mark - Refresh token

- (RACSignal *)tokenValidationWrapper:(RACSignal *)requestSignal {
    return [requestSignal catch:^(NSError *error) {
        // Catch the error, refresh the token, and then do the request again.
        if ([self errorCausedByExpiredToken:error]) {
            if (!self.refreshSignal) {
                NSLog(@"Will attempt to refresh access token.");
                self.refreshSignal = [self refreshToken];
                [self rac_liftSelector:@selector(setRefreshSignal:) withSignals:[[[self.refreshSignal ignoreValues] doNext:^(id x) {
                    NSLog(@"Refresh token completed");
                }] mapReplace:nil], nil];
            }
            else {
                NSLog(@"Access token already being refreshed.");
            }
            
            return [[self.refreshSignal ignoreValues] concat:[requestSignal retry]];
        }
        return requestSignal;
    }];
}

- (RACSignal *)refreshToken {
    CHDAuthenticationManager *authManager = [CHDAuthenticationManager sharedInstance];
    NSString *userId = authManager.userID;
    
    SHPAPIResource *resource = [[SHPAPIResource alloc] initWithPath:@"token"];
    [resource addValidator:[SHPBlockValidator validatorWithValidationBlock:^BOOL(id input, __autoreleasing NSError **error) {
        NSString *accessToken = [input objectForKey:@"access_token"];
        if (accessToken) {
            return YES;
        } else {
            if (error != NULL) *error = [NSError errorWithDescription:@"Unable to retrieve access token with refresh token" code:-1];
            return NO;
        }
    }]];
    resource.resultObjectClass = [CHDAccessToken class];
    RACSignal *requestSignal = [self.oauthManager dispatchRequest:^(SHPHTTPRequest *request) {
        [request setMethod:SHPHTTPRequestMethodGET];
        [request setValue:@"refresh_token" forQueryParameterKey:@"grant_type"];
        [request setValue:authManager.authenticationToken.refreshToken forQueryParameterKey:@"refresh_token"];
#ifdef DEBUG
        // This will generate a refresh token error
        //        [request addValue:@"afaf" forQueryParameterKey:@"refresh_token"];
#endif
        [request setValue:kClientID forQueryParameterKey:@"client_id"];
        [request setValue:kClientSecret forQueryParameterKey:@"client_secret"];
    } withBodyContent:nil toResource:resource];
    
    [requestSignal subscribeNext:^(CHDAccessToken *token) {
        if (token.accessToken && [authManager.userID isEqualToString:userId]) {
#ifdef DEBUG
            NSLog(@"New access token obtained: %@", token.accessToken);
#else
            NSLog(@"New access token obtained");
#endif
            [authManager authenticateWithToken:token userID:userId];
        }
        else {
            if (!token.accessToken) {
                NSLog(@"Error: No new access token obtained");
            }
            else {
                NSLog(@"Error: User %@ no longer logged in. Current user: %@", userId, authManager.userID);
            }
        }
    } error:^(NSError *error) {
        NSLog(@"Unable to refresh token: %@", error);
    }];
    
    return requestSignal;
}


#pragma mark Token error handling

- (BOOL)errorCausedByExpiredToken:(NSError *)error {
    SHPHTTPResponse *response = [error.userInfo objectForKey:SHPAPIManagerReactiveExtensionErrorResponseKey];
    NSDictionary *body = response.body;
    NSString *bodyError = body[@"error"];
    return response.statusCode == 401 && [bodyError isKindOfClass:[NSString class]] && [bodyError isEqualToString:@"invalid_grant"];
}

#pragma mark - Lazy Initialization

- (NSDateFormatter *)dateFormatter {
    if (!_dateFormatter) {
        _dateFormatter = [NSDateFormatter chd_apiDateFormatter];
    }
    return _dateFormatter;
}

@end
