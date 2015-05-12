//
//  Created by Peter Gammelgaard on 20/10/14.
//  Copyright (c) 2014 SHAPE A/S. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>


@interface SHPCalendarPickerDayCell : UICollectionViewCell

@property (nonatomic, strong) UIFont *textDefaultFont UI_APPEARANCE_SELECTOR;

@property (nonatomic, strong) UIColor *textDefaultColor UI_APPEARANCE_SELECTOR;
@property (nonatomic, strong) UIColor *textSelectedColor UI_APPEARANCE_SELECTOR;
@property (nonatomic, strong) UIColor *textHighlightedColor UI_APPEARANCE_SELECTOR;
@property (nonatomic, strong) UIColor *textTodayColor UI_APPEARANCE_SELECTOR;
@property (nonatomic, strong) UIColor *textDistantColor UI_APPEARANCE_SELECTOR;

@property (nonatomic, strong) UIColor *circleSelectedColor UI_APPEARANCE_SELECTOR;
@property (nonatomic, strong) UIColor *circleHighlightedColor UI_APPEARANCE_SELECTOR;
@property (nonatomic, strong) UIColor *circleDefaultColor UI_APPEARANCE_SELECTOR;
@property (nonatomic, strong) UIColor *circleTodayColor UI_APPEARANCE_SELECTOR;

@property (nonatomic, assign, getter=isToday) BOOL today;
@property (nonatomic, assign, getter=isDistant) BOOL distant;
@property (nonatomic, readonly) UILabel *dayLabel;
@property (nonatomic, strong) UIColor *statusColor;

- (void)setSelected:(BOOL)date animated:(BOOL)animated;
@end