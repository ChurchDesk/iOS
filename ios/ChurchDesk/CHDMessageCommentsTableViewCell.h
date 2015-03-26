//
//  CHDMessageCommentsTableViewCell.h
//  ChurchDesk
//
//  Created by Jakob Vinther-Larsen on 25/02/15.
//  Copyright (c) 2015 Shape A/S. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CHDTableViewCell.h"

@interface CHDMessageCommentsTableViewCell : CHDTableViewCell
@property (nonatomic, readonly) UIButton *editButton;
@property (nonatomic, readonly) UIImageView *profileImageView;
@property (nonatomic, readonly) UILabel *userNameLabel;
@property (nonatomic, readonly) UILabel *createdDateLabel;
@property (nonatomic, readonly) UILabel *messageLabel;
@property (nonatomic, assign) BOOL canEdit;
@end
