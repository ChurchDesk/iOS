//
//  NSString+SHPNetworkingAdditions.m
//  SHPNetworking
//
//  Created by Kasper Kronborg on 28/11/12.
//  Copyright (c) 2012 SHAPE A/S. All rights reserved.
//

#import "NSString+SHPNetworkingAdditions.h"

#define kSnakeCaseCacheKey @"SnakeCaseCacheKey"


@implementation NSString (SHPNetworkingAdditions)

- (NSString *)asSnakeCase
{
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

@end
