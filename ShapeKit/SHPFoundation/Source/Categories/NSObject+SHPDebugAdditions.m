//
//  Created by Ole Gammelgaard Poulsen on 18/12/12.
//  Copyright (c) 2012 SHAPE A/S. All rights reserved.
//
#import "NSObject+SHPDebugAdditions.h"
#import "SHPUtilities.h"
#import <objc/runtime.h>

@implementation NSObject (SHPDebugAdditions)

- (NSString *)shp_descriptionFromProperties {
	NSMutableString *retString = [NSMutableString string];

	unsigned int propertyCount;
	objc_property_t *properties = class_copyPropertyList([self class], &propertyCount);

	for (int i=0; i<propertyCount; i++) {
		objc_property_t property = properties[i];
		const char *propertyNameCString = property_getName(property);
		NSString *propertyName = [NSString stringWithUTF8String:propertyNameCString];
		NSString *valueString = [self valueForKey:propertyName];

		[retString appendFormat:@"%@: %@, ", propertyName, valueString];


	}
	free(properties);

	return [retString copy];
}


- (NSString *)shp_descriptionFromPropertiesRecursive {
	NSMutableString *retString = [NSMutableString string];

	unsigned int propertyCount;
	objc_property_t *properties = class_copyPropertyList([self class], &propertyCount);

	for (int i=0; i<propertyCount; i++) {
		objc_property_t property = properties[i];
		const char *propertyNameCString = property_getName(property);
		NSString *propertyName = [NSString stringWithUTF8String:propertyNameCString];
		id value = [self valueForKey:propertyName];
		unsigned int subPropertyCount;
		objc_property_t *subProperties = class_copyPropertyList([value class], &subPropertyCount);
		free(subProperties);
		if (subProperties > 0) {
			[retString appendFormat:@"%@: %@, ", propertyName, [value shp_descriptionFromPropertiesRecursive]];
		} else if ([value isKindOfClass:[NSArray class]]) {
			NSArray *array = (NSArray *)value;
			[retString appendFormat:@"%@: [", propertyName];
			[array enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
				[retString appendFormat:@"%@, ", [obj shp_descriptionFromPropertiesRecursive]];
			}];
			[retString appendString:@"],"];
		} else {
			[retString appendFormat:@"%@: %@, ", propertyName, value];
		}
	}
	free(properties);

	return [retString copy];
}

- (BOOL)shp_isNonEmpty {
	if ([self isKindOfClass:[NSNull class]]) {
		return NO;
	} else {
		if ([self isKindOfClass:[NSString class]]) {
			return [(NSString *)self length] > 0;
		} else if ([self isKindOfClass:[NSArray class]]) {
			return [(NSArray *)self count] > 0;
		} else if ([self isKindOfClass:[NSDictionary class]]) {
			return [[(NSDictionary *)self allKeys] count] > 0;
		} else {
			return YES;
		}
	}
}

@end
