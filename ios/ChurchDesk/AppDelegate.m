//
//  AppDelegate.m
//  ChurchDesk
//
//  Created by Jakob Vinther-Larsen on 16/02/15.
//  Copyright (c) 2015 Shape A/S. All rights reserved.
//


#import "AppDelegate.h"
#import "CHDLeftViewController.h"
#import "CHDDashboardTabBarViewController.h"
#import "DCIntrospect.h"
#import "CHDMenuItem.h"
#import "CHDDashboardMessagesViewController.h"
#import <Crashlytics/Crashlytics.h>
#import "CHDCalendarViewController.h"
#import "CHDSettingsViewController.h"

@interface AppDelegate ()

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {

    [Crashlytics startWithAPIKey:@"c7c174cb98f78bf0cd7b43db69eb37d1e2a46d11"];
    
    [self setupAppearance];

    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];

    SHPSideMenuController *sideMenuController = [SHPSideMenuController sideMenuControllerWithBuilder:^(SHPSideMenuControllerBuilder *builder) {
        builder.statusBarBehaviour = SHPSideMenuStatusBarBehaviourMove;
        builder.panningBehaviour = SHPSideMenuPanningBehaviourFullView; //SHPSideMenuPanningBehaviourOff;
        // More customizations
    }];


    CHDDashboardTabBarViewController *dashboardTabBar = [CHDDashboardTabBarViewController dashboardTabBarViewController];
    
    CHDDashboardMessagesViewController *messagesViewController = [CHDDashboardMessagesViewController new];
    messagesViewController.title = NSLocalizedString(@"Messages", @"");

    CHDSettingsViewController *settingsViewController = [CHDSettingsViewController new];

    UINavigationController *messagesNavigationController = [[UINavigationController new] initWithRootViewController:messagesViewController];
    UINavigationController *settingsNavigationController = [[UINavigationController new] initWithRootViewController:settingsViewController];

    CHDCalendarViewController *calendarViewController = [CHDCalendarViewController new];
    UINavigationController *calendarNavigationController = [[UINavigationController new] initWithRootViewController:calendarViewController];
    
    //Setup the Left Menu
    //Dashboard
    CHDMenuItem *menuItemDashboard = [CHDMenuItem new];
    menuItemDashboard.title = NSLocalizedString(@"Dashboard", @"");
    menuItemDashboard.viewController = dashboardTabBar;
    menuItemDashboard.image = kImgMenuDashboard;

    //Messages
    CHDMenuItem *menuItemMessages = [CHDMenuItem new];
    menuItemMessages.title = NSLocalizedString(@"Messages", @"");
    menuItemMessages.viewController = messagesNavigationController;
    menuItemMessages.image = kImgMenuMail;
    
    //Calendar
    CHDMenuItem *menuItemCalendar = [CHDMenuItem new];
    menuItemCalendar.title = NSLocalizedString(@"Calendar", @"");
    menuItemCalendar.viewController = calendarNavigationController;
    menuItemCalendar.image = kImgMenuEvent;

    //Settings
    CHDMenuItem *menuItemSettings = [CHDMenuItem new];
    menuItemSettings.title = NSLocalizedString(@"Settings", @"");
    menuItemSettings.image = kImgMenuSettings;
    menuItemSettings.viewController = settingsNavigationController;

    NSArray *menuItems = @[menuItemDashboard, menuItemMessages, menuItemCalendar, menuItemSettings];

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
    [[UINavigationBar appearance] setTranslucent:NO];
    [[UIBarButtonItem appearance] setTitleTextAttributes:@{NSFontAttributeName : [UIFont chd_fontWithFontWeight:CHDFontWeightRegular size:18], NSForegroundColorAttributeName : [UIColor whiteColor]} forState:UIControlStateNormal];

    [[UITabBar appearance] setBarTintColor:[UIColor shpui_colorWithHexValue:0x008db6]];
    [[UITabBarItem appearance] setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor shpui_colorWithHexValue:0x434343]} forState:UIControlStateNormal];
    [[UITabBarItem appearance] setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor]} forState:UIControlStateSelected];

    //[[UIBarButtonItem appearance] setImage:kImgBackArrow];
    //[[UIBarButtonItem appearance] setTitle:@""];

    [[UISwitch appearance] setOnTintColor:[UIColor chd_blueColor]];
    [[UISwitch appearance] setTintColor:[UIColor shpui_colorWithHexValue:0xc8c7cc]];
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
