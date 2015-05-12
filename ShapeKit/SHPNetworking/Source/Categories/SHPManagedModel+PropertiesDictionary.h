//
//  SHPManagedModel+PropertiesDictionary.h
//  SHPNetworking
//
//  Created by Kasper Kronborg on 21/11/12.
//  Copyright (c) 2012 SHAPE A/S. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "SHPManagedModel.h"



@interface SHPManagedModel (PropertiesDictionary)

- (void)setPropertiesWithDictionary:(NSDictionary *)dict;

- (NSString *)mapPropertyForPropertyWithName:(NSString *)propName;
- (NSNumberFormatter *)numberFormatterForPropertyWithName:(NSString *)propName;
- (NSDateFormatter *)dateFormatterForPropertyWithName:(NSString *)propName;
- (Class)nestedClassForArrayPropertyWithName:(NSString *)propName;
- (Class)classForArrayObjectWithPropertyName:(NSString *)propName objectDictionary:(NSDictionary *)dict;
- (id)transformedValueForPropertyWithName:(NSString *)propName value:(id)value;

@end

