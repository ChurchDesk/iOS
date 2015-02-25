//
//  CHDDashboardMessagesViewModel.m
//  ChurchDesk
//
//  Created by Jakob Vinther-Larsen on 25/02/15.
//  Copyright (c) 2015 Shape A/S. All rights reserved.
//

#import "CHDDashboardMessagesViewModel.h"
#import "CHDAPIClient.h"

@implementation CHDDashboardMessagesViewModel
- (instancetype)init {
    self = [super init];
    if (self) {
        RAC(self, messages) = [[[CHDAPIClient sharedInstance] getUnreadMessages] catch:^RACSignal *(NSError *error) {
            return [RACSignal empty];
        }];
    }
    return self;
}
@end
