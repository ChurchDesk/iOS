//
//  Created by Ole Gammelgaard Poulsen on 18/12/12.
//  Copyright (c) 2012 SHAPE A/S. All rights reserved.
//
#import "NSString+SHPMiscAdditions.h"


@implementation NSString (SHPMiscAdditions)

#define kSnakeCaseCacheKey @"SnakeCaseCacheKey"

- (NSString *)shp_snakeCaseFromCamelCaseString {
	// this method is rather slow so we optimize it by caching responses
	NSMutableDictionary *dictionary = [[NSThread currentThread] threadDictionary];
	NSCache *snakeCache = [dictionary objectForKey:kSnakeCaseCacheKey];
	if (!snakeCache) {
		snakeCache = [[NSCache alloc] init];
		[dictionary setObject:snakeCache forKey:kSnakeCaseCacheKey];
	}
	NSString *cachedResult = [snakeCache objectForKey:self];
	if (cachedResult) {
		return cachedResult;
	}

	NSScanner *scanner = [NSScanner scannerWithString:self];
	scanner.caseSensitive = YES;

	NSString *builder = [NSString string];
	NSString *buffer = nil;
	NSUInteger lastScanLocation = 0;

	NSCharacterSet *lowercaseSet = [NSCharacterSet lowercaseLetterCharacterSet];
	NSCharacterSet *uppercaseSet = [NSCharacterSet uppercaseLetterCharacterSet];

	while ([scanner isAtEnd] == NO) {
		if ([scanner scanCharactersFromSet:lowercaseSet intoString:&buffer]) {
			builder = [builder stringByAppendingString:buffer];
			if ([scanner scanCharactersFromSet:uppercaseSet intoString:&buffer]) {
				builder = [builder stringByAppendingString:@"_"];
				builder = [builder stringByAppendingString:buffer];
			}
		}

		// If the scanner location has not moved, there's a problem somewhere.
		if (lastScanLocation == scanner.scanLocation) return nil;
		lastScanLocation = scanner.scanLocation;
	}
	NSString *result = [builder lowercaseString];

	// save to cache
	[snakeCache setObject:result forKey:self];

	return result;
}

- (NSString *)shp_capitalizedFirstLetterString {
	if ([self length] < 1) return [self copy];
	return [[self lowercaseString] stringByReplacingCharactersInRange:NSMakeRange(0, 1) withString:[[self substringToIndex:1] uppercaseString]];
}

- (NSString *)shp_firstCaptureOfRegex:(NSString *)pattern {
	NSError *error = nil;
	NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:pattern options:NSRegularExpressionCaseInsensitive error:&error];
	NSTextCheckingResult *match = [regex firstMatchInString:self options:0 range:NSMakeRange(0, [self length])];
	NSString *capturedString = nil;
	if (match) {
		capturedString = [self substringWithRange:[match rangeAtIndex:1]];
	}
	return capturedString;
}

- (NSArray *)shp_capturesOfRegex:(NSString *)pattern {
	NSError *error = nil;
	NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:pattern options:NSRegularExpressionCaseInsensitive error:&error];
	NSTextCheckingResult *match = [regex firstMatchInString:self options:0 range:NSMakeRange(0, [self length])];
	NSArray *captures = @[];
	if (match) {
		for (int i = 1; i < [match numberOfRanges]; i++) {
			NSRange range = [match rangeAtIndex:(NSUInteger) i];
			if (range.location == NSNotFound) return nil;
			NSString *capture = [self substringWithRange:range];
			captures = [captures arrayByAddingObject:capture];
		}
	}
	return captures;
}

- (BOOL)shp_matchesRegex:(NSString *)pattern {
	NSError *error = nil;
	NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:pattern options:NSRegularExpressionCaseInsensitive error:&error];
	NSTextCheckingResult *match = [regex firstMatchInString:self options:0 range:NSMakeRange(0, [self length])];
	return (match != nil);
}

- (NSString *)shp_stringByRemovingOccurancesOfStrings:(NSArray *)strings {
	NSMutableString *str = [self mutableCopy];
	[strings enumerateObjectsUsingBlock:^(NSString *needle, NSUInteger idx, BOOL *stop) {
		NSAssert([needle isKindOfClass:[NSString class]], @"Array must contain only strings");
		[str replaceOccurrencesOfString:needle withString:@"" options:0 range:NSMakeRange(0, [str length])];
	}];
	return [str copy];
}

- (BOOL)shp_matchesEmailRegex {
    NSString *emailRegEx =
        @"(?:[a-z0-9!#$%\\&'*+/=?\\^_`{|}~-]+(?:\\.[a-z0-9!#$%\\&'*+/=?\\^_`{|}"
            @"~-]+)*|\"(?:[\\x01-\\x08\\x0b\\x0c\\x0e-\\x1f\\x21\\x23-\\x5b\\x5d-\\"
            @"x7f]|\\\\[\\x01-\\x09\\x0b\\x0c\\x0e-\\x7f])*\")@(?:(?:[a-z0-9](?:[a-"
            @"z0-9-]*[a-z0-9])?\\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?|\\[(?:(?:25[0-5"
            @"]|2[0-4][0-9]|[01]?[0-9][0-9]?)\\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-"
            @"9][0-9]?|[a-z0-9-]*[a-z0-9]:(?:[\\x01-\\x08\\x0b\\x0c\\x0e-\\x1f\\x21"
            @"-\\x5a\\x53-\\x7f]|\\\\[\\x01-\\x09\\x0b\\x0c\\x0e-\\x7f])+)\\])";

    NSPredicate *regExPredicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegEx];
    return [regExPredicate evaluateWithObject:[self lowercaseString]];
}

@end
