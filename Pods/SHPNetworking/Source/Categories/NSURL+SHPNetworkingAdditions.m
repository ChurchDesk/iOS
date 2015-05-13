//
//  NSURL+SHPNetworkingAdditions.m
//  SHPNetworking
//
//  Created by Kasper Kronborg on 19/11/12.
//  Copyright (c) 2012 SHAPE A/S. All rights reserved.
//

#import "NSURL+SHPNetworkingAdditions.h"


/* Helper function for URL encoding a NSString
 */
static NSString *toURLEncodedString(id obj)
{
    NSString *string = [obj description];
    
    NSString *encodedString = nil;
    if([string respondsToSelector:@selector(stringByAddingPercentEncodingWithAllowedCharacters:)]){
        encodedString = [string stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLHostAllowedCharacterSet]];
    }else{
        encodedString = [string stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    }
    
    if ([encodedString rangeOfString:@"+"].location == NSNotFound)
        return encodedString;
    
    // This will take care of encoding if the string contains a plus-sign
    encodedString = (__bridge NSString *)CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault, (__bridge CFStringRef)obj, NULL, CFSTR("+"), CFStringConvertNSStringEncodingToEncoding(NSUTF8StringEncoding));
    return encodedString;
}


@implementation NSURL (SHPNetworkingAdditions)

- (NSURL *)URLByAppendingQueryParameters:(NSDictionary *)params
{
    /* If params is empty, just return self
     */
    if (!params) {
        return self;
    }
    
    NSMutableArray *nameAndValues = [NSMutableArray arrayWithCapacity:[params count]];
    [params enumerateKeysAndObjectsUsingBlock:^(id key, NSArray *values, BOOL *stop) {

        [values enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop1) {
            NSString *nameAndValue = [NSString stringWithFormat:@"%@=%@", toURLEncodedString(key), toURLEncodedString(obj)];

            [nameAndValues addObject:nameAndValue];
        }];

    }];
    
    BOOL urlAlreadyContainsQueryParameters = [[self absoluteString] rangeOfString:@"?"].location != NSNotFound;
    
    NSString *absoluteString = [[self absoluteString] stringByAppendingFormat:@"%@%@", urlAlreadyContainsQueryParameters ? @"&" : @"?", [nameAndValues componentsJoinedByString:@"&"]];
    
    return [NSURL URLWithString:absoluteString];
}

@end
