//
//  Created by Philip Bruce on 20/10/14.
//  Copyright (c) 2014 SHAPE A/S. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSSet (SHPSetFunctional)
/// ---------------------------------------------------------------------
/// @name Manipulate sets
/// ---------------------------------------------------------------------

/// Returns a new set with the values returned from invoking the block on the passed array.
- (NSSet *)shp_map:(id (^)(id obj))block;

/// ---------------------------------------------------------------------
/// @name Filtering sets
/// ---------------------------------------------------------------------

/// Returns a new array with all the elements for which the block returns YES.
- (NSSet *)shp_filter:(BOOL (^)(id obj))block;

/// ---------------------------------------------------------------------
/// @name Extracting information from an sets
/// ---------------------------------------------------------------------

///  Derrive a single object by iterating over a set. This could for example be used to sum all the elements of a set.
- (id)shp_reduce:(id)initialValue combine:(id (^)(id currentReduction, id currentElement))block;

@end
