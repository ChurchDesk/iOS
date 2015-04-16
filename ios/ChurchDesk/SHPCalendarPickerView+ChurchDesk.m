//
//  SHPCalendarPickerView+ChurchDesk.m
//  ChurchDesk
//
//  Created by Mikkel Selsøe Sørensen on 23/02/15.
//  Copyright (c) 2015 Shape A/S. All rights reserved.
//

#import "SHPCalendarPickerView+ChurchDesk.h"
#import "SHPCalendarPickerWeekDayHeaderView.h"

@implementation SHPCalendarPickerView (ChurchDesk)

+ (instancetype) chd_calendarPickerView {
    SHPCalendarPickerView *calendarPickerView = [SHPCalendarPickerView new];
    calendarPickerView.disablePastDates = NO;
    calendarPickerView.textFont = [UIFont chd_fontWithFontWeight:CHDFontWeightRegular size:20];
    calendarPickerView.circleSelectedColor = [UIColor chd_blueColor];
    calendarPickerView.textColor = [UIColor chd_textDarkColor];
    calendarPickerView.textTodayColor = [UIColor chd_blueColor];
    calendarPickerView.textSelectedColor = [UIColor whiteColor];

    calendarPickerView.weekDayHeaderTextColor = [UIColor chd_textDarkColor];
    calendarPickerView.weekDayHeaderFont = [UIFont chd_fontWithFontWeight:CHDFontWeightRegular size:13];
    calendarPickerView.monthTextColor = [UIColor colorWithWhite:(2.0f/3.0f) alpha:1.0];
    calendarPickerView.monthFont = [UIFont chd_fontWithFontWeight:CHDFontWeightRegular size:20];
    
    calendarPickerView.buttonFont = [UIFont chd_fontWithFontWeight:CHDFontWeightRegular size:18];
    calendarPickerView.buttonTextColor = [UIColor chd_textDarkColor];
    
    calendarPickerView.prevButtonImage = kImgMonthArrowLeft;
    calendarPickerView.nextButtonImage = kImgMonthArrowRight;
    calendarPickerView.buttonsShowMonthName = YES;
    calendarPickerView.headerDateFormat = @"yyyy";
    calendarPickerView.buttonTitleDateFormat = @"MMMM";
    calendarPickerView.prevButtonHorizontalOffset = -11;
    calendarPickerView.nextButtonHorizontalOffset = 11;
    
    UIEdgeInsets nextImageInsets = calendarPickerView.headerView.nextButton.imageEdgeInsets;
    nextImageInsets.top += 4;
    calendarPickerView.headerView.nextButton.imageEdgeInsets = nextImageInsets;

    UIEdgeInsets prevImageInsets = calendarPickerView.headerView.prevButton.imageEdgeInsets;
    prevImageInsets.top += 4;
    calendarPickerView.headerView.prevButton.imageEdgeInsets = prevImageInsets;

    UIView *bottomLine = [UIView new];
    bottomLine.backgroundColor = [UIColor chd_cellDividerColor];
    [calendarPickerView addSubview:bottomLine];
    [bottomLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.equalTo(calendarPickerView);
        make.height.equalTo(@1);
    }];
    
    return calendarPickerView;
}

@end
