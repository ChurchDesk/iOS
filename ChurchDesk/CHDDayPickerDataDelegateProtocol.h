//
// Created by Jakob Vinther-Larsen on 29/04/15.
// Copyright (c) 2015 Shape A/S. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol CHDDayPickerDataDelegateProtocol <NSObject>
//Returns true if the supplied date contains one or more events, the dayPicker will show a dot on the give day
-(BOOL) chdDayPickerEventsExistsOnDay: (NSDate*) date;
@end