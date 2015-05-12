//
//  UIAlertView+SHPAdditions.h
//  iOSApp
//
//  Created by Vadim Shpakovski on 11/1/10.
//  Copyright 2010 __CO__. All rights reserved.
//

@interface UIAlertView (SHPAdditions)

+ (void)shpui_showWithTitle:(NSString *)title message:(NSString *)message cancelButtonTitle:(NSString *)cancelButtonTitle cancelHandler:(void (^)())cancelHandler defaultButtonTitle:(NSString *)defaultButtonTitle defaultHandler:(void (^)())defaultHandler;

@end
