//
//  AppDelegate.m
//  SHPFoundation
//
//  Created by Kasper Kronborg on 10/11/12.
//  Copyright (c) 2012 SHAPE A/S. All rights reserved.
//

#import "AppDelegate.h"
#import "SHPUtilities.h"


@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // ----------------
    // Window
    // ----------------
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.rootViewController = [UIViewController new];
    [self.window makeKeyAndVisible];

    // ----------------
    // Various tests
    // ----------------

    return YES;
}


@end
