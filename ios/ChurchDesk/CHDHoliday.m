//
//  CHDHoliday.m
//  ChurchDesk
//
//  Created by Mikkel Selsøe Sørensen on 03/03/15.
//  Copyright (c) 2015 Shape A/S. All rights reserved.
//

#import "CHDHoliday.h"

@implementation CHDHoliday

- (NSString *)mapPropertyForPropertyWithName:(NSString *)propName {
    if ([propName isEqualToString:@"date"]) {
        return @"startDate";
    }
    return [super mapPropertyForPropertyWithName:propName];
}

- (id)transformedValueForPropertyWithName:(NSString *)propName value:(id)value {
    
    if ([propName isEqualToString:@"date"]) {
        NSDate *date = [[self dateFormatterForPropertyWithName:propName] dateFromString:value];
        NSCalendar *calendar = [NSCalendar currentCalendar];
        return [calendar dateBySettingHour:0 minute:0 second:0 ofDate:date options:0];
    }
    
    return [super transformedValueForPropertyWithName:propName value:value];
}

@end
