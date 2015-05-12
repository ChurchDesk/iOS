//
// Created by Casper Storm Larsen on 05/09/14.
// SHAPE A/S
//


#import <Foundation/Foundation.h>

@class RACSignal;

@interface NSObject (SHPRACLiftingAdditions)

- (RACSignal *)shprac_liftSelector:(SEL)selector withSignal:(RACSignal *)signal;

@end