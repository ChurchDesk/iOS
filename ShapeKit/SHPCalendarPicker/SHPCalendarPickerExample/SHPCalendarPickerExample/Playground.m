//
// Created by Peter Gammelgaard on 22/11/14.
// Copyright (c) 2014 Peter Gammelgaard. All rights reserved.
//

#import <SHPCalendarPicker/SHPCalendarPickerView.h>
#import "Playground.h"
#import "KZPPlayground+Internal.h"
#import "View+MASAdditions.h"
#import "MASConstraint+Private.h"

@implementation Playground {

}

- (void)run {
    [self setupCalendarPickerView];
}

- (void)setupCalendarPickerView {
    KZPAdjustValue(width, 200, 600).defaultValue(320);
    KZPAdjustValue(height, 200, 600).defaultValue(300);

    SHPCalendarPickerView *calendarPickerView = [[SHPCalendarPickerView alloc] init];
    [calendarPickerView setSelectionMode:SHPCalendarPickerViewSelectionModeMultiple];
    [calendarPickerView setDisablePastDates:YES];
    [calendarPickerView setDisableDateBlock:^BOOL(NSDate *date){
        return NO;
    }];

    [self.worksheetView addSubview:calendarPickerView];

    __block MASConstraint *heightConstraint;
    __block MASConstraint *widthConstraint;
    [calendarPickerView mas_updateConstraints:^(MASConstraintMaker *make) {
        heightConstraint = make.height.equalTo(@(height));
        widthConstraint = make.width.equalTo(@(width));
        make.center.equalTo(self.worksheetView);
    }];

    KZPAdjustValue(dayFontSize, 10, 25).defaultValue(15);
    KZPWhenChanged(dayFontSize, ^(int newHeaderFontSize){
        calendarPickerView.textFont = [UIFont systemFontOfSize:newHeaderFontSize];
    });

    KZPWhenChanged(width, ^(int w) {
        [widthConstraint setLayoutConstantWithValue:@(w)];
    });

    KZPWhenChanged(height, ^(int h) {
        [heightConstraint setLayoutConstantWithValue:@(h)];
    });
    
}


@end