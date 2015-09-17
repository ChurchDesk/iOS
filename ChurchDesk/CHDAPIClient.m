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
#import "CHDNotificationSettings.h"

static const CGFloat kDefaultCacheIntervalInSeconds = 60.f * 30.f; // 30 minutes
static NSString *const kAuthorizationHeaderField = @"token";

static NSString *const kClientID = @"2_3z9mhb9d9xmo8k0g00wkskckcs4444k4kkokw08gg4gs8k04ok";
static NSString *const kClientSecret = @"hlymtmodq0gs48kcwwwsccogo8sc8o4sook8sgs8040w8s44o";

//These credentials are used to obtain access token to reset password
static NSString *const kClientCredentialsID = @"3_516ahy5oztkwsgg88wwo4wo08wccg0gwckkwgkk80o8k4ocgg0";
static NSString *const kclientCredentialsSecret = @"24gojcb452xw0k8ckcw48ocogw40oskcw408448gk884w04c4s";


#define PRODUCTION_ENVIRONMENT 1

#if PRODUCTION_ENVIRONMENT
static NSString *const kBaseUrl = @"https://api.churchdesk.com";
#else
static NSString *const kBaseUrl = @"https://private-anon-83c43a3ef-churchdeskapi.apiary-mock.com/";
#endif
static NSString *const kURLAPIPart = @"api/v1/";
static NSString *const kURLAPIOauthPart = @"oauth/v2/";

@interface CHDNopDataTransformer : NSObject <SHPDataTransformer>
@end

@implementation CHDNopDataTransformer

- (id)objectWithData:(NSData *)data error:(__autoreleasing NSError **)error {
    return @{};
}

- (NSData *)dataWithObject:(id)object error:(__autoreleasing NSError **)error {
    return [NSData data];
}

@end

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
    NSString *auth = [CHDAuthenticationManager sharedInstance].authenticationToken.accessToken;
    if (!auth) {
        [[CHDAuthenticationManager sharedInstance] signOut]; //if there is no token, redirect user to login screen
        return [RACSignal return:Nil];
    }
    RACSignal *requestSignal = [self.manager dispatchRequest:^(SHPHTTPRequest *request) {
        if (auth) {
            [request setValue:[CHDAuthenticationManager sharedInstance].authenticationToken.accessToken forQueryParameterKey:@"access_token"];
        }
       
        [request addValue:@"application/json" forHeaderField:@"Accept"];
        [request addValue:@"application/json" forHeaderField:@"Content-Type"];
        if (requestBlock) {
            requestBlock(request);
        }
    } withBodyContent:nil toResource:resource onlyResult:onlyResult];
    if (auth) {
#if INHOUSE
    requestSignal = [requestSignal flattenMap:^RACStream *(SHPHTTPResponse *response) {
        [Crashlytics setObjectValue:response.body ?: @"" forKey:@"LastResponseBody"];
        [Crashlytics setObjectValue:response.headers ?: @{} forKey:@"LastResponseHeaders"];
        [Crashlytics setObjectValue:@(response.statusCode) forKey:@"LastResponseStatusCode"];
        return [RACSignal return:response.result];
    }];
#endif
    
    requestSignal.name = path;
    return [[self tokenValidationWrapper:requestSignal] doError:^(NSError *error) {
        SHPHTTPResponse *response = error.userInfo[SHPAPIManagerReactiveExtensionErrorResponseKey];
        NSLog(@"Error on %@: %@\nResponse: %@ code %ld", path, error, response.body, (long)response.statusCode);
        
    }];
    }
    else{
        return [RACSignal return:Nil];
    }
    
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

- (RACSignal*)deleteHeaderDictionary:(NSDictionary*) dictionary resultClass: (Class) resultClass toPath:(NSString*)path {
    return [self resourcesForPath:path resultClass:resultClass ?: [NSDictionary class] withResource:nil request:^(SHPHTTPRequest *request) {
        request.method = SHPHTTPRequestMethodDELETE;
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
    SHPAPIManager *manager = self.manager;

    RACSignal *requestSignal = [self.oauthManager dispatchRequest:^(SHPHTTPRequest *request) {
    
        [request setValue:kClientID forQueryParameterKey:@"client_id"];
        [request setValue:kClientSecret forQueryParameterKey:@"client_secret"];
        [request setValue:@"password" forQueryParameterKey:@"grant_type"];
        [request setValue:username ?: @"" forQueryParameterKey:@"username"];
        [request setValue:password ?: @"" forQueryParameterKey:@"password"];
        
        [request addValue:@"application/json" forHeaderField:@"Accept"];
        [request addValue:@"application/json" forHeaderField:@"Content-Type"];
    } withBodyContent:nil toResource:resource];
    
    return [[[requestSignal replayLazily] doError:^(NSError *error) {
        SHPHTTPResponse *response = error.userInfo[SHPAPIManagerReactiveExtensionErrorResponseKey];
        NSLog(@"Error on token: %@\nResponse: %@", error, response.body);
    }] doNext:^(id x) {
        [[manager cache] invalidateObjectsMatchingRegex:self.resourcePathForGetCurrentUser];
    }];
}

- (RACSignal*) getCurrentUser {
    return [self resourcesForPath:[self resourcePathForGetCurrentUser] resultClass:[CHDUser class] withResource:nil];
}

- (RACSignal*) postResetPasswordForEmail: (NSString*) email accessToken:(NSString*) token {
    return [self postBodyDictionary:@{@"username" : email ?: @""} resultClass:[NSArray class] toPath:[NSString stringWithFormat:@"users/password-reset?access_token=%@", token]];
}

#pragma mark - Environment

- (RACSignal*) getEnvironment {
    return [self resourcesForPath:[self resourcePathForGetEnvironment] resultClass:[CHDEnvironment class] withResource:nil];
}

#pragma mark - Calendar

- (RACSignal*) getEventsFromYear: (NSInteger) year month: (NSInteger) month {
    return [self resourcesForPath:[self resourcePathForGetEventsFromYear:year month:month] resultClass:[CHDEvent class] withResource:nil];
}

- (RACSignal*) getEventWithId:(NSNumber *)eventId siteId: (NSString*)siteId {
    return [self resourcesForPath:[self resourcePathForGetEventWithId:eventId siteId:siteId] resultClass:[CHDEvent class] withResource:nil];
}

- (RACSignal*) createEventWithEvent: (CHDEvent*) event {
    NSDateComponents *startDate = [[NSCalendar currentCalendar] components:NSCalendarUnitYear | NSCalendarUnitMonth fromDate:event.startDate];
    NSString *eventsResourcePath = [self resourcePathForGetEventsFromYear:startDate.year month:startDate.month];
    SHPAPIManager *manager = self.manager;
    NSDictionary *eventDictionary = [event dictionaryRepresentation];

    return [[self resourcesForPath:@"events" resultClass:[NSDictionary class] withResource:nil request:^(SHPHTTPRequest *request) {
        request.method = SHPHTTPRequestMethodPOST;

        NSError *error = nil;
        NSData *data = eventDictionary ? [NSJSONSerialization dataWithJSONObject:eventDictionary options:0 error:&error] : nil;
        request.body = data;
        if (!data && eventDictionary) {
            NSLog(@"Error encoding JSON: %@", error);
        }
    }] doNext:^(id x) {
        [manager.cache invalidateObjectsMatchingRegex:eventsResourcePath];
    }];
}
- (RACSignal*) updateEventWithEvent: (CHDEvent*) event {
    NSDateComponents *startDate = [[NSCalendar currentCalendar] components:NSCalendarUnitYear | NSCalendarUnitMonth fromDate:event.startDate];
    NSString *eventsResourcePath = [self resourcePathForGetEventsFromYear:startDate.year month:startDate.month];
    SHPAPIManager *manager = self.manager;

    NSString *siteId = event.siteId;
    NSNumber *eventId = event.eventId;
    NSDictionary *eventDictionary = [event dictionaryRepresentation];

    return [[self resourcesForPath:[NSString stringWithFormat:@"events/%@", eventId] resultClass:[NSDictionary class] withResource:nil request:^(SHPHTTPRequest *request) {
        request.method = SHPHTTPRequestMethodPUT;
        [request setValue:siteId ?: @"" forQueryParameterKey:@"site"];

        NSError *error = nil;
        NSData *data = eventDictionary ? [NSJSONSerialization dataWithJSONObject:eventDictionary options:0 error:&error] : nil;
        request.body = data;
        if (!data && eventDictionary) {
            NSLog(@"Error encoding JSON: %@", error);
        }
    }] doNext:^(id x) {
        [manager.cache invalidateObjectsMatchingRegex:eventsResourcePath];
        NSString *regexReady = [self resourcePathForGetEventWithId:eventId siteId:siteId];
        regexReady = [regexReady stringByReplacingOccurrencesOfString:@"?" withString:@"\\?"];
        regexReady = [regexReady stringByReplacingOccurrencesOfString:@"\\." withString:@"\\."];
        regexReady = [regexReady stringByReplacingOccurrencesOfString:@"/" withString:@"\\/"];
        [manager.cache invalidateObjectsMatchingRegex:[NSString stringWithFormat:@".*%@.*", regexReady]];
    }];
}

- (RACSignal*) getInvitations {
    return [self resourcesForPath:[self resourcePathForGetInvitations] resultClass:[CHDInvitation class] withResource:nil];
}

- (RACSignal*) getHolidaysFromYear: (NSInteger) year {
    return [self resourcesForPath:[self resourcePathForGetHolidaysFromYear:year] resultClass:[CHDHoliday class] withResource:nil];
}

- (RACSignal*) setResponseForEventWithId:(NSNumber *)eventId siteId: (NSString*)siteId response: (NSInteger) response {
    SHPAPIManager *manager = self.manager;

    return [[[self postHeaderDictionary:@{@"site" : siteId} resultClass:[NSArray class] toPath:[NSString stringWithFormat:@"events/respond/%@/%li", eventId, (long) response]] map:^id(id value) {
        return eventId;
    }] doNext:^(id x) {
        [manager.cache invalidateObjectsMatchingRegex:@"(my-invites)"];
        [manager.cache invalidateObjectsMatchingRegex:[NSString stringWithFormat:@"(events/%@?.*site=%@)", eventId, siteId]];
    }];
}

#pragma mark - Messages

- (RACSignal*) getUnreadMessages{
  return [self resourcesForPath: [self resourcePathForGetUnreadMessages] resultClass:[CHDMessage class] withResource:nil];
}

- (RACSignal*) getMessagesFromDate: (NSDate*) date limit: (NSInteger) limit {
    return [self getMessagesFromDate:date limit:limit query:nil];
}

- (RACSignal*) getMessagesFromDate: (NSDate*) date limit: (NSInteger) limit query: (NSString*) query {
    return [self resourcesForPath:@"messages" resultClass:[CHDMessage class] withResource:nil request:^(SHPHTTPRequest *request) {
        [request setValue:[self.dateFormatter stringFromDate:date] forQueryParameterKey:@"start_date"];
        [request setValue:[NSString stringWithFormat:@"%lu", (long)limit] forQueryParameterKey:@"limit"];
        if (query) {
            [request setValue:query forQueryParameterKey:@"query"];
        }
    }];
}

- (RACSignal*)getMessageWithId:(NSNumber *)messageId siteId:(NSString*)siteId {
    SHPAPIManager *manager = self.manager;
    return [[self resourcesForPath:[self resourcePathForGetMessageWithId:messageId] resultClass:[CHDMessage class] withResource:nil request:^(SHPHTTPRequest *request) {
        [request setValue:siteId forQueryParameterKey:@"site"];
    }] doNext:^(CHDMessage *message) {
        //Invalidate unread - only if message is unread
        if(!message.read){
            [manager.cache invalidateObjectsMatchingRegex:@"(messages/unread)"];
        }
    }];
}

//This will return a 200 with no content
- (RACSignal*)setMessageAsRead:(NSNumber *)messageId siteId:(NSString*)siteId {
    SHPAPIManager *manager = self.manager;

    return [[[self postHeaderDictionary:@{@"site" : siteId} resultClass:[NSArray class] toPath:[NSString stringWithFormat:@"messages/%@/mark-as-read", messageId]] doNext:^(id x) {
        [manager.cache invalidateObjectsMatchingRegex:@"(messages/unread)"];
    }] catch:^RACSignal *(NSError *error) {
        return [RACSignal empty];
    }];
}

- (RACSignal*) createMessageWithTitle:(NSString*) title message:(NSString*) message siteId: (NSString*) siteId groupId:(NSNumber*) groupId{
    SHPAPIManager *manager = self.manager;

    NSDictionary *body = @{@"site": siteId, @"groupId": groupId, @"title": title, @"body": message};
    return [[self postBodyDictionary:body resultClass:[CHDAPICreate class] toPath:@"messages"] doNext:^(id x) {
        [manager.cache invalidateObjectsMatchingRegex:@"(messages/unread)"];
    }];
}

- (RACSignal*) createCommentForMessageId:(NSNumber*) targetId siteId: (NSString*) siteId body:(NSString*) message {
    SHPAPIManager *manager = self.manager;
    NSDictionary *body = @{@"site": siteId, @"targetId": targetId, @"body": message};
    return [[self postBodyDictionary:body resultClass:[CHDAPICreate class] toPath:@"comments"] doNext:^(id x) {
        [manager.cache invalidateObjectsMatchingRegex:[NSString stringWithFormat:@"(messages/%@)", targetId]];
    }];
}

- (RACSignal*) deleteCommentWithId: (NSNumber*) commentId siteId: (NSString*) siteId messageId: (NSNumber*) messageId {
    SHPAPIManager *manager = self.manager;
    NSDictionary *header = @{@"site": siteId};
    return [[self deleteHeaderDictionary:header resultClass:nil toPath:[NSString stringWithFormat:@"comments/%@", commentId]] doNext:^(id x) {
        [manager.cache invalidateObjectsMatchingRegex:[NSString stringWithFormat:@"(messages/%@)", messageId]];
    }];
}

- (RACSignal*) updateCommentWithId: (NSNumber*) commentId body:(NSString*) message siteId: (NSString*) siteId messageId: (NSNumber*) messageId {
    SHPAPIManager *manager = self.manager;
    NSDictionary *body = @{@"body": message};
    return [[self putBodyDictionary:body resultClass:nil toPath:[NSString stringWithFormat:@"comments/%@?site=%@", commentId, siteId]] doNext:^(id x) {
        [manager.cache invalidateObjectsMatchingRegex:[NSString stringWithFormat:@"(messages/%@)", messageId]];
    }];
}

#pragma mark - Notifications
- (RACSignal*) getNotificationSettings {
    return [self resourcesForPath:[self resourcePathForGetNotificationSettings] resultClass:[CHDNotificationSettings class] withResource:nil];
}

- (RACSignal *)updateNotificationSettingsWithSettings:(CHDNotificationSettings *)settings {
    NSDictionary *settingsDict = @{
        @"bookingUpdated" : [NSNumber numberWithBool:settings.bookingUpdated],
        @"bookingCanceled" : [NSNumber numberWithBool:settings.bookingCanceled],
        @"bookingCreated" : [NSNumber numberWithBool:settings.bookingCreated],
        @"message" : [NSNumber numberWithBool:settings.message],
    };
    return [self postBodyDictionary:settingsDict resultClass:[NSDictionary class] toPath:@"push-notifications/settings"];
}

- (RACSignal*)postDeviceToken: (NSString*) deviceToken {
    if (!deviceToken) {
        return [RACSignal empty];
    }
    NSString *environment = [NSBundle mainBundle].infoDictionary[@"PUSH_ENVIRONMENT"];
    NSString *path = [NSString stringWithFormat:@"push-notifications/register-token/%@/ios/%@", deviceToken, environment];
    
    return [self resourcesForPath:path resultClass:[NSDictionary class] withResource:^(SHPAPIResource *resource) {
        NSValue *extraRangeValue = [NSValue valueWithRange:NSMakeRange(409, 1)]; // allow status code 409 (meaning device is already registered)
        resource.acceptableStatusCodeRanges = [resource.acceptableStatusCodeRanges arrayByAddingObject:extraRangeValue];
        resource.dataTransformer = [CHDNopDataTransformer new];
    } request:^(SHPHTTPRequest *request) {
        request.method = SHPHTTPRequestMethodPOST;
        [request addValue:@"" forHeaderField:@"Content-Type"];
    }];
}

- (RACSignal*) deleteDeviceToken: (NSString*) deviceToken accessToken: (NSString*)accessToken {
    if (deviceToken.length > 0 && accessToken.length > 0) {
        NSString *path = [NSString stringWithFormat:@"push-notifications/delete-token/%@", deviceToken];
        return [[self deleteHeaderDictionary:@{@"access_token" : accessToken} resultClass:nil toPath:path] doNext:^(id x) {
        }];
    } else{
        return [RACSignal empty];
    }

}

- (RACSignal *)clientAccessToken {
    SHPAPIResource *resource = [[SHPAPIResource alloc] initWithPath:@"token"];
    resource.resultObjectClass = [NSDictionary class];

    return [self.oauthManager dispatchRequest:^(SHPHTTPRequest *request) {

        [request setValue:kClientCredentialsID forQueryParameterKey:@"client_id"];
        [request setValue:kclientCredentialsSecret forQueryParameterKey:@"client_secret"];
        [request setValue:@"client_credentials" forQueryParameterKey:@"grant_type"];

        [request addValue:@"application/json" forHeaderField:@"Accept"];
        [request addValue:@"application/json" forHeaderField:@"Content-Type"];
    } withBodyContent:nil toResource:resource];
}

#pragma mark - Resources paths
- (NSString*)resourcePathForGetCurrentUser{return @"users";}
- (NSString*)resourcePathForGetEnvironment{return @"dictionaries";}
- (NSString*)resourcePathForGetEventsFromYear: (NSInteger) year month: (NSInteger) month{return [NSString stringWithFormat:@"events/%@/%@", @(year), @(month)];}
- (NSString*)resourcePathForGetEventWithId:(NSNumber *)eventId siteId: (NSString*)siteId{return [NSString stringWithFormat:@"events/%@?site=%@", eventId, siteId];}

- (NSString*)resourcePathForGetInvitations{return @"my-invites";}
- (NSString*)resourcePathForGetHolidaysFromYear: (NSInteger) year{return [NSString stringWithFormat:@"holydays/%@", @(year)];}

- (NSString*)resourcePathForGetUnreadMessages {return @"messages/unread";}
- (NSString*)resourcePathForGetMessagesFromDate{return @"messages";}
- (NSString*)resourcePathForGetMessageWithId:(NSNumber *)messageId { return [NSString stringWithFormat:@"messages/%@", messageId];}
- (NSString*)resourcePathForGetNotificationSettings{return @"push-notifications/settings";}

#pragma mark - Refresh token

- (RACSignal *)tokenValidationWrapper:(RACSignal *)requestSignal {
    @weakify(self)
    RACSignal* (^refreshBlock)(void) = ^RACSignal*(void) {
        @strongify(self)
        NSLog(@"Refresh signal %@. Will retry request upon completion.", _refreshSignal ? @"exists" : @"does not exist");
        return [self.refreshSignal flattenMap:^RACStream *(id value) {
            NSLog(@"Retrying request: %@", requestSignal.name);
            return requestSignal;
        }];
    };
    
    if ([CHDAuthenticationManager sharedInstance].authenticationToken.expired) {
        NSLog(@"Authentication token expired");
        return refreshBlock();
    }
    
    RACSignal *deferedRequestSignal = [RACSignal defer:^RACSignal *{
        return requestSignal;
    }];
    
    return [deferedRequestSignal catch:^(NSError *error) {
        // Catch the error, refresh the token, and then do the request again.
        if ([self errorCausedByExpiredToken:error]) {
            NSLog(@"Server reported expired token");
            return refreshBlock();
        }
        return [RACSignal error:error];
    }];
}

- (RACSignal *)refreshSignal {
    if (!_refreshSignal) {
        CHDAuthenticationManager *authManager = [CHDAuthenticationManager sharedInstance];
        NSString *userId = authManager.userID;
        
        SHPAPIResource *resource = [[SHPAPIResource alloc] initWithPath:@"token"];
        resource.resultObjectClass = [CHDAccessToken class];
        [resource addValidator:[SHPBlockValidator validatorWithValidationBlock:^BOOL(id input, __autoreleasing NSError **error) {
            NSString *accessToken = [input objectForKey:@"access_token"];
            if (accessToken) {
                return YES;
            } else {
                if (error != NULL) {
                    *error = [NSError errorWithDescription:@"Unable to retrieve access token with refresh token" code:-1];
                }
                return NO;
            }
        }]];
        
        @weakify(self)
        RACSignal *dispatchSignal = [[[[self.oauthManager dispatchRequest:^(SHPHTTPRequest *request) {
            [request setMethod:SHPHTTPRequestMethodGET];
            [request setValue:@"refresh_token" forQueryParameterKey:@"grant_type"];
            [request setValue:authManager.authenticationToken.refreshToken ?: @"" forQueryParameterKey:@"refresh_token"];
            [request setValue:kClientID forQueryParameterKey:@"client_id"];
            [request setValue:kClientSecret forQueryParameterKey:@"client_secret"];
            
        } withBodyContent:nil toResource:resource] doError:^(NSError *error) {
            SHPHTTPResponse *response = error.userInfo[SHPAPIManagerReactiveExtensionErrorResponseKey];
            NSLog(@"Error during token refresh. Signing out.\nHTTP Status: %lu\nResponse: %@", (long)response.statusCode, response.body);
            [authManager signOut];
            
        }] finally:^{
            @strongify(self)
            NSLog(@"Refresh token completed");
            self->_refreshSignal = nil;
        }] replayLazily];
        
        RACSignal *authSignal = [dispatchSignal flattenMap:^RACStream *(CHDAccessToken *token) {
            if (token.accessToken && [authManager.userID isEqualToString:userId]) {
#ifdef DEBUG
                NSLog(@"New access token obtained: %@", token.accessToken);
#else
                NSLog(@"New access token obtained");
#endif
                
                return [RACSignal return:RACTuplePack(token, userId)];
            }
            else {
                NSString *description = nil;
                if (!token.accessToken) {
                    description = @"Error: No new access token obtained";
                }
                else {
                    description = [NSString stringWithFormat:@"Error: User %@ no longer logged in. Current user: %@", userId, authManager.userID];
                }
                NSLog(@"%@", description);
                return [RACSignal error:[NSError errorWithDescription:description code:-1]];
            }
        }];
        
        [authManager rac_liftSelector:@selector(authenticateWithToken:userID:) withSignalOfArguments:authSignal];
        _refreshSignal = dispatchSignal;
    }
    return _refreshSignal;
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
