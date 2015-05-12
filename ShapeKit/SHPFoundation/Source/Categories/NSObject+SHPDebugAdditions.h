//
//  Created by Ole Gammelgaard Poulsen on 18/12/12.
//  Copyright (c) 2012 SHAPE A/S. All rights reserved.
//
#import <Foundation/Foundation.h>

@interface NSObject (SHPDebugAdditions)

/// Returns a string with the values of the properties. Eg. "age:7, name:Ben"
- (NSString *)shp_descriptionFromProperties;
- (NSString *)shp_descriptionFromPropertiesRecursive;

/// Returns NO for NSNull, empty strings, arrays and dictionaries. Returns YES for other objects.
- (BOOL)shp_isNonEmpty;

@end
