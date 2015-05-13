//
// Created by Peter Gammelgaard on 19/11/14.
// Copyright (c) 2014 Shape A/S. All rights reserved.
//

#import "SHPDateFormatterHelper.h"

static NSString * const SHPDateFormatterKey = @"SHPDateFormatterKey";
static NSString * const SHPDateFormatterParseKey = @"SHPDateFormatterParseKey";

@interface SHPDateFormatter()
@property (nonatomic, assign) BOOL parse;
@end

@implementation SHPDateFormatter

+ (SHPDateFormatter *)shp_parseDateFormatter {
    SHPDateFormatter *df = [SHPDateFormatter new];
    df.parse = YES;
    return df;
}

+ (SHPDateFormatter *)shp_dateFormatter {
    SHPDateFormatter *df = [SHPDateFormatter new];
    df.parse = NO;
    return df;
}

- (NSString *)stringFromDate:(NSDate *)date {
    NSAssert(!self.parse, @"SHPDateFormatter used incorrectly. Please use +dateFormatterWithFormat instead");
    return [super stringFromDate:date];
}

- (NSDate *)dateFromString:(NSString *)dateString {
    NSAssert(self.parse, @"SHPDateFormatter used incorrectly. Please use +parseDateFormatterWithFormat instead");
    return [super dateFromString:dateString];
}

- (void)setDateFormat:(NSString *)dateFormat {
    NSAssert(self.dateFormat == nil || self.dateFormat.length == 0, @"Setting the date format is not supported. Use +dateFormatterWithFormat or +parseDateFormatterWithFormat instead to get a another NSDateFormatter instance");
    [super setDateFormat:dateFormat];
}

@end

@interface SHPDateFormatterHelper ()
@end

@implementation SHPDateFormatterHelper {

}

+ (NSDateFormatter *)parseDateFormatterWithFormat:(NSString *)format {
    NSString *cacheKey = [NSString stringWithFormat:@"%@-%@", SHPDateFormatterParseKey, format];
    NSMutableDictionary *cache = [[NSThread currentThread] threadDictionary];
    SHPDateFormatter *df = cache[cacheKey];

    if (!df) {
        df = [SHPDateFormatter shp_parseDateFormatter];
        [df setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"]];
        [df setDateFormat:format];
        cache[cacheKey] = df;
    }

    return df;
}

+ (NSDateFormatter *)dateFormatterWithFormat:(NSString *)format {
    NSString *cacheKey = [NSString stringWithFormat:@"%@-%@", SHPDateFormatterKey, format];
    NSMutableDictionary *cache = [[NSThread currentThread] threadDictionary];
    SHPDateFormatter *df = cache[cacheKey];

    if (!df) {
        df = [SHPDateFormatter shp_dateFormatter];
        [df setDateFormat:format];
        cache[cacheKey] = df;
    }

    return df;
}

+ (NSString *)stringFromDate:(NSDate *)date withFormat:(NSString *)format {
    NSDateFormatter *df = [SHPDateFormatterHelper dateFormatterWithFormat:format];
    return [df stringFromDate:date];
}

+ (NSDate *)dateFromString:(NSString *)dateString withFormat:(NSString *)format {
    NSDateFormatter *df = [SHPDateFormatterHelper parseDateFormatterWithFormat:format];
    return [df dateFromString:dateString];
}

@end