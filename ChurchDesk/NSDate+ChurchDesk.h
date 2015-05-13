//
// Created by Jakob Vinther-Larsen on 12/04/15.
// Copyright (c) 2015 Shape A/S. All rights reserved.
//

#import <Foundation/Foundation.h>

@class CHDEvent;

@interface NSDate (ChurchDesk)
+ (NSString *)formattedTimeForEvent:(CHDEvent *)event;
+ (NSString *)formattedTimeForEvent:(CHDEvent *)event referenceDate: (NSDate*) referenceDate;
@end