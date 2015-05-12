//
//  Created by Ole Gammelgaard Poulsen on 18/12/12.
//  Copyright (c) 2012 SHAPE A/S. All rights reserved.
//
#import "NSArray+SHPGroupingAdditions.h"


@implementation NSArray (SHPGroupingAdditions)

- (NSArray *)shp_groupByPropertyFromBlock:(id (^)(id))propertyBlock {
	// a dict is used to group the array contents in containers based on the property passed to this method
	NSMutableDictionary *groupedDict = [[NSMutableDictionary alloc] initWithCapacity:[self count]];

	// loop through each object in the array and add to the dict
	// the property is used as the key in the dict
	[self enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
		// the key is the value returned by the property
		id key = propertyBlock(obj);
		NSAssert(key, @"propertyBlock must supply a key");
		// if no entry exists in the dict for that key then set up a mutable array for the key
		if (!groupedDict[key]) {
			groupedDict[key] = [NSMutableArray array];
		}

		// add the object to the dict
		[groupedDict[key] addObject:obj];
	}];

	// create immutable results array
	NSArray *groupedResultArray = [groupedDict allValues];

	return groupedResultArray;
}

- (NSDictionary *)shp_dictionaryGroupedByPropertyFromBlock:(id (^)(id))propertyBlock {
	// a dict is used to group the array contents in containers based on the property passed to this method
	NSMutableDictionary *groupedDict = [[NSMutableDictionary alloc] initWithCapacity:[self count]];

	// loop through each object in the array and add to the dict
	// the property is used as the key in the dict
	[self enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
		// the key is the value returned by the property
		id key = propertyBlock(obj);
		NSAssert(key, @"propertyBlock must supply a key");
		// if no entry exists in the dict for that key then set up a mutable array for the key
		if (!groupedDict[key]) {
			groupedDict[key] = [NSMutableArray array];
		}

		// add the object to the dict
		[groupedDict[key] addObject:obj];
	}];
	return [groupedDict copy];
}

- (NSArray *)shp_arrayByFlattening {
	NSMutableArray *flattenedArray = [NSMutableArray arrayWithCapacity:[self count]];

	for (id obj in self) {
		if ([obj isKindOfClass:[NSArray class]]) {
			[flattenedArray addObjectsFromArray:[(NSArray *) obj shp_arrayByFlattening]];
		} else {
			[flattenedArray addObject:obj];
		}
	}

	return [flattenedArray copy];
}

@end
