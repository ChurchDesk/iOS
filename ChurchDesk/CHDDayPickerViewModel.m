//
//  CHDDayPickerViewModel.m
//  ChurchDesk
//
//  Created by Mikkel Selsøe Sørensen on 25/02/15.
//  Copyright (c) 2015 Shape A/S. All rights reserved.
//

#import "CHDDayPickerViewModel.h"

@interface CHDDayPickerViewModel ()

@property (nonatomic, strong) NSDateFormatter *weekdayFormatter;
@property (nonatomic, strong) NSDateFormatter *dayOfMonthFormatter;

@end

@implementation CHDDayPickerViewModel

- (NSDate*) dateOffsetByDays: (NSInteger) offset fromDate: (NSDate*) date {    
    return [[NSCalendar currentCalendar] dateByAddingUnit:NSCalendarUnitDay value:offset toDate:date options:0];
}

- (NSString*) threeLetterWeekdayFromDate: (NSDate*) date {
    return [self.weekdayFormatter stringFromDate:date];
}

- (NSString*) dayOfMonthFromDate: (NSDate*) date {
    return [self.dayOfMonthFormatter stringFromDate:date];
}

- (NSUInteger) daysFromReferenceDate: (NSDate*) referenceDate toDate: (NSDate*) date {
    NSDateComponents *comps = [[NSCalendar currentCalendar] components:NSCalendarUnitDay fromDate:referenceDate toDate:date options:0];
    return comps.day;
}

- (NSDate*) dateForMondayOfWeekWithDate: (NSDate*) date {
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSInteger weekday = [calendar component:NSCalendarUnitWeekday fromDate:date];
    if (weekday == 1) {
        weekday = 8;
    }
    return [calendar dateByAddingUnit:NSCalendarUnitDay value:2-weekday toDate:date options:0];
}

#pragma mark - Lazy Initialization

- (NSDateFormatter *)weekdayFormatter {
    if (!_weekdayFormatter) {
        _weekdayFormatter = [NSDateFormatter new];
        _weekdayFormatter.dateFormat = @"EEE";
    }
    return _weekdayFormatter;
}

- (NSDateFormatter *)dayOfMonthFormatter {
    if (!_dayOfMonthFormatter) {
        _dayOfMonthFormatter = [NSDateFormatter new];
        _dayOfMonthFormatter.dateFormat = @"d";
    }
    return _dayOfMonthFormatter;
}

@end
