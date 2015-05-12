//
//  SHPAPIResource.m
//  SHPNetworking
//
//  Created by Kasper Kronborg on 18/11/12.
//  Copyright (c) 2012 SHAPE A/S. All rights reserved.
//

#import "SHPAPIResource.h"
#import "SHPNetworkingErrors.h"
#import "SHPManagedModel.h"
#import "SHPJSONTransformer.h"



@implementation SHPAPIResource
{
    NSMutableArray *_validators;
}

#pragma mark Initializers

- (id)init
{
    if (!(self = [super init])) return nil;

    /* Defaults
     */
    [self setDataTransformer:[[SHPJSONTransformer alloc] init]];

	// default acceptable status code ranges [ <200 - 299> ]
	self.acceptableStatusCodeRanges = @[ [NSValue valueWithRange:NSMakeRange(200, 100)] ];

    return self;
}

#pragma mark Convenience initializers

- (id)initWithPath:(NSString *)path
{
    if (!(self = [self init])) return nil;

    [self setPath:path];

    return self;
}

#pragma mark Validators

- (void)setValidators:(NSArray *)validators
{
    _validators = [NSMutableArray arrayWithArray:validators];
}

- (void)addValidator:(id <SHPValidator>)validator
{
    (_validators && [_validators isKindOfClass:[NSMutableArray class]]) ? [_validators addObject:validator] : [self setValidators:@[validator]];
}

- (NSArray *)validators
{
    return [_validators copy];
}

//- (void)validateObject:(id)object error:(NSError *__autoreleasing *)error
//{
//    __block NSError *validationBlockError = nil;
//
//    [[self.parser validators] enumerateObjectsUsingBlock:^(SHPParserValidator *validator, NSUInteger idx, BOOL *stop) {
//        [validator validateObject:object error:&validationBlockError];
//
//        /* If we have an validation error bail out
//         */
//        if (validationBlockError) {
//            return;
//        }
//    }];
//
//    *error = validationBlockError;
//}

- (id)objectOfClass:(Class)objectClass withKeyPath:(NSString *)keyPath populatedWithObject:(id)object error:(NSError *__autoreleasing *)error
{
    if (!objectClass) {
        return nil;
    }

    if (keyPath) {
        if ([object isKindOfClass:[NSDictionary class]]) {
            object = [object valueForKeyPath:keyPath];
        }
    }

    /* SHPManageModel
     */
    if ([objectClass isSubclassOfClass:[SHPManagedModel class]]) {

        /* A managed model can only be created from a dictionary or from an array containing dictionaries
         */

        /* Dictionary
         */
        if ([object isKindOfClass:[NSDictionary class]]) {
            return [(SHPManagedModel *)[objectClass alloc] initWithDictionary:object];
        }

        /* Array
         */
        if ([object isKindOfClass:[NSArray class]]) {

            /* We check that the array we have in our object is an array nested of dictionaries that we will populate our managed model with.
             */
            NSMutableArray *mDictionaries = [NSMutableArray arrayWithCapacity:[object count]];
            for (id obj in (NSArray *)object) {
                if ([obj isKindOfClass:[NSDictionary class]]) {
                    [mDictionaries addObject:obj];
                }
            }
            NSArray *dictionaries = [mDictionaries copy];

            NSMutableArray *mMappedDictionaries = [NSMutableArray arrayWithCapacity:[dictionaries count]];
            for (id dict in dictionaries) {
                [mMappedDictionaries addObject:[(SHPManagedModel *)[objectClass alloc] initWithDictionary:dict]];
            }
            NSArray *mappedDictionaries = [mMappedDictionaries copy];

            return mappedDictionaries;
        }
    }

    /* NSDictionary
     */
    else if ([objectClass isSubclassOfClass:[NSDictionary class]]) {
        return [[NSDictionary alloc] initWithDictionary:object];
    }
    /* NSArray
     */
    else if ([objectClass isSubclassOfClass:[NSArray class]]) {
        return [[NSArray alloc] initWithArray:object];
    }
    /* NSString
     */
    else if ([objectClass isSubclassOfClass:[NSString class]] && [object isKindOfClass:[NSString class]]) {
        return [[NSString alloc] initWithString:object];
    }
    /* Object is already correct class, so don't give error. E.g. used for NSNumber
     */
    else if ([object isKindOfClass:objectClass]) {
        return object;
    }

    *error = [NSError errorWithDescription:NSLocalizedString(([NSString stringWithFormat:@"Failed to populate model of class '%@' with result of class '%@'", objectClass, [object class]]), nil) code:SHPNetworkingErrorFailedToPopluateModel];

    return nil;
}

- (id)objectOfResultClassPopulatedWithObject:(id)object error:(NSError *__autoreleasing *)error
{
    NSAssert(self.resultObjectClass != nil, @"Must set result object class on SHPAPIResource object");

    return [self objectOfClass:self.resultObjectClass withKeyPath:self.resultKeyPath populatedWithObject:object error:error];
}


- (id)objectOfErrorResultClassPopulatedWithObject:(id)object error:(NSError *__autoreleasing *)error
{
    return [self objectOfClass:self.errorResultObjectClass withKeyPath:self.errorResultKeyPath populatedWithObject:object error:error];
}

@end
