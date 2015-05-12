//
//  NSObject+SHPDelegation.m
//  Keyboard
//
//  Created by Philip Bruce on 02/02/12.
//  Copyright (c) 2012 Shape ApS. All rights reserved.
//

#import "NSObject+SHPDelegation.h"
#import "SHPUtilities.h"

@implementation NSObject(SHPDelegation)

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"

- (void)shp_performDelegateSelector:(SEL)selector withObject:(id)object {
    id receiver = self;
    if ([receiver delegate] && [[receiver delegate] respondsToSelector:selector]) {
        [[receiver delegate] performSelector:selector withObject:object];
    }
}

- (void)shp_performDelegateSelector:(SEL)selector withObject:(id)object1 withObject:(id)object2 {
    id receiver = self;
    if ([receiver delegate] && [[receiver delegate] respondsToSelector:selector]) {
        [[receiver delegate] performSelector:selector withObject:object1 withObject:object2];
    }
}

- (void)shp_performSelectorIfPresent:(SEL)selector withObject:(id)object1 withObject:(id)object2 fromProtocol:(Protocol *)protocol failWithAssertionMessagePrefix:(NSString *)messagePrefix {
    if ([self respondsToSelector:selector]) {
        if (object1 == nil && object2 == nil) {
            [self performSelector:selector];
        } else if (object2 == nil) {
            [self performSelector:selector withObject:object1];
        } else if (object1 != nil) {
            [self performSelector:selector withObject:object1 withObject:object2];
        } else {
            SHPAssert(NO, @"[SHPFoundation] You cannot supply object2 and not object1");
        }
    } else {
        SHPAssert(NO, @"%@ '%@' should implement '%@' from protocol '%@'", messagePrefix, NSStringFromClass([self class]), NSStringFromSelector(selector), NSStringFromProtocol(protocol));
    }
}

- (void)shp_performSelectorIfPresent:(SEL)selector withObject:(id)object1 withObject:(id)object2 {
    if ([self respondsToSelector:selector]) {
        if (object1 == nil && object2 == nil) {
            [self performSelector:selector];
        } else if (object2 == nil) {
            [self performSelector:selector withObject:object1];
        } else if (object1 != nil) {
            [self performSelector:selector withObject:object1 withObject:object2];
        } else {
            SHPAssert(NO, @"[SHPFoundation] You cannot supply object2 and not object1");
        }
    }
}

- (id)shp_performSelectorWithReturnValueIfPresent:(SEL)selector withObject:(id)object1 withObject:(id)object2 fromProtocol:(Protocol *)protocol failWithAssertionMessagePrefix:(NSString *)messagePrefix {
    id result;
    if ([self respondsToSelector:selector]) {
        if (object1 == nil && object2 == nil) {
            result = [self performSelector:selector];
        } else if (object2 == nil) {
            result = [self performSelector:selector withObject:object1];
        } else if (object1 != nil) {
            result = [self performSelector:selector withObject:object1 withObject:object2];
        } else {
            SHPAssert(NO, @"[SHPFoundation] You cannot supply object2 and not object1");
        }
    } else {
        SHPAssert(NO, @"%@ '%@' should implement '%@' from protocol '%@'", messagePrefix, NSStringFromClass([self class]), NSStringFromSelector(selector), NSStringFromProtocol(protocol));
    }
    return result;
}

- (id)shp_performSelectorWithReturnValueIfPresent:(SEL)selector withObject:(id)object1 withObject:(id)object2 {
    id result;
    if ([self respondsToSelector:selector]) {
        if (object1 == nil && object2 == nil) {
            result = [self performSelector:selector];
        } else if (object2 == nil) {
            result = [self performSelector:selector withObject:object1];
        } else if (object1 != nil) {
            result = [self performSelector:selector withObject:object1 withObject:object2];
        } else {
            SHPAssert(NO, @"[SHPFoundation] You cannot supply object2 and not object1");
        }
    }

    return result;
}

#pragma clang diagnostic pop

@end
