//
//  Created by Philip Bruce on 20/10/14.
//  Copyright (c) 2014 SHAPE A/S. All rights reserved.
//

#import "NSArray+SHPArrayFunctional.h"

@implementation NSArray (SHPArrayFunctional)

- (NSArray *)shp_map:(id (^)(id obj))block {
    NSMutableArray *resultArray = [NSMutableArray arrayWithCapacity:[self count]];
    for (id element in self) {
        [resultArray addObject:block(element)];
    }

    return [resultArray copy];
}

- (NSArray *)shp_mapWithIndex:(id (^)(id obj, NSUInteger index))block {
    NSMutableArray *resultArray = [NSMutableArray arrayWithCapacity:[self count]];
    NSUInteger index = 0;
    for (id element in self) {
        [resultArray addObject:block(element, index)];
        index++;
    }

    return [resultArray copy];
}

- (NSArray *)shp_filter:(BOOL (^)(id obj))block {
    NSMutableArray *resultArray = [NSMutableArray arrayWithCapacity:[self count]];
    for (id element in self) {
        if (block(element)) { [resultArray addObject:element]; }
    }

    return [resultArray copy];
}

- (NSArray *)shp_filterWithIndex:(BOOL (^)(id obj, NSUInteger index))block {
    NSMutableArray *resultArray = [NSMutableArray arrayWithCapacity:[self count]];
    NSUInteger index = 0;
    for (id element in self) {
        if (block(element, index)) { [resultArray addObject:element]; }
        index++;
    }

    return [resultArray copy];
}

- (id)shp_detect:(BOOL (^)(id obj))block {
    for (id element in self) {
        if (block(element)) { return element; }
    }

    return nil;
}

- (id)shp_reduce:(id)initialValue combine:(id (^)(id currentReduction, id currentElement))block {
    id currentReduction = initialValue;

    for (id element in self) {
        currentReduction = block(currentReduction, element);
    }

    return currentReduction;
}

- (BOOL)shp_any:(BOOL (^)(id obj))block {
    return ([self shp_detect:block] != nil);
}

@end
