//
// Created by Peter Gammelgaard on 19/11/14.
// Copyright (c) 2014 Shape A/S. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SHPDateFormatter : NSDateFormatter

@end

@interface SHPDateFormatterHelper : NSObject

/**
 Returns a date formatter suitable for parsing a string representation into a NSDate from a given format
*/
+ (NSDateFormatter *)parseDateFormatterWithFormat:(NSString *)format;

/**
 Returns a date formatter suitable for making a string representation of a NSDate from a given format
*/
+ (NSDateFormatter *)dateFormatterWithFormat:(NSString *)format;

/**
 Makes a string representation of a NSDate from a given format
*/
+ (NSString *)stringFromDate:(NSDate *)date withFormat:(NSString *)format;

/**
 Makes a NSDate from string representation from a given format
*/
+ (NSDate *)dateFromString:(NSString *)dateString withFormat:(NSString *)format;

@end