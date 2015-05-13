//
//  Created by Philip Bruce on 20/10/14.
//  Copyright (c) 2014 SHAPE A/S. All rights reserved.
//

#import "NSArray+SHPArrayFunctional.h"

@implementation NSSet (SHPSetFunctional)

- (NSSet *)shp_map:(id (^)(id obj))block {
    NSMutableSet *resultSet = [NSMutableSet setWithCapacity:[self count]];
    for (id element in self) {
        [resultSet addObject:block(element)];
    }

    return [resultSet copy];
}

- (NSSet *)shp_filter:(BOOL (^)(id obj))block {
    NSMutableSet *resultSet = [NSMutableSet setWithCapacity:[self count]];
    for (id element in self) {
        if (block(element)) { [resultSet addObject:element]; }
    }

    return [resultSet copy];
}

- (id)shp_reduce:(id)initialValue combine:(id (^)(id currentReduction, id currentElement))block {
    id currentReduction = initialValue;

    for (id element in self) {
        currentReduction = block(currentReduction, element);
    }

    return currentReduction;
}

@end
