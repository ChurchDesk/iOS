//
//  SHPManagedModel+PropertiesDictionary.m
//  SHPNetworking
//
//  Created by Kasper Kronborg on 21/11/12.
//  Copyright (c) 2012 SHAPE A/S. All rights reserved.
//

#import "SHPManagedModel+PropertiesDictionary.h"

#import "NSString+SHPNetworkingAdditions.h"
#import <objc/runtime.h>



@implementation SHPManagedModel (PropertiesDictionary)

+ (NSArray *)managedModelClassHierarchy
{
    NSArray *arr = @[self];
    Class superClass = [self superclass];
    BOOL isManagedModelClass = [superClass isEqual:[SHPManagedModel class]];
    BOOL isManagedModelSubclass = [superClass isSubclassOfClass:[SHPManagedModel class]];
    if (!isManagedModelClass && isManagedModelSubclass) {
        arr = [arr arrayByAddingObjectsFromArray:[superClass managedModelClassHierarchy]];
    }
    return arr;
}

- (void)setPropertiesWithDictionary:(NSDictionary *)dict
{
    NSArray *managedModelClassHierarchy = [[self class] managedModelClassHierarchy];
    for (NSUInteger classIndex = 0; classIndex < managedModelClassHierarchy.count; classIndex++) {
        Class c = managedModelClassHierarchy[classIndex];
        unsigned int numberOfProperties;
        objc_property_t *properties = class_copyPropertyList(c, &numberOfProperties);

        for (int i = 0; i < numberOfProperties; i++) {

            /* Get the name of the property.
             */
            objc_property_t prop = properties[i];
            NSString *name = [NSString stringWithUTF8String:property_getName(prop)];

            // abort if the name is one of iOS 8's new NSObject properties
            NSArray *excludedProperties = @[@"description", @"debugDescription", @"hash", @"superclass"];
            if ([excludedProperties containsObject:name]) continue;

            id value = nil;

            /* First check we make is to see if the class it self has an alternate key for us to map against
             This way there is a fast way to tell this method which key to use specificly.
             */
            NSString *altKey = [self mapPropertyForPropertyWithName:name];
            if (altKey) {
                value = [dict valueForKey:altKey];
            }

            /* Check if we have a value in our dict with the same name of the property.
             */
            if (!value) {
                value = [dict valueForKey:name];
            }

            /* Get a value from removing the class prefix. eg. productId => id
             */
            if (!value) {
                NSString *className = NSStringFromClass([self class]);
                NSString *unprefixedName = [name stringByReplacingOccurrencesOfString:[className lowercaseString] withString:@""];

                value = [dict objectForKey:[unprefixedName lowercaseString]];
            }

            /* If we found no value for the property key, we'll try and convert it to snake case and see if that will find us anything.
             We make this check as the last attempt to get a value, since this is the most expensive.
             */
            if (!value) {
                value = [dict valueForKey:[name asSnakeCase]];
            }

            /* If we found no value, we try to capitalize the first letter.
             */
            if(!value) {
                NSString *capitalizedName = [name stringByReplacingCharactersInRange:NSMakeRange(0, 1) withString:[[name substringToIndex:1] uppercaseString]];
                value = [dict valueForKey:capitalizedName];
            }

            /* If we have a value for our property, we want to determine the type for our property so we can convert our value to the correct type.
             */
            if (value) {

                /* Try if we have a transformed value
                 */
                id transformedValue = [self transformedValueForPropertyWithName:name value:value];
                if (transformedValue) {
                    value = transformedValue;
                }
                else {
                    char *type = property_copyAttributeValue(prop, "T");

                    /* If we can't determine the type, bail early.
                     */
                    if (!type) {
                        continue;
                    }

                    switch (type[0]) {
                        case '@': // object
                        {
                            Class class = nil;
                            if (strlen(type) >= 3) {
                                char *className = strndup(type + 2, strlen(type) - 3); // stripping type names of @"" so that @"NSString" becomes NSString.
                                class = NSClassFromString([NSString stringWithUTF8String:className]);
                                free(className);
                            }

                            /* Checking for type mismatch and try to compensate
                             */
                            if ([class isSubclassOfClass:[NSString class]] && [value isKindOfClass:[NSNumber class]]) {
                                value = [value stringValue];
                            }
                            else if ([class isSubclassOfClass:[NSNumber class]] && [value isKindOfClass:[NSString class]]) {

                                /* Check if our model class provides a specific number formatter, if this method isn't overridden
                                 we are provided a generic number formatter from this class.
                                 */
                                NSNumberFormatter *numberFormatter = [self numberFormatterForPropertyWithName:name];
                                value = [numberFormatter numberFromString:value];
                            }
                            else if ([class isSubclassOfClass:[NSDate class]] && [value isKindOfClass:[NSString class]]) {

                                /* Check if model class provides a specific date formatter
                                 */
                                NSDateFormatter *dateFormatter = [self dateFormatterForPropertyWithName:name];
                                if (!dateFormatter) {
                                    NSLog(@"Date couldn't be set since no date formatter was provided. Class: %@, Property: %@", [self class], name);
                                }

                                NSString *value_copy = value;
                                value = [dateFormatter dateFromString:value];
                                if (!value) {
                                    NSLog(@"Unable to parse date %@. Class: %@, Property: %@", value_copy, [self class], name);
                                }
                            }
                            else if ([class isSubclassOfClass:[SHPManagedModel class]] && [value isKindOfClass:[NSDictionary class]]) {
                                value = [(SHPManagedModel *)[class alloc] initWithDictionary:value];
                            }
                            else if ([class isSubclassOfClass:[NSArray class]] && [value isKindOfClass:[NSArray class]]) {
                                __block Class nestedItemClass = [self nestedClassForArrayPropertyWithName:name];

                                NSMutableArray *mValues = [NSMutableArray arrayWithCapacity:[(NSArray *)value count]];
                                for (id obj in (NSArray *)value) {
                                    id newValue = obj;

                                    if ([obj isKindOfClass:[NSDictionary class]]) {
                                        nestedItemClass = [self classForArrayObjectWithPropertyName:name objectDictionary:obj] ?: nestedItemClass;
                                        if (nestedItemClass) {
                                            newValue = [(SHPManagedModel *)[nestedItemClass alloc] initWithDictionary:obj];
                                        }
                                    }

                                    [mValues addObject:newValue];
                                };

                                value = [mValues copy];
                            }

                            break;
                        }
                        case 'i': // int
                        case 's': // short
                        case 'l': // long
                        case 'q': // long long
                        case 'I': // unsigned int
                        case 'S': // unsigned short
                        case 'L': // unsigned long
                        case 'Q': // unsigned long long
                        case 'f': // float
                        case 'd': // double
                        case 'B': // A C++ bool or a C99 _Bool
                        {
                            value = [self valueForNumberTypeWithValue:value propertyName:name];
                            break;
                        }
                        case 'c': // BOOL or char
                        case 'C': // unsigned char
                        {
                            value = [self valueForCharTypeWithValue:value propertyName:name];
                            break;
                        }
                        default:
                        {
                            value = nil;

                            break;
                        }
                    }
                    free(type);
                }

                if (value && ![value isKindOfClass:[NSNull class]]) {
                    [self setValue:value forKey:name];
                }
            }
        }
        free(properties);
    };

}

#pragma mark - Subclass methods

- (NSString *)mapPropertyForPropertyWithName:(NSString *)propName
{
    return nil;
}

- (NSNumberFormatter *)numberFormatterForPropertyWithName:(NSString *)propName
{
    /* We provide a generic number formatter out of the box.
     */
    NSNumberFormatter *numberFormatter = [self englishUsNumberFormatter];
    return numberFormatter;
}

- (NSNumberFormatter *)englishUsNumberFormatter {
    static NSNumberFormatter *_sharedFormatter = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedFormatter = [[NSNumberFormatter alloc] init];
        [_sharedFormatter setNumberStyle:NSNumberFormatterDecimalStyle];
        [_sharedFormatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US"]];
    });

    return _sharedFormatter;
}

- (NSDateFormatter *)dateFormatterForPropertyWithName:(NSString *)propName
{
    return nil;
}

- (Class)nestedClassForArrayPropertyWithName:(NSString *)propName
{
    return nil;
}

- (Class)classForArrayObjectWithPropertyName:(NSString *)propName objectDictionary:(NSDictionary *)dict {
    return nil;
}

- (id)transformedValueForPropertyWithName:(NSString *)propName value:(id)value
{
    return nil;
}


#pragma mark - Helpers

- (id)valueForNumberTypeWithValue:(id)value propertyName:name
{
    if ([value isKindOfClass:[NSNumber class]]) {
        return value;
    }

    if ([value isKindOfClass:[NSString class]]) {
        NSNumberFormatter *numberFormatter = [self englishUsNumberFormatter];
        return [numberFormatter numberFromString:value];
    }

    NSLog(@"The value '%@' with class '%@' couldn't be assigned as a number type. Class: %@, Property: %@", value, [value class], [self class], name);

    return nil;
}

- (id)valueForCharTypeWithValue:(id)value propertyName:name
{
    if ([value isKindOfClass:[NSNumber class]]) {
        return value;
    }

    if ([value isKindOfClass:[NSString class]]) {
        NSAssert([(NSString*)value length] == 1, @"%@: Illegal value \"%@\". Expecting type of char or BOOL", [self class], value);
        char firstChar = [value characterAtIndex:0];
        return [NSNumber numberWithChar:firstChar];
    }

    NSLog(@"The value '%@' with class '%@' couldn't be assigned as a char type. Class: %@, Property: %@", value, [value class], [self class], name);

    return nil;
}

@end
