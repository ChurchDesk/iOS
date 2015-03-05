//
//  CHDDashboardInvitationsViewModel.m
//  ChurchDesk
//
//  Created by Mikkel Selsøe Sørensen on 24/02/15.
//  Copyright (c) 2015 Shape A/S. All rights reserved.
//

#import "CHDDashboardInvitationsViewModel.h"
#import "CHDAPIClient.h"
#import "CHDEnvironment.h"
#import "CHDUser.h"

@interface CHDDashboardInvitationsViewModel ()

@property (nonatomic, strong) NSArray *invitations;
@property (nonatomic, strong) CHDEnvironment *environment;
@property (nonatomic, strong) CHDUser *user;

@end

@implementation CHDDashboardInvitationsViewModel

- (instancetype)init {
    self = [super init];
    if (self) {
        RAC(self, invitations) = [[[CHDAPIClient sharedInstance] getInvitations] catch:^RACSignal *(NSError *error) {
            return [RACSignal empty];
        }];

        RAC(self, environment) = [[[CHDAPIClient sharedInstance] getEnvironment] catch:^RACSignal *(NSError *error) {
            return [RACSignal empty];
        }];

        RAC(self, user) = [[[CHDAPIClient sharedInstance] getCurrentUser] catch:^RACSignal *(NSError *error) {
            return [RACSignal empty];
        }];
    }
    return self;
}

@end
