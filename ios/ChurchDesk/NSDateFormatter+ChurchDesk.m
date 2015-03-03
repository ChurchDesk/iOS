//
//  NSDateFormatter+ChurchDesk.m
//  ChurchDesk
//
//  Created by Mikkel Selsøe Sørensen on 03/03/15.
//  Copyright (c) 2015 Shape A/S. All rights reserved.
//

#import "NSDateFormatter+ChurchDesk.h"

@implementation NSDateFormatter (ChurchDesk)

+ (instancetype) chd_apiDateFormatter {
    NSDateFormatter *dateFormatter = [NSDateFormatter new];
    [dateFormatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"]];
    dateFormatter.dateFormat = @"yyyy-MM-dd'T'HH:mm:ssZ";
    [dateFormatter setTimeZone:[NSTimeZone timeZoneWithName:@"GMT"]];
    return dateFormatter;
}

@end
