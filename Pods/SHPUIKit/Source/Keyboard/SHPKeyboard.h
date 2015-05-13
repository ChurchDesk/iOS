//  Created by Philip Bruce on 27/01/12.
//  Copyright (c) 2012 Shape ApS. All rights reserved.

/**
 Keyboard class which allows you to catch hardware keyboard events in the iPhone Simulator for debugging use

 When enabled by calling the setup method a hidden UITextField is created with an empty UIView as its inputview. This allows for capturing keyboard events from the computer hosting the iPhone Simulator. Most normal keys are currently captured, but not special keys such as modifier keys or the arrow keys.
 
 *Warning*
 
 The library is not complete and therefore won't catch all keyboard events - see above
 
 */


#import <Foundation/Foundation.h>

static NSString *const SHPKeyboardKeyPressedEvent = @"SHPKeyboardEventKeyPressed";

@protocol SHPKeyboardDelegate <NSObject>

@optional
- (void)keyboardKeyPressed:(NSDictionary *)keyDict;
@end

@interface SHPKeyboard : UIResponder <UITextViewDelegate>

@property (strong, nonatomic) UITextView *textField;
@property (weak, nonatomic) id delegate;

+ (SHPKeyboard *)sharedInstance;

/// ---------------------------------------------------------------------
/// @name Setup
/// ---------------------------------------------------------------------

/**
 Calling setup keyboard enables keyboard detection and will continually
 notify the keyboard delegate of keypresses.
 
 @warning *Warning*
 
 Calling this method will continually attempt to take over the keyboard
 and might conflict with other libraries that work similarly (DCIntrospect
 for instance).
 
 @warning *UI interference*
 
 The library will continually try to take over the keyboard and therefore might
 cause uintended side effects for UI views which depend on keyboard appear and
 disappear events to resize themselves. If you are seeing strange behaviour please try
 disabling this library to see if it resolves your problem
 
 */
- (void)setupKeyboard;

@end
