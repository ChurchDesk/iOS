//
//  CHDSegmentViewModel.m
//  ChurchDesk
//
//  Created by Chirag Sharma on 12/04/16.
//  Copyright © 2016 Shape A/S. All rights reserved.
//

#import "CHDSegmentViewModel.h"
#import "CHDAPIClient.h"
#import "CHDUser.h"
#import "CHDSegment.h"
#import "CHDAuthenticationManager.h"
#import "NSDate+ChurchDesk.h"

@implementation CHDSegmentViewModel
- (instancetype)init{
    self = [super init];
    if (self) {
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        NSData *encodedObject = [defaults objectForKey:kcurrentuser];
        CHDUser *user = [NSKeyedUnarchiver unarchiveObjectWithData:encodedObject];
        if (user.sites.count > 1) {
            _organizationId = [defaults valueForKey:kselectedOrganizationIdforPeople];
        }
        else{
            CHDSite *site = [user.sites objectAtIndex:0];
            _organizationId = site.siteId;
        }
        //Initial signal
        RACSignal *initialSignal = [[[[CHDAPIClient sharedInstance] getSegmentsforOrganization:_organizationId] map:^id(NSArray* segments) {
            RACSequence *results = [segments.rac_sequence filter:^BOOL(CHDSegment* segment) {
                if (segment.name.length >1) {
                    return YES;
                }
                else{
                    return NO;
                }
            }];
            
            return results.array;
            
        }] catch:^RACSignal *(NSError *error) {
            return [RACSignal empty];
        }];
        
        
        //Update signal
        CHDAPIClient *apiClient = [CHDAPIClient sharedInstance];
        
        RACSignal *authenticationTokenSignal = [RACObserve([CHDAuthenticationManager sharedInstance], authenticationToken) ignore:nil];
        
        RACSignal *updateSignal = [[[apiClient.manager.cache rac_signalForSelector:@selector(invalidateObjectsMatchingRegex:)] filter:^BOOL(RACTuple *tuple) {
            NSString *regex = tuple.first;
            NSString *resourcePath = [apiClient resourcePathForGetSegments];
            [[NSUserDefaults standardUserDefaults] setValue:[NSDate date] forKey:keventsTimestamp];
            return [regex rangeOfString:resourcePath].location != NSNotFound;
        }] flattenMap:^RACStream *(id value) {
            return [[[[CHDAPIClient sharedInstance] getSegmentsforOrganization:_organizationId] map:^id(NSArray* segments) {
                RACSequence *results = [segments.rac_sequence filter:^BOOL(CHDSegment* segment) {
                    if (segment.name.length >1) {
                        return YES;
                    }
                    else{
                        return NO;
                    }
                }];
                return results.array;
            }] catch:^RACSignal *(NSError *error) {
                return [RACSignal empty];
            }];
        }];
        
        RAC(self, segments) = [RACSignal merge:@[initialSignal, updateSignal]];
        [self shprac_liftSelector:@selector(reload) withSignal:authenticationTokenSignal];
    }
    return self;
}

- (void)reload {
    CHDAPIClient *apiClient = [CHDAPIClient sharedInstance];
    NSString *resoursePath = [apiClient resourcePathForGetSegments];
    [[[apiClient manager] cache] invalidateObjectsMatchingRegex:resoursePath];
}

@end
