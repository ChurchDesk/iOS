//
//  SHPBlockValidator.h
//  SHPNetworking
//
//  Created by Kasper Kronborg on 03/01/13.
//  Copyright (c) 2013 SHAPE A/S. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SHPValidator.h"



typedef BOOL(^SHPBlockValidatorValidationBlock)(id input, NSError *__autoreleasing *error);

@interface SHPBlockValidator : NSObject <SHPValidator>
+ (id)validatorWithValidationBlock:(SHPBlockValidatorValidationBlock)block;
- (id)initWithValidationBlock:(SHPBlockValidatorValidationBlock)block;
@end