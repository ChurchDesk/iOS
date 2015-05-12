//
//  Created by Ole Gammelgaard Poulsen on 18/12/12.
//  Copyright (c) 2012 SHAPE A/S. All rights reserved.
//
#import <Foundation/Foundation.h>

@interface NSString (SHPBase64additions)

+ (NSString *)shp_stringByBase64EncodingData:(NSData *)data;
- (NSString *)shp_stringByBase64Encoding;

@end
