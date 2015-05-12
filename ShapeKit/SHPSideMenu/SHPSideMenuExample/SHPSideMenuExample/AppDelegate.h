//
//  AppDelegate.h
//  SHPSideMenuExample
//
//  Created by Peter Gammelgaard on 15/04/14.
//  Copyright (c) 2014 Peter Gammelgaard. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SHPSideMenuController.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate, SHPSideMenuControllerDelegate>

@property (strong, nonatomic) UIWindow *window;

@end