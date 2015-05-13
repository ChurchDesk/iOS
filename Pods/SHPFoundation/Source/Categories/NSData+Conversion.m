//
//  NSData+Conversion.m
//  Pods
//
//  Created by Mikkel Selsøe Sørensen on 19/03/15.
//
//

#import "NSData+Conversion.h"

@implementation NSData (Conversion)

- (NSString *)shp_hexStringRepresentation {
    const char *data = [self bytes];
    NSMutableString *token = [NSMutableString string];
    
    for (int i = 0; i < [self length]; i++) {
        [token appendFormat:@"%02.2hhX", data[i]];
    }
    
    return [token copy];
}

@end
