//
//  Created by Philip Bruce on 20/10/14.
//  Copyright (c) 2014 SHAPE A/S. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSArray (SHPArrayFunctional)
/// ---------------------------------------------------------------------
/// @name Manipulate arrays
/// ---------------------------------------------------------------------

/// Returns a new array with the values returned from invoking the block on the passed array.
- (NSArray *)shp_map:(id (^)(id obj))block;

/// Returns a new array with the values returned from invoking the block on the passed array. Differs from map by including the index of the object.
- (NSArray *)shp_mapWithIndex:(id (^)(id obj, NSUInteger index))block;

/// ---------------------------------------------------------------------
/// @name Filtering arrays
/// ---------------------------------------------------------------------

/// Returns a new array with all the elements for which the block returns YES.
- (NSArray *)shp_filter:(BOOL (^)(id obj))block;

/// Returns a new array with all the elements for which the block returns YES. Differs from filter by including the index of the object.
- (NSArray *)shp_filterWithIndex:(BOOL (^)(id obj, NSUInteger index))block;

/// Returns the first element satisfying the block, or nil if no element satisfies.
- (id)shp_detect:(BOOL (^)(id obj))block;

/// ---------------------------------------------------------------------
/// @name Extracting information from an array
/// ---------------------------------------------------------------------

///  Derrive a single object by iterating over an array. This could for example be used to sum all the elements of an array.
- (id)shp_reduce:(id)initialValue combine:(id (^)(id currentReduction, id currentElement))block;

/// ---------------------------------------------------------------------
/// @name Querying arrays
/// ---------------------------------------------------------------------

/// Check if any elements return true
- (BOOL)shp_any:(BOOL (^)(id obj))block;

@end
