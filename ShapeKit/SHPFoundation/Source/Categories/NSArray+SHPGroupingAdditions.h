//
//  Created by Ole Gammelgaard Poulsen on 18/12/12.
//  Copyright (c) 2012 SHAPE A/S. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSArray (SHPGroupingAdditions)

/// ---------------------------------------------------------------------
/// @name Grouping objects in the array
/// ---------------------------------------------------------------------

/// Groups the array by some property on the object in the array
///
/// The block should return the property that the objects should be grouped by.
- (NSArray *)shp_groupByPropertyFromBlock:(id (^)(id))propertyBlock;

/// Groups the array by some property on the object in the array
///
/// The block should return the property that the objects should be grouped by.
/// This is a variant of groupByPropertyFromBlock that returns a dict instead of an array.
- (NSDictionary *)shp_dictionaryGroupedByPropertyFromBlock:(id (^)(id))propertyBlock;

/// ---------------------------------------------------------------------
/// @name Flattening the array hierarchy
/// ---------------------------------------------------------------------

/// Flattens the array hierarchy so that any nested arrays will have their objects included in the outer array
- (NSArray *)shp_arrayByFlattening;

@end
