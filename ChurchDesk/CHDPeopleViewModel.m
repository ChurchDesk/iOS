//
//  CHDPeopleViewModel.m
//  ChurchDesk
//
//  Created by Chirag Sharma on 01/04/16.
//  Copyright © 2016 Shape A/S. All rights reserved.
//

#import "CHDPeopleViewModel.h"
#import "CHDAPIClient.h"
#import "CHDUser.h"
@interface CHDPeopleViewModel()
@property (nonatomic, strong) NSArray *events;

@end
@implementation CHDPeopleViewModel
- (instancetype)init {
    self = [super init];
    if (self) {
       
        CHDUser *currentUser= [[NSUserDefaults standardUserDefaults] objectForKey:kcurrentUser];
        if (currentUser.sites.count > 0) {
            CHDSite *selectedSite = [currentUser.sites objectAtIndex:0];
            _organizationId = selectedSite.siteId;
        }

        //Initial signal
        RACSignal *initialSignal = [[[[CHDAPIClient sharedInstance] getpeopleforOrganization:_organizationId] map:^id(NSArray* people) {
            [[NSUserDefaults standardUserDefaults] setValue:[NSDate date] forKey:kpeopleTimestamp];
            RACSequence *results = [people.rac_sequence filter:^BOOL(CHDEvent* event) {
                return YES;
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
        [[NSUserDefaults standardUserDefaults] setObject:_user forKey:kcurrentUser];
        [self shprac_liftSelector:@selector(reload) withSignal:authenticationTokenSignal];
    }
    return self;
}

@end
