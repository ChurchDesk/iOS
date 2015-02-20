//
//  AppDelegate.m
//  ChurchDesk
//
//  Created by Jakob Vinther-Larsen on 16/02/15.
//  Copyright (c) 2015 Shape A/S. All rights reserved.
//


#import "AppDelegate.h"
#import "SHPSideMenu.h"
#import "CHDLeftViewController.h"
#import "CHDDashboardTabBarViewController.h"
#import "DCIntrospect.h"
#import "CHDMenuItem.h"
#import "CHDDashboardMessagesViewController.h"
#import <Crashlytics/Crashlytics.h>

@interface AppDelegate ()

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {

    [Crashlytics startWithAPIKey:@"c7c174cb98f78bf0cd7b43db69eb37d1e2a46d11"];
    
    [self setupAppearance];

    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];

    SHPSideMenuController *sideMenuController = [SHPSideMenuController sideMenuControllerWithBuilder:^(SHPSideMenuControllerBuilder *builder) {
        builder.statusBarBehaviour = SHPSideMenuStatusBarBehaviourMove;
        // More customizations
    }];


    CHDDashboardTabBarViewController *dashboardTabBar = [CHDDashboardTabBarViewController dashboardTabBarViewController];
    CHDDashboardMessagesViewController *messagesViewController = [CHDDashboardMessagesViewController new];
    messagesViewController.title = NSLocalizedString(@"Messages", @"");

    UINavigationController *messagesNavigationController = [[UINavigationController new] initWithRootViewController:messagesViewController];

    //Setup the Left Menu
    //Dashboard
    CHDMenuItem *menuItemDashboard = [CHDMenuItem new];
    menuItemDashboard.title = NSLocalizedString(@"Dashboard", @"");
    menuItemDashboard.viewController = dashboardTabBar;
    menuItemDashboard.image = kImgDashboard;

    //Messages
    CHDMenuItem *menuItemMessages = [CHDMenuItem new];
    menuItemMessages.title = NSLocalizedString(@"Messages", @"");
    menuItemMessages.viewController = messagesNavigationController;
    menuItemMessages.image = kImgMessagesSideMenuIcon;


    NSArray *menuItems = @[menuItemDashboard, menuItemMessages];

    CHDLeftViewController *leftViewController = [[CHDLeftViewController alloc] initWithMenuItems:menuItems];

    sideMenuController.leftViewController = leftViewController;
    [sideMenuController setSelectedViewController:dashboardTabBar];

    self.window.rootViewController = sideMenuController;

    [self.window makeKeyAndVisible];

#if DEBUG
    [[DCIntrospect sharedIntrospector] start];
#endif

    return YES;
}

- (void) setupAppearance {
    [[UINavigationBar appearance] setTintColor:[UIColor whiteColor]];
    [[UINavigationBar appearance] setBarTintColor:[UIColor chd_blueColor]];
    [[UINavigationBar appearance] setTitleTextAttributes:@{NSFontAttributeName : [UIFont chd_fontWithFontWeight:CHDFontWeightRegular size:18], NSForegroundColorAttributeName : [UIColor whiteColor]}];
    [[UIBarButtonItem appearance] setTitleTextAttributes:@{NSFontAttributeName : [UIFont chd_fontWithFontWeight:CHDFontWeightRegular size:18], NSForegroundColorAttributeName : [UIColor whiteColor]} forState:UIControlStateNormal];

    [[UITabBar appearance] setBarTintColor:[UIColor shpui_colorWithHexValue:0x008db6]];
    [[UITabBarItem appearance] setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor shpui_colorWithHexValue:0x434343]} forState:UIControlStateNormal];
    [[UITabBarItem appearance] setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor]} forState:UIControlStateSelected];
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.

}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.

}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


@end