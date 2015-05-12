//
//  NSData+Conversion.h
//  Pods
//
//  Created by Mikkel Selsøe Sørensen on 19/03/15.
//
//

#import <Foundation/Foundation.h>

@interface NSData (Conversion)

/// Suitable for converting push tokens into a string representation
- (NSString *)shp_hexStringRepresentation;

@end
