//
//  Created by Peter Gammelgaard on 21/08/14.
//  Copyright (c) 2013 SHAPE A/S. All rights reserved.
//

#import "NSObject+RACDescription.h"
#import "NSInvocation+RACTypeParsing.h"
#import "RACEXTScope.h"

@implementation NSObject (SHPRACLiftingAdditions)

- (RACSignal *)shprac_liftSelector:(SEL)selector withSignal:(RACSignal *)signal {
    NSCParameterAssert(selector != NULL);
    NSCParameterAssert(signal != nil);
    
    NSMethodSignature *methodSignature = [self methodSignatureForSelector:selector];
    NSAssert(methodSignature != nil, @"%@ does not respond to %@", self, NSStringFromSelector(selector));
    
    NSUInteger numberOfArguments = methodSignature.numberOfArguments - 2;
    NSAssert(numberOfArguments <= 1, @"Selector should take one or zero arguments");
    
    @unsafeify(self);
    
    return [[[[signal takeUntil:self.rac_willDeallocSignal] map:^(id argument) {
        @strongify(self);
        
        NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:methodSignature];
        invocation.selector = selector;
        if (numberOfArguments > 0) {
            invocation.rac_argumentsTuple = RACTuplePack(argument);
        }
        [invocation invokeWithTarget:self];
        
        return invocation.rac_returnValue;
    }] replayLast] setNameWithFormat:@"%@ -shp_liftSelector: %s withSignal: %@", [self rac_description], sel_getName(selector), signal];
}

@end