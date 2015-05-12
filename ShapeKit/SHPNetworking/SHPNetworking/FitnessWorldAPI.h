//
// Created by kronborg on 08/01/13.
//


#import <Foundation/Foundation.h>


@interface FitnessWorldAPI : SHPAPI
- (void)getNewsWithCompletion:(SHPAPIManagerResourceCompletionBlock)completion;
@end