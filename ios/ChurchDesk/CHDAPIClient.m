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

static const CGFloat kDefaultCacheIntervalInSeconds = 60.f * 30.f; // 30 minutes
static NSString *const kAuthorizationHeaderField = @"token";

#define PRODUCTION_ENVIRONMENT 0

#if PRODUCTION_ENVIRONMENT
static NSString *const kBaseUrl = @"";
#else
static NSString *const kBaseUrl = @"http://private-anon-83c43a3ef-churchdeskapi.apiary-mock.com/";
#endif
static NSString *const kURLAPIPart = @"api/v1/";


@interface CHDAPIClient ()

@property (nonatomic, readonly) NSDateFormatter *dateFormatter;

@end

@implementation CHDAPIClient

- (id)init
{
    self = [super init];
    if (self) {
        [self setBaseURL:[[NSURL URLWithString:kBaseUrl] URLByAppendingPathComponent:kURLAPIPart]];
        
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
        NSString *auth = @"access_token";
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
    
    return [[requestSignal replayLazily] doError:^(NSError *error) {
        SHPHTTPResponse *response = error.userInfo[SHPAPIManagerReactiveExtensionErrorResponseKey];
        NSLog(@"Error on %@: %@\nResponse: %@", path, error, response.body);
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
        NSData *data = [NSJSONSerialization dataWithJSONObject:dictionary options:0 error:&error];
        request.body = data;
        if (!data) {
            NSLog(@"Error encoding JSON: %@", error);
        }
    }];
}

#pragma mark - Environment

- (RACSignal*) getEnvironment {
    return [self resourcesForPath:@"dictionaries" resultClass:[CHDEnvironment class] withResource:nil];
}

#pragma mark - Calendar

- (RACSignal*) getEventWithId: (NSNumber*) eventId site: (NSString*) site {
    return [self resourcesForPath:[NSString stringWithFormat:@"events/%@?site=%@", eventId, site] resultClass:[CHDEvent class] withResource:nil];
}

- (RACSignal*) getInvitations {
    return [self resourcesForPath:@"my-invites" resultClass:[CHDInvitation class] withResource:nil];
}

#pragma mark - Messages

- (RACSignal*) getUnreadMessages{
  return [self resourcesForPath:@"messages/unread" resultClass:[CHDMessage class] withResource:nil];
}

@end
