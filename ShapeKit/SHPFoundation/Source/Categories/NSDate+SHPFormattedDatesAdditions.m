//
//  Created by Ole Gammelgaard Poulsen on 02/04/13.
//  Copyright (c) 2012 SHAPE A/S. All rights reserved.
//

#import "NSDate+SHPFormattedDatesAdditions.h"


@implementation NSDate (SHPFormattedDatesAdditions)

- (NSString *)shp_stringWithTimeStyle:(NSDateFormatterStyle)timeStyle dateStyle:(NSDateFormatterStyle)dateStyle {
	NSString *cacheKey = [NSString stringWithFormat:@"DateFormatterTime:%dDate:%d", timeStyle, dateStyle];
	NSMutableDictionary *cache = [[NSThread currentThread] threadDictionary];
	NSDateFormatter *dateFormatter = [cache objectForKey:cacheKey];
	if (!dateFormatter) {
		dateFormatter = [NSDateFormatter new];
		dateFormatter.timeStyle = timeStyle;
		dateFormatter.dateStyle = dateStyle;
		[cache setObject:dateFormatter forKey:cacheKey];
	}
	return [dateFormatter stringFromDate:self];
}

- (NSString *)shp_stringWithTimeStyle:(NSDateFormatterStyle)timeStyle {
	return [self shp_stringWithTimeStyle:timeStyle dateStyle:NSDateFormatterNoStyle];
}

- (NSString *)shp_stringWithDateStyle:(NSDateFormatterStyle)dateStyle {
	return [self shp_stringWithTimeStyle:NSDateFormatterNoStyle dateStyle:dateStyle];
}

- (NSString *)shp_stringWithDateFormat:(NSString *)dateFormat {
	NSAssert(dateFormat.length, @"dateFormat must be valid date format string");
	NSString *cacheKey = [NSString stringWithFormat:@"DateFormatterFormat:%@", dateFormat];
	NSMutableDictionary *cache = [[NSThread currentThread] threadDictionary];
	NSDateFormatter *dateFormatter = [cache objectForKey:cacheKey];
	if (!dateFormatter) {
		dateFormatter = [NSDateFormatter new];
		dateFormatter.dateFormat = dateFormat;
		[cache setObject:dateFormatter forKey:cacheKey];
	}
	return [dateFormatter stringFromDate:self];
}




@end
