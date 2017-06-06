//
//  CHDMessageCommentsTableViewCell.h
//  ChurchDesk
//
//  Created by Jakob Vinther-Larsen on 25/02/15.
//  Copyright (c) 2015 Shape A/S. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CHDTableViewCell.h"

@interface CHDMessageCommentsTableViewCell : CHDTableViewCell <UITextViewDelegate>
@property (nonatomic, readonly) UIButton *editButton;
@property (nonatomic, readonly) UIImageView *profileImageView;
@property (nonatomic, readonly) UILabel *userNameLabel;
@property (nonatomic, readonly) UILabel *createdDateLabel;
@property (nonatomic, readonly) UITextView *messageTextView;
@property (nonatomic, assign) BOOL canEdit;
@end
