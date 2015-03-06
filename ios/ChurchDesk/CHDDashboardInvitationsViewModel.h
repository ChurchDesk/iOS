//
//  CHDDashboardInvitationsViewModel.h
//  ChurchDesk
//
//  Created by Mikkel Selsøe Sørensen on 24/02/15.
//  Copyright (c) 2015 Shape A/S. All rights reserved.
//

#import <Foundation/Foundation.h>

@class CHDEnvironment;
@class CHDUser;
@class CHDInvitation;

@interface CHDDashboardInvitationsViewModel : NSObject

@property (nonatomic, readonly) NSArray *invitations;
@property (nonatomic, readonly) CHDEnvironment *environment;
@property (nonatomic, readonly) CHDUser *user;

-(NSString*)getFormattedInvitationTimeFrom:(CHDInvitation *)invitation;

@end
