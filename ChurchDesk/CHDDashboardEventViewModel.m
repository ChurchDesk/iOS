//
// Created by Jakob Vinther-Larsen on 10/03/15.
// Copyright (c) 2015 Shape A/S. All rights reserved.
//

#import "CHDDashboardEventViewModel.h"
#import "CHDAPIClient.h"
#import "CHDEvent.h"
#import "CHDUser.h"
#import "CHDEnvironment.h"
#import "CHDAuthenticationManager.h"
#import "NSDate+ChurchDesk.h"

@interface CHDDashboardEventViewModel()
@property (nonatomic, strong) CHDUser *user;
@property (nonatomic, strong) NSArray *events;
@property (nonatomic, strong) CHDEnvironment *environment;
@property (nonatomic) NSInteger year;
@property (nonatomic) NSInteger month;
@property (nonatomic, strong) RACCommand *loginCommand;
@end

@implementation CHDDashboardEventViewModel

- (instancetype)init {
    self = [super init];
    if (self) {
        NSDate *referenceDate = [NSDate new];
        NSCalendar *calendar = [NSCalendar currentCalendar];
        NSInteger year = self.year = [calendar component:NSCalendarUnitYear fromDate:referenceDate];
        NSInteger month = self.month = [calendar component:NSCalendarUnitMonth fromDate:referenceDate];
//        NSInteger today = [calendar component:NSCalendarUnitDay fromDate:referenceDate];
        //Initial signal
        RACSignal *initialSignal = [[[[CHDAPIClient sharedInstance] getEventsFromYear:year month:month] map:^id(NSArray* events) {
                [[NSUserDefaults standardUserDefaults] setValue:[NSDate date] forKey:keventsTimestamp];
                RACSequence *results = [events.rac_sequence filter:^BOOL(CHDEvent* event) {
                    return [self isDate:referenceDate inRangeFirstDate:event.startDate lastDate:event.endDate];
                }];
                //Earliest on top
                return [results.array sortedArrayUsingComparator:^NSComparisonResult(CHDEvent *event1, CHDEvent *event2) {
                    return [event1.startDate compare:event2.startDate];
                }];
            }] catch:^RACSignal *(NSError *error) {
                return [RACSignal empty];
            }];
        
        //Update signal
        CHDAPIClient *apiClient = [CHDAPIClient sharedInstance];
        
        RACSignal *authenticationTokenSignal = [RACObserve([CHDAuthenticationManager sharedInstance], authenticationToken) ignore:nil];

        RACSignal *updateSignal = [[[apiClient.manager.cache rac_signalForSelector:@selector(invalidateObjectsMatchingRegex:)] filter:^BOOL(RACTuple *tuple) {
            NSString *regex = tuple.first;
            NSString *resourcePath = [apiClient resourcePathForGetEventsFromYear:year month:[calendar component:NSCalendarUnitMonth fromDate:[NSDate date]]];
            [[NSUserDefaults standardUserDefaults] setValue:[NSDate date] forKey:keventsTimestamp];
            return [regex rangeOfString:resourcePath].location != NSNotFound;
        }] flattenMap:^RACStream *(id value) {
            return [[[[CHDAPIClient sharedInstance] getEventsFromYear:year month:month] map:^id(NSArray* events) {
                RACSequence *results = [events.rac_sequence filter:^BOOL(CHDEvent* event) {
                return [self isDate:[NSDate date] inRangeFirstDate:event.startDate lastDate:event.endDate];
                }];
                //Earliest on top
                return [results.array sortedArrayUsingComparator:^NSComparisonResult(CHDEvent *event1, CHDEvent *event2) {
                    return [event1.startDate compare:event2.startDate];
                }];
            }] catch:^RACSignal *(NSError *error) {
                return [RACSignal empty];
            }];
        }];

        RAC(self, events) = [RACSignal merge:@[initialSignal, updateSignal]];

        [self shprac_liftSelector:@selector(setEnvironment:) withSignal:[authenticationTokenSignal flattenMap:^RACStream *(id value) {
            return [[[CHDAPIClient sharedInstance] getEnvironment] catch:^RACSignal *(NSError *error) {
                return [RACSignal empty];
            }];
        }]];
        
        [self shprac_liftSelector:@selector(setUser:) withSignal:[authenticationTokenSignal flattenMap:^RACStream *(id value) {
            return [[[CHDAPIClient sharedInstance] getCurrentUser] catch:^RACSignal *(NSError *error) {
                return [RACSignal empty];
            }];
        }]];
        [self shprac_liftSelector:@selector(reload) withSignal:authenticationTokenSignal];
    }
    return self;
}
- (BOOL)isDate:(NSDate *)date inRangeFirstDate:(NSDate *)firstDate lastDate:(NSDate *)lastDate {
    NSCalendar *calendar = [NSCalendar currentCalendar];
    unsigned unitFlags = NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear;

    NSDateComponents *dateComponents = [calendar components:unitFlags fromDate:date];
    NSDateComponents *firstDateComponents = [calendar components:unitFlags fromDate:firstDate];
    NSDateComponents *lastDateComponents = [calendar components:unitFlags fromDate:lastDate];

    BOOL first = dateComponents.day == firstDateComponents.day && dateComponents.month == firstDateComponents.month && dateComponents.year == firstDateComponents.year;
    BOOL last = dateComponents.day == lastDateComponents.day && dateComponents.month == lastDateComponents.month && dateComponents.year == lastDateComponents.year;
    
    return ([date compare:firstDate] == NSOrderedDescending && [date compare:lastDate]  == NSOrderedAscending) || first || last;
}

- (NSString *)formattedTimeForEvent:(CHDEvent *)event {

    return [NSDate formattedTimeForEvent:event];
}

- (void)reload {
    CHDAPIClient *apiClient = [CHDAPIClient sharedInstance];
    NSString *resoursePath = [apiClient resourcePathForGetEventsFromYear:self.year month:self.month];
    [[[apiClient manager] cache] invalidateObjectsMatchingRegex:resoursePath];
}

- (RACSignal*) loginWithUserName: (NSString*) username password: (NSString*) password {
    return [self.loginCommand execute:RACTuplePack(username, password)];
}

- (RACCommand *)loginCommand {
    if (!_loginCommand) {
        _loginCommand = [[RACCommand alloc] initWithSignalBlock:^RACSignal *(RACTuple *tuple) {
            NSString *username = tuple.first;
            NSString *password = tuple.second;
            return [[CHDAuthenticationManager sharedInstance] rac_liftSelector:@selector(authenticateWithToken:userID:password:) withSignals:[[CHDAPIClient sharedInstance] loginWithUserName:username password:password], [RACSignal return:username], [RACSignal return:password], nil];
        }];
    }
    return _loginCommand;
}

@end
