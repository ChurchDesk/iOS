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
#import "SHPSideMenu.h"
#import "UINavigationController+ChurchDesk.h"
#import "SHPUIInjection.h"
#import "CHDLoginViewController.h"
#import "CHDRootViewController.h"
#import "CHDAuthenticationManager.h"
#import "NSUserDefaults+CHDDefaults.h"

@interface AppDelegate ()

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {

#if !DEBUG
    [Crashlytics startWithAPIKey:@"c7c174cb98f78bf0cd7b43db69eb37d1e2a46d11"];
#endif
    
    [self setupAppearance];
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.rootViewController = [[CHDRootViewController alloc] initWithPrimaryViewController:[self viewControllerHierarchy] secondaryViewControllerClass:[CHDLoginViewController class]];
    [self.window makeKeyAndVisible];

#if TARGET_IPHONE_SIMULATOR && DEBUG
    [[DCIntrospect sharedIntrospector] start];
    [SHPUIInjection enable];
#endif

#if !SCREEN_SHOT_MODE
    [self presentLoginViewControllerWhenNeeded];
#endif
    
    return YES;
}

- (UIViewController*) viewControllerHierarchy {
    
#if SCREEN_SHOT_MODE
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
    UIViewController *viewController = [UIViewController new];
    viewController.view.backgroundColor = [UIColor chd_lightGreyColor];
    [viewController.view addSubview: [[UINavigationBar alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 64)]];
    return viewController;
#else
    
    SHPSideMenuController *sideMenuController = [SHPSideMenuController sideMenuControllerWithBuilder:^(SHPSideMenuControllerBuilder *builder) {
        builder.statusBarBehaviour = SHPSideMenuStatusBarBehaviourMove;
        builder.panningBehaviour = SHPSideMenuPanningBehaviourFullView; //SHPSideMenuPanningBehaviourOff;
        // More customizations
    }];
    
    CHDDashboardTabBarViewController *dashboardTabBar = [CHDDashboardTabBarViewController dashboardTabBarViewController];
    CHDDashboardMessagesViewController *messagesViewController = [[CHDDashboardMessagesViewController new] initWithStyle:CHDMessagesStyleAllMessages];
    messagesViewController.title = NSLocalizedString(@"Messages", @"");
    CHDCalendarViewController *calendarViewController = [CHDCalendarViewController new];
    CHDSettingsViewController *settingsViewController = [CHDSettingsViewController new];
    
    UINavigationController *dashboardNavigationController = [UINavigationController chd_sideMenuNavigationControllerWithRootViewController:dashboardTabBar];
    UINavigationController *messagesNavigationController = [UINavigationController chd_sideMenuNavigationControllerWithRootViewController:messagesViewController];
    UINavigationController *settingsNavigationController = [UINavigationController chd_sideMenuNavigationControllerWithRootViewController:settingsViewController];
    UINavigationController *calendarNavigationController = [UINavigationController chd_sideMenuNavigationControllerWithRootViewController:calendarViewController];
    
    //Setup the Left Menu
    //Dashboard
    CHDMenuItem *menuItemDashboard = [CHDMenuItem new];
    menuItemDashboard.title = NSLocalizedString(@"Dashboard", @"");
    menuItemDashboard.viewController = dashboardNavigationController;//dashboardTabBar;
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
    [sideMenuController setSelectedViewController:dashboardNavigationController];
    
    [sideMenuController rac_liftSelector:@selector(setSelectedViewController:closeMenu:) withSignals:[[[RACObserve([CHDAuthenticationManager sharedInstance], userID) skip:1] filter:^BOOL(id value) {
        return value == nil;
    }] mapReplace:dashboardNavigationController], [RACSignal return:@YES], nil];
    
    return sideMenuController;
    
#endif
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

    [UINavigationBar appearance].backIndicatorImage = kImgBackArrow;
    [UINavigationBar appearance].backIndicatorTransitionMaskImage = kImgBackArrow;
    
    [[UISwitch appearance] setOnTintColor:[UIColor chd_blueColor]];
    [[UISwitch appearance] setTintColor:[UIColor shpui_colorWithHexValue:0xc8c7cc]];
}

- (void) presentLoginViewControllerWhenNeeded {
    CHDRootViewController *rootVC = (CHDRootViewController*)self.window.rootViewController;
    CHDAuthenticationManager *authenticationManager = [CHDAuthenticationManager sharedInstance];
    
    __block BOOL animated = authenticationManager.userID != nil; // user is logged in initially. Next presentation is animated
    
    [rootVC rac_liftSelector:@selector(presentSecondaryViewControllerAnimated:completion:) withSignals:[[[RACObserve(authenticationManager, userID) distinctUntilChanged] filter:^BOOL(NSString *token) {
        return token == nil;
    }] flattenMap:^RACStream *(id value) {
        return [RACSignal return:@(animated)];
    }], [RACSignal return:^(BOOL finished) {
        if (animated) {
            NSLog(@"Replacing view controller hierarchy");
            rootVC.primaryViewController = [self viewControllerHierarchy];
        }
        animated = YES;
    }], nil];
    
    [rootVC rac_liftSelector:@selector(dismissSecondaryViewControllerAnimated:completion:) withSignals:[[[RACObserve(authenticationManager, userID) distinctUntilChanged] filter:^BOOL(NSString *token) {
        return token != nil;
    }] mapReplace:@YES], [RACSignal return:nil], nil];
    
    [rootVC rac_liftSelector:@selector(dismissViewControllerAnimated:completion:) withSignals:[[[RACObserve(authenticationManager, userID) distinctUntilChanged] filter:^BOOL(NSString *token) {
        return token == nil;
    }] mapReplace:@NO], [RACSignal return:nil], nil];


    [[NSUserDefaults standardUserDefaults] shprac_liftSelector:@selector(chdClearDefaults) withSignal:[[RACObserve(authenticationManager, userID) distinctUntilChanged] filter:^BOOL(NSString *token) {
        return token == nil;
    }]];
}

#pragma mark - Push messages

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    NSLog(@"We successfully registered for remote notifications.");
    
    NSString *deviceTokenString = [deviceToken shp_hexStringRepresentation];
    
    [CHDAuthenticationManager sharedInstance].deviceToken = deviceTokenString;
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error
{
    NSLog(@"We failed to register for push notifications. Error: %@ %@", [error localizedDescription], [NSBundle mainBundle].bundleIdentifier);
    [CHDAuthenticationManager sharedInstance].deviceToken = nil;
}


@end
