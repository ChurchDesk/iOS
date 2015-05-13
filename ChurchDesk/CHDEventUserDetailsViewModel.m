//
//  CHDEventUserDetailsViewModel.m
//  ChurchDesk
//
//  Created by Mikkel Selsøe Sørensen on 26/03/15.
//  Copyright (c) 2015 Shape A/S. All rights reserved.
//

#import "CHDEventUserDetailsViewModel.h"
#import "CHDAPIClient.h"

@implementation CHDEventUserDetailsViewModel

- (instancetype)init {
    self = [super init];
    if (self) {
        RAC(self, environment) = [[[CHDAPIClient sharedInstance] getEnvironment] catch:^RACSignal *(NSError *error) {
            return [RACSignal empty];
        }];
    }
    return self;
}

@end
