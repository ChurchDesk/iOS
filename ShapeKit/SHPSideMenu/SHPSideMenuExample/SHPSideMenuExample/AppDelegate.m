//
//  AppDelegate.m
//  SHPSideMenuExample
//
//  Created by Peter Gammelgaard on 15/04/14.
//  Copyright (c) 2014 Peter Gammelgaard. All rights reserved.
//

#import "AppDelegate.h"
#import "SHPSideMenuController.h"
#import "MyViewController.h"
#import "MyLeftViewController.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];


    MyViewController *viewController1 = [MyViewController new];
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:viewController1];

    UIViewController *viewController2 = [UIViewController new];

    MyLeftViewController *leftViewController = [MyLeftViewController new];

    SHPSideMenuController *sideMenuController = [SHPSideMenuController sideMenuControllerWithBuilder:^(SHPSideMenuControllerBuilder *builder) {
        builder.statusBarBehaviour = SHPSideMenuStatusBarBehaviourMove;
    }];

    sideMenuController.viewControllers = @[navigationController, viewController2];
    sideMenuController.leftViewController = leftViewController;

    [viewController1.view setBackgroundColor:[UIColor whiteColor]];
    [viewController2.view setBackgroundColor:[UIColor greenColor]];
    [leftViewController.view setBackgroundColor:[UIColor blueColor]];

    self.window.rootViewController = sideMenuController;

    return YES;
}



@end