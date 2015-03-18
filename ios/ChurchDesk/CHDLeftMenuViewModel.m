//
// Created by Jakob Vinther-Larsen on 17/03/15.
// Copyright (c) 2015 Shape A/S. All rights reserved.
//

#import "CHDLeftMenuViewModel.h"
#import "CHDAPIClient.h"

@interface CHDLeftMenuViewModel()
@property (nonatomic, strong) CHDUser *user;
@end

@implementation CHDLeftMenuViewModel

-(instancetype) init {
    self = [super init];
    if(self){
        CHDAPIClient *apiClient = [CHDAPIClient sharedInstance];

        RACSignal *updateTriggerSignal = [[apiClient.manager.cache rac_signalForSelector:@selector(invalidateObjectsMatchingRegex:)] filter:^BOOL(RACTuple *tuple) {
            NSString *regex = tuple.first;
            NSString *resourcePath = [apiClient resourcePathForGetCurrentUser];
            return [regex rangeOfString:resourcePath].location != NSNotFound;
        }];

        RACSignal *updateSignal = [updateTriggerSignal flattenMap:^RACStream *(id value) {
                return [[[CHDAPIClient sharedInstance] getCurrentUser] catch:^RACSignal *(NSError *error) {
                    return [RACSignal empty];
                }];
            }];

        RACSignal *initialSignal = [[[CHDAPIClient sharedInstance] getCurrentUser] catch:^RACSignal *(NSError *error) {
            return [RACSignal empty];
        }];
        
        RAC(self, user) = [RACSignal merge:@[initialSignal, updateSignal]];
    }
    return self;
}

@end