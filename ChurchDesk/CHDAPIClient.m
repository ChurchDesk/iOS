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
static NSString *const kBaseUrl = @"https://api2.churchdesk.com/";
#else
static NSString *const kBaseUrl = @"https://private-anon-83c43a3ef-churchdeskapi.apiary-mock.com/";
#endif
static NSString *const kURLAPIPart = @"";
static NSString *const kURLAPIOauthPart = @"";

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
        NSLog(@"Error on %@: %@\nResponse: %@", path, error, response.body);
        if (response.statusCode == 401) {
            NSLog(@"signing out");
            [[CHDAuthenticationManager sharedInstance] signOut];
        }
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
        NSLog(@"data %@", data);
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
    SHPAPIResource *resource = [[SHPAPIResource alloc] initWithPath:@"login"];
    resource.resultObjectClass = [CHDAccessToken class];
    SHPAPIManager *manager = self.manager;

    RACSignal *requestSignal = [self.oauthManager dispatchRequest:^(SHPHTTPRequest *request) {
        request.method = SHPHTTPRequestMethodPOST;
        [request addValue:@"application/json" forHeaderField:@"Accept"];
        [request addValue:@"application/json" forHeaderField:@"Content-Type"];
        NSError *error = nil;
        NSData *data = [NSJSONSerialization dataWithJSONObject:@{@"username": username, @"password": password, @"clientId": @"2"} options:0 error:&error];
        request.body = data;
    } withBodyContent:nil toResource:resource];
    
    return [[[requestSignal replayLazily] doError:^(NSError *error) {
        SHPHTTPResponse *response = error.userInfo[SHPAPIManagerReactiveExtensionErrorResponseKey];
        NSLog(@"Error on token: %@\nResponse: %@", error, response.body);
    }] doNext:^(id x) {
        [Heap track:@"Successful Login"];
        [[manager cache] invalidateObjectsMatchingRegex:self.resourcePathForGetCurrentUser];
    }];
}

- (RACSignal*) getCurrentUser {
    return [self resourcesForPath:[self resourcePathForGetCurrentUser] resultClass:[CHDUser class] withResource:nil];
}

- (RACSignal*) postResetPasswordForEmail: (NSString*) email{
    SHPAPIResource *resource = [[SHPAPIResource alloc] initWithPath:@"login/forgot"];
    resource.resultObjectClass = [NSObject class];
    SHPAPIManager *manager = self.manager;
    
    RACSignal *requestSignal = [self.oauthManager dispatchRequest:^(SHPHTTPRequest *request) {
        request.method = SHPHTTPRequestMethodPOST;
        [request addValue:@"application/json" forHeaderField:@"Accept"];
        [request addValue:@"application/json" forHeaderField:@"Content-Type"];
        NSError *error = nil;
        NSData *data = [NSJSONSerialization dataWithJSONObject:@{@"email": email} options:0 error:&error];
        request.body = data;
    } withBodyContent:nil toResource:resource];
    
    return [[[requestSignal replayLazily] doError:^(NSError *error) {
        SHPHTTPResponse *response = error.userInfo[SHPAPIManagerReactiveExtensionErrorResponseKey];
        NSLog(@"Error on reset: %@\nResponse: %@", error, response.body);
    }] doNext:^(id x) {
        [[manager cache] invalidateObjectsMatchingRegex:self.resourcePathForGetCurrentUser];
    }];
}

#pragma mark - Environment

- (RACSignal*) getEnvironment {
    return [self resourcesForPath:[self resourcePathForGetEnvironment] resultClass:[CHDEnvironment class] withResource:nil];
}

#pragma mark - Calendar

- (RACSignal*) getEventsFromYear: (NSInteger) year month: (NSInteger) month {
    //return [self resourcesForPath:[self resourcePathForGetEvents] resultClass:[CHDEvent class] withResource:nil];
    NSString *endDate = [NSString stringWithFormat:@"%ld-%ld-31", (long)year, (long)month];//[self getEndDateOfMonth:year month:month];
    NSString *startDate = [NSString stringWithFormat:@"%ld-%ld-01", (long)year, (long)month];
    NSLog(@"month %ld, year %ld, start date %@, end date %@", (long)month, (long)year, startDate, endDate);
    return [self resourcesForPath:[self resourcePathForGetEvents] resultClass:[CHDEvent class] withResource:nil request:^(SHPHTTPRequest *request) {
        [request setValue:startDate forQueryParameterKey:@"start"];
        [request setValue:endDate forQueryParameterKey:@"end"];
        //[request setValue:@"event" forQueryParameterKey:@"type"];
    }];
}

-(NSString *) getEndDateOfMonth: (NSInteger) year month: (NSInteger) month {
    NSString *dateString = [NSString stringWithFormat:@"%ld-%ld-15", (long)year, (long)month];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    NSDate *dateFromString = [[NSDate alloc] init];
    dateFromString = [dateFormatter dateFromString:dateString];
    
    //calculating last day of month
    NSCalendar *currentCalendar = [NSCalendar currentCalendar];
    NSRange daysRange =
    [currentCalendar
     rangeOfUnit:NSCalendarUnitDay
     inUnit:NSCalendarUnitMonth
     forDate:dateFromString];
    
    // daysRange.length will contain the number of the last day
    // of the month containing dateofstring
    NSLog(@"%lu", (unsigned long)daysRange.length);
    return [NSString stringWithFormat:@"%ld-%ld-%lu", (long)year, (long)month, (unsigned long)daysRange.length];
    
}

- (RACSignal*) getEventWithId:(NSNumber *)eventId siteId: (NSString*)siteId {
    return [self resourcesForPath:[self resourcePathForGetEventWithId:eventId siteId:siteId] resultClass:[CHDEvent class] withResource:nil];
}

- (RACSignal*) createEventWithEvent: (CHDEvent*) event {
   // NSDateComponents *startDate = [[NSCalendar currentCalendar] components:NSCalendarUnitYear | NSCalendarUnitMonth fromDate:event.startDate];
    NSString *eventsResourcePath = [self resourcePathForGetEvents];
    SHPAPIManager *manager = self.manager;
    NSDictionary *eventDictionary = [event dictionaryRepresentation];
    
    return [[self resourcesForPath:@"calendar" resultClass:[NSDictionary class] withResource:nil request:^(SHPHTTPRequest *request) {
        request.method = SHPHTTPRequestMethodPOST;
        [request setValue:event.siteId ?: @"" forQueryParameterKey:@"organizationId"];
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
  //  NSDateComponents *startDate = [[NSCalendar currentCalendar] components:NSCalendarUnitYear | NSCalendarUnitMonth fromDate:event.startDate];
    NSString *eventsResourcePath = [self resourcePathForGetEvents];
    SHPAPIManager *manager = self.manager;
    
    NSString *siteId = event.siteId;
    NSNumber *eventId = event.eventId;
    NSDictionary *eventDictionary = [event dictionaryRepresentation];

    return [[self resourcesForPath:[NSString stringWithFormat:@"calendar/%@", eventId] resultClass:[NSDictionary class] withResource:nil request:^(SHPHTTPRequest *request) {
        request.method = SHPHTTPRequestMethodPUT;
        [request setValue:siteId ?: @"" forQueryParameterKey:@"organizationId"];
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
    [[NSUserDefaults standardUserDefaults] setValue:[NSDate date] forKey:kinvitationsTimestamp];
    return [self resourcesForPath:[self resourcePathForGetInvitations] resultClass:[CHDInvitation class] withResource:nil];
}

- (RACSignal*) getHolidaysFromYear: (NSInteger) year country:(NSString*)country{
    return [self resourcesForPath:[self resourcePathForGetHolidaysFromYear:year country:country] resultClass:[CHDHoliday class] withResource:nil];
}

- (RACSignal*) setResponseForEventWithId:(NSNumber *)eventId siteId: (NSString*)siteId response: (NSString *) response {
    SHPAPIManager *manager = self.manager;

    return [[[self postHeaderDictionary:@{} resultClass:[NSArray class] toPath:[NSString stringWithFormat:@"calendar/invitations/%@/attending/%@", eventId, response]] map:^id(id value) {
        return eventId;
    }] doNext:^(id x) {
        [manager.cache invalidateObjectsMatchingRegex:@"(my-invites)"];
        [manager.cache invalidateObjectsMatchingRegex:[NSString stringWithFormat:@"(events/%@?.*site=%@)", eventId, siteId]];
    }];
}

#pragma mark - Messages

- (RACSignal*) getUnreadMessages{
    [[NSUserDefaults standardUserDefaults] setValue:[NSDate date] forKey:kmessagesTimestamp];
    return [self resourcesForPath: [self resourcePathForGetUnreadMessages] resultClass:[CHDMessage class] withResource:nil request:^(SHPHTTPRequest *request) {
        [request setValue:@"1" forQueryParameterKey:@"onlyUnread"];
        }];
}

- (RACSignal*) getMessagesFromDate: (NSDate*) date limit: (NSInteger) limit {
    return [self getMessagesFromDate:date limit:limit query:nil];
}

- (RACSignal*) getMessagesFromDate: (NSDate*) date limit: (NSInteger) limit query: (NSString*) query {
    [[NSUserDefaults standardUserDefaults] setValue:[NSDate date] forKey:kmessagesTimestamp];
    return [self resourcesForPath:@"messages" resultClass:[CHDMessage class] withResource:nil request:^(SHPHTTPRequest *request) {
        [request setValue:[self.dateFormatter stringFromDate:date] forQueryParameterKey:@"limitDate"];
        [request setValue:[NSString stringWithFormat:@"%lu", (long)limit] forQueryParameterKey:@"limit"];
        if (query) {
            [request setValue:query forQueryParameterKey:@"query"];
        }
    }];
}

- (RACSignal*)getMessageWithId:(NSNumber *)messageId siteId:(NSString*)siteId {
    SHPAPIManager *manager = self.manager;
    return [[self resourcesForPath:[self resourcePathForGetMessageWithId:messageId] resultClass:[CHDMessage class] withResource:nil request:^(SHPHTTPRequest *request) {
        //[request setValue:siteId forQueryParameterKey:@"site"];
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
    return [[self resourcesForPath:[self resourcePathForGetMessageWithId:messageId] resultClass:[CHDMessage class] withResource:nil request:^(SHPHTTPRequest *request) {
        //[request setValue:siteId forQueryParameterKey:@"site"];
    }] doNext:^(CHDMessage *message) {
        //Invalidate unread - only if message is unread
        if(!message.read){
            [manager.cache invalidateObjectsMatchingRegex:@"(messages/unread)"];
        }
    }];
}

- (RACSignal*) createMessageWithTitle:(NSString*) title message:(NSString*) message siteId: (NSString*) siteId groupId:(NSNumber*) groupId{
    SHPAPIManager *manager = self.manager;
    NSDictionary *body = @{@"groupId": groupId, @"title": title, @"message": message};
    return [[self postBodyDictionary:body resultClass:[CHDAPICreate class] toPath:@"messages"] doNext:^(id x) {
        [manager.cache invalidateObjectsMatchingRegex:@"(messages/unread)"];
    }];
}

- (RACSignal*) createCommentForMessageId:(NSNumber*) targetId siteId: (NSString*) siteId body:(NSString*) message {
    SHPAPIManager *manager = self.manager;
    NSDictionary *body = @{@"body": message};
    NSString *commentPath = [NSString stringWithFormat:@"messages/%@/comments", targetId];
    return [[self postBodyDictionary:body resultClass:[CHDAPICreate class] toPath:commentPath] doNext:^(id x) {
        [manager.cache invalidateObjectsMatchingRegex:[NSString stringWithFormat:@"(messages/%@)", targetId]];
    }];
}

- (RACSignal*) deleteCommentWithId: (NSNumber*) commentId siteId: (NSString*) siteId messageId: (NSNumber*) messageId {
    SHPAPIManager *manager = self.manager;
    NSDictionary *header = @{};
    return [[self deleteHeaderDictionary:header resultClass:nil toPath:[NSString stringWithFormat:@"messages/comments/%@", commentId]] doNext:^(id x) {
        [manager.cache invalidateObjectsMatchingRegex:[NSString stringWithFormat:@"(messages/%@)", messageId]];
    }];
}

- (RACSignal*) updateCommentWithId: (NSNumber*) commentId body:(NSString*) message siteId: (NSString*) siteId messageId: (NSNumber*) messageId {
    SHPAPIManager *manager = self.manager;
    NSDictionary *body = @{@"body": message};
    return [[self putBodyDictionary:body resultClass:nil toPath:[NSString stringWithFormat:@"messages/comments/%@", commentId]] doNext:^(id x) {
        [manager.cache invalidateObjectsMatchingRegex:[NSString stringWithFormat:@"(messages/%@)", messageId]];
    }];
}

#pragma mark - Notifications
- (RACSignal*) getNotificationSettings {
    return [self resourcesForPath:[self resourcePathForGetNotificationSettings] resultClass:[CHDNotificationSettings class] withResource:nil request:^(SHPHTTPRequest *request) {
        [request setValue:[[NSUserDefaults standardUserDefaults] valueForKey:@"organizationId"] forQueryParameterKey:@"organizationId"];
    }];
}

- (RACSignal *)updateNotificationSettingsWithSettings:(CHDNotificationSettings *)settings {
    NSDictionary *settingsDict = @{
                                   @"bookingUpdatedNotifcation" : @{@"push" : [NSNumber numberWithBool:settings.bookingUpdated]},
        @"bookingCanceledNotifcation" : @{@"push" : [NSNumber numberWithBool:settings.bookingCanceled]},
        @"bookingCreatedNotifcation" : @{@"push" : [NSNumber numberWithBool:settings.bookingCreated]},
        @"groupMessageNotifcation" : @{@"push" : [NSNumber numberWithBool:settings.message]},
    };
    
    return [[self resourcesForPath:[NSString stringWithFormat:@"users/%@", [[NSUserDefaults standardUserDefaults] valueForKey:@"userId"]] resultClass:[NSDictionary class] withResource:nil request:^(SHPHTTPRequest *request) {
        request.method = SHPHTTPRequestMethodPUT;
        [request setValue:[[NSUserDefaults standardUserDefaults] valueForKey:@"organizationId"] forQueryParameterKey:@"organizationId"];
        NSError *error = nil;
        NSData *data = settingsDict ? [NSJSONSerialization dataWithJSONObject:settingsDict options:0 error:&error] : nil;
        request.body = data;
        if (!data && settingsDict) {
            NSLog(@"Error encoding JSON: %@", error);
        }
    }] doNext:^(id x) {
    }];
}

- (RACSignal*)postDeviceToken: (NSString*) deviceToken {
    if (!deviceToken) {
        return [RACSignal empty];
    }
    NSString *environment = [NSBundle mainBundle].infoDictionary[@"PUSH_ENVIRONMENT"];
    NSString *path = [NSString stringWithFormat:@"devices/%@/iOS/%@", deviceToken, environment];
    
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
        NSString *path = [NSString stringWithFormat:@"devices/%@", deviceToken];
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
- (NSString*)resourcePathForGetCurrentUser{return @"users/me";}
- (NSString*)resourcePathForGetEnvironment{return @"dictionaries";}
- (NSString*)resourcePathForGetEventsFromYear: (NSInteger) year month: (NSInteger) month{return [NSString stringWithFormat:@"events/%@/%@", @(year), @(month)];}

- (NSString*)resourcePathForGetEvents{return @"calendar";}
- (NSString*)resourcePathForGetEventWithId:(NSNumber *)eventId siteId: (NSString*)siteId{return [NSString stringWithFormat:@"calendar/%@?organizationId=%@", eventId, siteId];}

- (NSString*)resourcePathForGetInvitations{return @"calendar/invitations";}
- (NSString*)resourcePathForGetHolidaysFromYear: (NSInteger) year country: (NSString*)country{return [NSString stringWithFormat:@"calendar/holydays/%@/%@", country, @(year)];}

- (NSString*)resourcePathForGetUnreadMessages {return @"messages";}
- (NSString*)resourcePathForGetMessagesFromDate{return @"messages";}
- (NSString*)resourcePathForGetMessageWithId:(NSNumber *)messageId { return [NSString stringWithFormat:@"messages/%ld", (long)messageId.integerValue];}
- (NSString*)resourcePathForGetNotificationSettings{return [NSString stringWithFormat:@"users/%@", [[NSUserDefaults standardUserDefaults] valueForKey:@"userId"]];}

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

/*- (RACSignal *)refreshSignal {
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
}*/


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
