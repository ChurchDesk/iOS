//
//  CHDDayPickerViewModel.h
//  ChurchDesk
//
//  Created by Mikkel Selsøe Sørensen on 25/02/15.
//  Copyright (c) 2015 Shape A/S. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CHDDayPickerViewModel : NSObject

- (NSDate*) dateOffsetByDays: (NSInteger) offset fromDate: (NSDate*) date;
- (NSString*) threeLetterWeekdayFromDate: (NSDate*) date;
- (NSString*) dayOfMonthFromDate: (NSDate*) date;

@end
