//
//  Keyboard.m
//  Keyboard
//
//  Created by Philip Bruce on 27/01/12.
//  Copyright (c) 2012 Shape ApS. All rights reserved.
//

#import "SHPKeyboard.h"
#import "UIDevice+SystemAdditions.h"

@interface _SHPKeyboardTextView : UITextView
@end

@protocol _SHPKeyboardTextViewDelegate
- (void)keyPressed:(UIKeyCommand *)keyCommand;
@end

@implementation _SHPKeyboardTextView {
}

- (void)keyboardPressed:(UIKeyCommand *)keyCommand  {
    if (self.delegate && [self.delegate respondsToSelector:@selector(keyPressed:)]) {
        id<_SHPKeyboardTextViewDelegate> keyboardDelegate = (id <_SHPKeyboardTextViewDelegate>) self.delegate;
        [keyboardDelegate keyPressed:keyCommand];
    }
}

- (NSArray *)keyCommands {
    NSArray *inputs = @[@"1",@"2",@"3",@"4",@"5",@"6",@"7",@"8",@"9",@"0",
            @"q",@"w",@"e",@"r",@"t",@"y",@"u",@"i",@"o",@"p",@"å",
            @"a",@"s",@"d",@"f",@"g",@"h",@"j",@"k",@"l",@"æ",@"ø",
            @"z",@"x",@"c",@"v",@"b",@"n",@"m",
            @",",@".",@"/",@"\\",@"\n",@" ",@"\t",@"!",@"?",@"_",@"-",
            UIKeyInputUpArrow,UIKeyInputDownArrow,UIKeyInputLeftArrow,UIKeyInputRightArrow,UIKeyInputEscape];

    NSMutableArray *mCommands = [NSMutableArray arrayWithCapacity:[inputs count]];
    for (NSUInteger i = 0; i < [inputs count]; i++) {
        NSString *input = inputs[i];
        [mCommands addObject:[UIKeyCommand keyCommandWithInput:input modifierFlags:0 action:@selector(keyboardPressed:)]];
    }
    NSArray *commands = [mCommands copy];

    return commands;
}

@end

@interface SHPKeyboard()

@property (assign, nonatomic) BOOL selectionDetectionEnabled;

- (void)resetTextFieldContent;

@end

@implementation SHPKeyboard

+ (SHPKeyboard *)sharedInstance {
    static SHPKeyboard *sharedInstance = nil;
    static dispatch_once_t pred;

    if (sharedInstance) return sharedInstance;

    dispatch_once(&pred, ^{
        sharedInstance = [SHPKeyboard alloc];
        sharedInstance = [sharedInstance init];
    });

    return sharedInstance;
}

- (void)setupKeyboard {
    _textField = [[_SHPKeyboardTextView alloc] init];
    _textField.inputView = [[UIView alloc] init];
    _textField.delegate = self;
    [self resetTextFieldContent];

    UIWindow *w = [[[UIApplication sharedApplication] windows] objectAtIndex:0];
    [w insertSubview:_textField atIndex:0];
    [_textField becomeFirstResponder];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidHide:) name:UIKeyboardDidHideNotification object:nil];
}

- (void)resetTextFieldContent {
    _textField.text = @"1 24 ";
    _selectionDetectionEnabled = NO;
    [_textField setSelectedRange:NSMakeRange(2, 0)];
    _selectionDetectionEnabled = YES;
}

#pragma mark - Text Field delegate

- (void)keyboardDidHide:(NSNotification *)note {
    double delayInSeconds = 0.5;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [_textField becomeFirstResponder];
    });
}

- (void)notifyDelegateWithDict:(NSDictionary *)keyDict {
    if ([self.delegate respondsToSelector:@selector(keyboardKeyPressed:)]) {
        [self.delegate keyboardKeyPressed:keyDict];
    }
	[[NSNotificationCenter defaultCenter] postNotificationName:SHPKeyboardKeyPressedEvent object:nil userInfo:keyDict];
}

- (void)textViewDidChangeSelection:(UITextView *)textView {
    if (_selectionDetectionEnabled) {
        [self resetTextFieldContent];
    }
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    [self resetTextFieldContent];

    if([[UIDevice currentDevice] shpui_hasSystemVersionLessThan:@"7.0"]) {
        NSDictionary *keyDict = [NSDictionary dictionaryWithObjectsAndKeys:text, @"key", nil];
		[self notifyDelegateWithDict:keyDict];
	}

    return NO;
}

- (void)keyPressed:(UIKeyCommand *)keyCommand {
    NSDictionary *keyDict = [NSDictionary dictionaryWithObjectsAndKeys:keyCommand.input, @"key", nil];
	[self notifyDelegateWithDict:keyDict];
}



@end
