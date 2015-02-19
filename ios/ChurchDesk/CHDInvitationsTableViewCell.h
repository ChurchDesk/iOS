//
//  CHDInvitationsTableViewCell.h
//  ChurchDesk
//
//  Created by Jakob Vinther-Larsen on 18/02/15.
//  Copyright (c) 2015 Shape A/S. All rights reserved.
//

#import "CHDTableViewCell.h"

@interface CHDInvitationsTableViewCell : CHDTableViewCell
@property (nonatomic, readonly) UILabel* titleLabel;
@property (nonatomic, readonly) UILabel* invitedByLabel;
@property (nonatomic, readonly) UILabel* locationLabel;
@property (nonatomic, readonly) UILabel* receivedTimeLabel;
@property (nonatomic, readonly) UILabel*eventTimeLabel;
@property (nonatomic, readonly) UILabel* parishLabel;
@end
