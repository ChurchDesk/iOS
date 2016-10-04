//
//  CHDCalendarTitleView.h
//  ChurchDesk
//
//  Created by Mikkel Selsøe Sørensen on 23/02/15.
//  Copyright (c) 2015 Shape A/S. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIButton+CHDCalendarTitleButton.h"

@interface CHDCalendarTitleView : UIView

@property (nonatomic, readonly) UIButton *titleButton;
@property (nonatomic, assign) BOOL pointArrowDown;
- (void)setFrame:(CGRect)frame;
@end
