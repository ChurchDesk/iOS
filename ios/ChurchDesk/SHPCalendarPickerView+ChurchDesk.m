//
//  SHPCalendarPickerView+ChurchDesk.m
//  ChurchDesk
//
//  Created by Mikkel Selsøe Sørensen on 23/02/15.
//  Copyright (c) 2015 Shape A/S. All rights reserved.
//

#import "SHPCalendarPickerView+ChurchDesk.h"

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
    calendarPickerView.monthTextColor = [UIColor chd_textDarkColor];
    calendarPickerView.monthFont = [UIFont chd_fontWithFontWeight:CHDFontWeightRegular size:20];
//    calendarPickerView.prevButtonImage = kimgm
    
    return calendarPickerView;
}

@end
