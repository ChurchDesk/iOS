//
//  NSObject+SHPDelegation.h
//  Keyboard
//
//  Created by Philip Bruce on 02/02/12.
//  Copyright (c) 2012 Shape ApS. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSObject(SHPDelegation)

/// ---------------------------------------------------------------------
/// @name Delegation
/// ---------------------------------------------------------------------

/**
 Perform a delegation method only if there is a delegate and if it responds to the method

 Provides a single call which checks if a delegate is set and whether it responds to the
 selector before trying to call it.

 @warning *Warning*

 It is assumed that the delegate can be accessed through a property called delegate
*/
- (void)shp_performDelegateSelector:(SEL)selector withObject:(id)object __deprecated_msg("This method has been deprecated as it was too tightly couped with a 'delegate' property. Use 'shp_performSelectorIfPresent...' instead");


/**
 Same as - (void)performDelegateSelector:(SEL)selector withObject:(id)object, but takes
 an additional object parameter to be sent to the delegate
*/
- (void)shp_performDelegateSelector:(SEL)selector withObject:(id)object1 withObject:(id)object2 __deprecated_msg("This method has been deprecated as it was too tightly couped with a 'delegate' property. Use 'shp_performSelectorIfPresent...' instead");

/**
* Performs the given selector if it's present on the object, otherwise fails using SHPAssert
*
* Uses self and selector together with a supplied protocol and message prefix to form a nice assertion message
* There are two variants depending on whether the selector has a return value
*/
- (void)shp_performSelectorIfPresent:(SEL)selector withObject:(id)object1 withObject:(id)object2 fromProtocol:(Protocol *)protocol failWithAssertionMessagePrefix:(NSString *)messagePrefix;
- (id)shp_performSelectorWithReturnValueIfPresent:(SEL)selector withObject:(id)object1 withObject:(id)object2 fromProtocol:(Protocol *)protocol failWithAssertionMessagePrefix:(NSString *)messagePrefix;

/**
* Performs the given selector if it's present on the object, otherwise just disregards the selector. Returns a BOOL to indicate whether selector was performed
* There are two variants depending on whether the selector has a return value
* */
- (void)shp_performSelectorIfPresent:(SEL)selector withObject:(id)object1 withObject:(id)object2;
- (id)shp_performSelectorWithReturnValueIfPresent:(SEL)selector withObject:(id)object1 withObject:(id)object2;

@end
