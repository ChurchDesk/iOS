//
//  SHPBlockValidator.m
//  SHPNetworking
//
//  Created by Kasper Kronborg on 03/01/13.
//  Copyright (c) 2013 SHAPE A/S. All rights reserved.
//

#import "SHPBlockValidator.h"



@implementation SHPBlockValidator
{
    SHPBlockValidatorValidationBlock _block;
}

#pragma mark Convenience initalizers

+ (id)validatorWithValidationBlock:(SHPBlockValidatorValidationBlock)block
{
    return [[SHPBlockValidator alloc] initWithValidationBlock:block];
}

- (id)initWithValidationBlock:(SHPBlockValidatorValidationBlock)block
{
    if (!(self = [super init])) return nil;
    
    _block = block;
    
    return self;
}

#pragma mark SHPValidator implementation

- (BOOL)validate:(id)input error:(NSError *__autoreleasing *)error
{
    NSAssert(_block, @"SHPBlockValidator has to have a block specified");
    
    return _block(input, error);
}

@end
