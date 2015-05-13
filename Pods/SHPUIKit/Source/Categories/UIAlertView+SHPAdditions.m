//
//  UIAlertView+SHPAdditions.m
//  iOSApp
//
//  Created by Vadim Shpakovski on 11/1/10.
//  Copyright 2010 __CO__. All rights reserved.
//

#import "UIAlertView+SHPAdditions.h"

@interface AlertViewDelegate : NSObject <UIAlertViewDelegate>
{
    void (^_cancelHandler)();
    void (^_defaultHandler)();
    BOOL _hasCancelButton;
    BOOL _hasDefaultButton;
}

@property (nonatomic, copy) void (^cancelHandler)();
@property (nonatomic, copy) void (^defaultHandler)();

@property (nonatomic, assign) BOOL hasCancelButton;
@property (nonatomic, assign) BOOL hasDefaultButton;

@end

#pragma mark -

@implementation UIAlertView (SHPAdditions)

+ (void)shpui_showWithTitle:(NSString *)title message:(NSString *)message cancelButtonTitle:(NSString *)cancelButtonTitle cancelHandler:(void (^)())cancelHandler defaultButtonTitle:(NSString *)defaultButtonTitle defaultHandler:(void (^)())defaultHandler
{
    // Verify that an alert is valid
    BOOL hasCancelButton = cancelButtonTitle != nil;
    BOOL hasDefaultButton = defaultButtonTitle != nil;
    if (!hasCancelButton && !hasDefaultButton) return;

    // Make a container for user handlers
    static AlertViewDelegate *alertViewDelegate = nil;
    alertViewDelegate = [[AlertViewDelegate alloc] init];
    alertViewDelegate.cancelHandler = cancelHandler;
    alertViewDelegate.defaultHandler = defaultHandler;
    alertViewDelegate.hasCancelButton = hasCancelButton;
    alertViewDelegate.hasDefaultButton = hasDefaultButton;

    // Display alert view
    static UIAlertView *alertView = nil;
    alertView = [[UIAlertView alloc] initWithTitle:title message:message delegate:alertViewDelegate cancelButtonTitle:cancelButtonTitle otherButtonTitles:defaultButtonTitle, nil];
    [alertView show];
}

@end

#pragma mark -

@implementation AlertViewDelegate

@synthesize cancelHandler = _cancelHandler;
@synthesize defaultHandler = _defaultHandler;

@synthesize hasCancelButton = _hasCancelButton;
@synthesize hasDefaultButton = _hasDefaultButton;

#pragma mark -


#pragma mark -
#pragma mark UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    // Find which button has been clicked
    BOOL isCancelClicked = (self.hasCancelButton && (buttonIndex == 0));

    // Call alert handler corresponding to the clicked button
    void (^alertHandler)() = isCancelClicked ? self.cancelHandler : self.defaultHandler;
    if (alertHandler) alertHandler();

    // Perform cleanup

}

@end
