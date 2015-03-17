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
        RAC(self, user) = [[[CHDAPIClient sharedInstance] getCurrentUser] catch:^RACSignal *(NSError *error) {
            return [RACSignal empty];
        }];
    }
    return self;
}

@end