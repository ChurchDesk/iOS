//
//  CHDCreatePersonViewModel.m
//  ChurchDesk
//
//  Created by Chirag Sharma on 10/06/16.
//  Copyright © 2016 ChurchDesk ApS. All rights reserved.
//

#import "CHDCreatePersonViewModel.h"
#import "CHDAPIClient.h"
#import "CHDUser.h"
#import "CHDSite.h"
#import "CHDTag.h"
#import "CHDAuthenticationManager.h"

@implementation CHDCreatePersonViewModel

- (instancetype)init {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSData *encodedObject = [defaults objectForKey:kcurrentuser];
    CHDUser *user = [NSKeyedUnarchiver unarchiveObjectWithData:encodedObject];
    NSString *organizationId;
    if (user.sites.count > 1) {
        organizationId = [defaults valueForKey:kselectedOrganizationIdforPeople];
    }
    else{
        CHDSite *site = [user.sites objectAtIndex:0];
        organizationId = site.siteId;
    }
    //Initial signal
    RACSignal *initialSignal = [[[[CHDAPIClient sharedInstance] getTagsforOrganization:organizationId] map:^id(NSArray* tags) {
        RACSequence *results = [tags.rac_sequence filter:^BOOL(CHDTag* tag) {
            if (tag.name.length >1) {
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
    
    RACSignal *updateSignal = [[[apiClient.manager.cache rac_signalForSelector:@selector(invalidateObjectsMatchingRegex:)] filter:^BOOL(RACTuple *tuple) {
        NSString *regex = tuple.first;
        NSString *resourcePath = [apiClient resourcePathForGetSegments];
        [[NSUserDefaults standardUserDefaults] setValue:[NSDate date] forKey:keventsTimestamp];
        return [regex rangeOfString:resourcePath].location != NSNotFound;
    }] flattenMap:^RACStream *(id value) {
        return [[[[CHDAPIClient sharedInstance] getSegmentsforOrganization:organizationId] map:^id(NSArray* tags) {
            RACSequence *results = [tags.rac_sequence filter:^BOOL(CHDTag* tag) {
                if (tag.name.length >1) {
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
    RAC(self, tags) = [RACSignal merge:@[initialSignal, updateSignal]];
    
    RAC(self, canCreatePerson) = [RACSignal combineLatest:@[RACObserve(self, firstName), RACObserve(self, lastName), RACObserve(self, phoneNumber), RACObserve(self, email)]
                                                  reduce:^(NSString *firstName, NSString *lastName, NSString *phoneNumber, NSString *email){
                                                      BOOL validFirstName = !([firstName isEqualToString:@""]);
                                                      BOOL validLastName = !([lastName isEqualToString:@""]);
                                                      BOOL validPhoneNumber = !([phoneNumber isEqualToString:@""]);
                                                      BOOL validEmail = !([email isEqualToString:@""]);
                                                      
                                                      return @(validFirstName || validLastName || validPhoneNumber || validEmail);
                                                  }];
    return self;
}




@end
