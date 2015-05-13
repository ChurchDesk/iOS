//
//  Created by Peter Gammelgaard on 20/10/14.
//  Copyright (c) 2014 SHAPE A/S. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class SHPCalendarPickerWeekDayHeaderView;
@class SHPCalendarPickerLayoutAttributes;

@protocol SHPCalendarPickerWeekDayHeaderViewDelegate <NSObject>
- (void)didSelectNextMonthForCalendarPickerWeekDayHeaderView:(SHPCalendarPickerWeekDayHeaderView *)calendarPickerWeekDayHeaderView;
- (void)didSelectPrevMonthForCalendarPickerWeekDayHeaderView:(SHPCalendarPickerWeekDayHeaderView *)calendarPickerWeekDayHeaderView;
- (void)didSelectCurrentMonthForCalendarPickerWeekDayHeaderView:(SHPCalendarPickerWeekDayHeaderView *)calendarPickerWeekDayHeaderView;
@end

@interface SHPCalendarPickerWeekDayHeaderView : UIView

@property (nonatomic, readonly) UIButton *nextButton;
@property (nonatomic, readonly) UIButton *prevButton;

@property (nonatomic, strong) UIFont *monthDefaultFont UI_APPEARANCE_SELECTOR;
@property (nonatomic, strong) UIColor *monthDefaultColor UI_APPEARANCE_SELECTOR;
@property (nonatomic, strong) UIFont *weekDayDefaultFont UI_APPEARANCE_SELECTOR;
@property (nonatomic, strong) UIColor *weekDayDefaultColor UI_APPEARANCE_SELECTOR;
@property (nonatomic, strong) UIFont *buttonDefaultFont UI_APPEARANCE_SELECTOR;
@property (nonatomic, strong) UIColor *buttonDefaultColor UI_APPEARANCE_SELECTOR;
@property (nonatomic, strong) UIImage *nextButtonImage UI_APPEARANCE_SELECTOR;
@property (nonatomic, strong) UIImage *prevButtonImage UI_APPEARANCE_SELECTOR;
@property (nonatomic, strong) UIColor *nextButtonTintColor UI_APPEARANCE_SELECTOR;
@property (nonatomic, strong) UIColor *prevButtonTintColor UI_APPEARANCE_SELECTOR;
@property (nonatomic, weak) id<SHPCalendarPickerWeekDayHeaderViewDelegate> delegate;

@property (nonatomic, strong) NSArray *weekDayNames;
@property (nonatomic, strong) NSString *titleText;
@property (nonatomic, strong) NSString *prevTitleText;
@property (nonatomic, strong) NSString *nextTitleText;
@property (nonatomic, strong) NSString *prevMonthName;
@property (nonatomic, strong) NSString *nextMonthName;
@property (nonatomic, assign) CGFloat prevButtonHorizontalOffset;
@property (nonatomic, assign) CGFloat nextButtonHorizontalOffset;

@property (nonatomic, assign) BOOL buttonsShowMonthName;

- (SHPCalendarPickerLayoutAttributes *)layout;
- (void)animateToNextMonthName;
- (void)animateToPrevMonthName;

@end