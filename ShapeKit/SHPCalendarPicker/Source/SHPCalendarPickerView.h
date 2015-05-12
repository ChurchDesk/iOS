//
//  Created by Peter Gammelgaard on 19/10/14.
//  Copyright (c) 2014 SHAPE A/S. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class SHPCalendarPickerView;
@class SHPCalendarPickerWeekDayHeaderView;


NS_ENUM(NSInteger , SHPCalendarPickerViewSelectionMode) {
    SHPCalendarPickerViewSelectionModeSingle,
    SHPCalendarPickerViewSelectionModeMultiple
};

@protocol SHPCalendarPickerViewDelegate <NSObject>
@optional
- (void)calendarPickerView:(SHPCalendarPickerView *)calendarPickerView didSelectDate:(NSDate *)date;
- (void)calendarPickerView:(SHPCalendarPickerView *)calendarPickerView didDeselectDate:(NSDate *)date;
- (void)calendarPickerView:(SHPCalendarPickerView *)calendarPickerView willChangeToMonth:(NSDate *)date;
- (void)calendarPickerView:(SHPCalendarPickerView *)calendarPickerView didChangeToMonth:(NSDate *)date;
- (UIColor *)calendarPickerView:(SHPCalendarPickerView *)calendarPickerView statusColorForDate:(NSDate *)date;

- (void)calendarPickerView:(SHPCalendarPickerView *)calendarPickerView didHighlightDate:(NSDate *)date forCell:(UICollectionViewCell *)cell inView:(UIView *)view;
@end

@interface SHPCalendarPickerView : UIView

// Default value is YES
@property (nonatomic, assign) BOOL disablePastDates;

// Default value is SHPCalendarPickerViewSelectionModeSingle;
@property (nonatomic, assign) enum SHPCalendarPickerViewSelectionMode selectionMode;

// Default value is [NSCalendar currentCalendar]
@property (nonatomic, strong) NSCalendar *calendar;

// Default is [NSDate date]
@property (nonatomic, strong) NSDate *currentMonth;

@property (nonatomic, strong) NSArray *selectedDates;

@property (nonatomic, weak) id<SHPCalendarPickerViewDelegate> delegate;

@property(nonatomic, strong) UIFont *textFont;
@property(nonatomic, strong) UIColor *circleDefaultColor;
@property(nonatomic, strong) UIColor *circleSelectedColor;
@property(nonatomic, strong) UIColor *circleHighlightedColor;
@property(nonatomic, strong) UIColor *circleTodayColor;
@property(nonatomic, strong) UIColor *textColor;
@property(nonatomic, strong) UIColor *textTodayColor;
@property(nonatomic, strong) UIColor *textSelectedColor;
@property(nonatomic, strong) UIColor *textHighlightedColor;
@property(nonatomic, strong) UIColor *textDistantColor;

@property(nonatomic, strong) UIColor *weekDayHeaderTextColor;
@property(nonatomic, strong) UIFont *weekDayHeaderFont;
@property(nonatomic, strong) UIColor *weekDayHeaderBackgroundColor;
@property(nonatomic, strong) UIColor *monthTextColor;
@property(nonatomic, strong) UIFont *monthFont;
@property(nonatomic, strong) UIColor *buttonTextColor;
@property(nonatomic, strong) UIFont *buttonFont;
@property(nonatomic, strong) UIColor *nextButtonTintColor;
@property(nonatomic, strong) UIColor *prevButtonTintColor;
@property(nonatomic, strong) UIImage *nextButtonImage;
@property(nonatomic, strong) UIImage *prevButtonImage;
@property (nonatomic, assign) CGFloat prevButtonHorizontalOffset;
@property (nonatomic, assign) CGFloat nextButtonHorizontalOffset;
@property (nonatomic, assign) BOOL buttonsShowMonthName;
@property(nonatomic, copy) BOOL (^disableDateBlock)(NSDate*);

@property(nonatomic, strong) NSString *headerDateFormat;
@property (nonatomic, readonly) SHPCalendarPickerWeekDayHeaderView *headerView;
@property(nonatomic, strong) NSString *buttonTitleDateFormat; // used if buttonsShowMonthName == YES

@end
