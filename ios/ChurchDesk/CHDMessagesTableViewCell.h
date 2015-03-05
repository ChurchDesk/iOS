//
//  CHDMessagesTableViewCell.h
//  ChurchDesk
//
//  Created by Jakob Vinther-Larsen on 19/02/15.
//  Copyright (c) 2015 Shape A/S. All rights reserved.
//

#import "CHDDotView.h"
#import "CHDAccessoryTableViewCell.h"

@interface CHDMessagesTableViewCell : CHDAccessoryTableViewCell
@property (nonatomic, readonly) UILabel* groupLabel;
@property (nonatomic, readonly) UILabel* parishLabel;
@property (nonatomic, readonly) UILabel* authorLabel;
@property (nonatomic, readonly) UILabel* contentLabel;
@property (nonatomic, readonly) UILabel* receivedTimeLabel;
@property (nonatomic, readonly) CHDDotView* receivedDot;

@property (nonatomic, readonly) UIButton *markAsReadButton;
@end
