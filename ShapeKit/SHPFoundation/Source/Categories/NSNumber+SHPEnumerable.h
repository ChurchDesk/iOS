//
//  Created by Ole Gammelgaard Poulsen on 14/01/13.
//  Copyright (c) 2012 SHAPE A/S. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSNumber (SHPEnumerable)

- (void)shp_timesDo:(void (^)(NSUInteger))block;
- (NSArray *)shp_timesCollect:(id (^)(NSUInteger))block;

@end
