//  Created by Philip Bruce on 21/02/11.
//  Copyright 2011 Shape ApS. All rights reserved.

/**
 Timer class which makes handling NSTimer instances easier.
 
 Normally when using NSTimers you have to keep a reference to it in an ivar so that you can stop and remove it again at some later point. This class solves the problem by keeping the references to timers for you. Instead you refer to timers using a unique tag which is just an NSString
 
 SHPTimer is a singleton class and reached through the sharedInstance method.
*/

#import <Foundation/Foundation.h>

@interface SHPTimer : NSObject {

}

/// ---------------------------------------------------------------------
/// @name Adding and removing timers
/// ---------------------------------------------------------------------

/**
 Adds a timer with a specified interval, target and selector. You pass in a unique tag which you can later use to remove the timer. You also specify whether the timer should repeat or not.
*/
- (void)addTimerWithTag:(NSString *)tag interval:(NSTimeInterval)interval target:(id)target selector:(SEL)selector repeats:(BOOL)repeats;

/**
 Removes a timer previously added by passing in the unique identifier of the timer.
*/
- (void)removeTimerWithTag:(NSString *)tag;

/// ---------------------------------------------------------------------
/// @name Getting the singleton instance
/// ---------------------------------------------------------------------

+ (SHPTimer *)sharedInstance;

@end
