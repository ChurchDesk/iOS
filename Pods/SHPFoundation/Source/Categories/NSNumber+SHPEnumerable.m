//
//  Created by Ole Gammelgaard Poulsen on 14/01/13.
//  Copyright (c) 2012 SHAPE A/S. All rights reserved.
//

#import "NSNumber+SHPEnumerable.h"


@implementation NSNumber (SHPEnumerable)

- (void)shp_timesDo:(void (^)(NSUInteger))block {
	NSInteger times = [self integerValue];
	NSAssert(times >= 0, @"Number must be >= 0");
	NSAssert(block, @"You must pass a non-nill block");
	for (NSUInteger idx = 0; idx < times; idx++ ) {
		block(idx);
	}
}

- (NSArray *)shp_timesCollect:(id (^)(NSUInteger))block {
	NSInteger times = [self integerValue];
	NSAssert(times >= 0, @"Number must be >= 0");
	NSAssert(block, @"You must pass a non-nill block");
	NSMutableArray *results = [NSMutableArray arrayWithCapacity:times];
	for (NSUInteger idx = 0; idx < times; idx++ ) {
		id newObject = block(idx);
		[results addObject:newObject];
	}
	return [results copy];
}

@end
