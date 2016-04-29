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
#import "CHDPeopleTabBarController.h"
#import <Crashlytics/Crashlytics.h>
#import "CHDCalendarViewController.h"
#import "CHDTImeRecordingViewController.h"
#import "CHDSettingsViewController.h"
#import "SHPSideMenu.h"
#import "UINavigationController+ChurchDesk.h"
#import "SHPUIInjection.h"
#import "CHDLoginViewController.h"
#import "CHDRootViewController.h"
#import "CHDAuthenticationManager.h"
#import "NSUserDefaults+CHDDefaults.h"
#import "SSKeychainQuery.h"
#import "CHDAnalyticsManager.h"
#import "intercom.h"
//#import "ABNotifier.h"

@interface AppDelegate ()

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [Heap setAppId:@"408075929"]; //prod
//    [Heap startDebug];
//    [Heap setAppId:@"43172103"];    //dev
//    [Heap enableVisualizer];
//    [ABNotifier startNotifierWithAPIKey:@"b4c9bc3857f9ef793ce268bde99d9173"
//                        environmentName:ABNotifierAutomaticEnvironment
//                                 useSSL:YES
//                               delegate:self];
#if !DEBUG
    [Crashlytics startWithAPIKey:@"c7c174cb98f78bf0cd7b43db69eb37d1e2a46d11"];
#endif
    [[CHDAnalyticsManager sharedInstance] startGoogleAnalytics];
    [self setupAppearance];

    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.rootViewController = [[CHDRootViewController alloc] initWithPrimaryViewController:[self viewControllerHierarchy] secondaryViewControllerClass:[CHDLoginViewController class]];
    [self.window makeKeyAndVisible];
    // Initialize Intercom
    [Intercom setApiKey:@"ios_sdk-a429632ee85f7de1db11af6debdefc4e4d7dbcad" forAppId:@"ybr6de25"];
#if TARGET_IPHONE_SIMULATOR && DEBUG
    [[DCIntrospect sharedIntrospector] start];
    //[SHPUIInjection enable];
#endif

#if !SCREEN_SHOT_MODE
    [self presentLoginViewControllerWhenNeeded];
#endif
    
    return YES;
}

-(void)applicationDidBecomeActive:(UIApplication *)application{
    //first check if a version update is available
    if ([self needsUpdate]) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"New Version!", @"") message:NSLocalizedString(@"A new version of app is available to download", @"") delegate:self cancelButtonTitle:NSLocalizedString(@"Download", @"") otherButtonTitles:nil];
        [alertView show];
        CHDAuthenticationManager *authenticationManager = [CHDAuthenticationManager sharedInstance];
        [authenticationManager signOut];
    }
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
        builder.panningBehaviour = SHPSideMenuPanningBehaviourNavigationBar;
    }];
    
    CHDDashboardTabBarViewController *dashboardTabBar = [CHDDashboardTabBarViewController dashboardTabBarViewController];
    CHDPeopleTabBarController *peopleTabBar = [CHDPeopleTabBarController peopleTabBarViewController];
    CHDDashboardMessagesViewController *messagesViewController = [[CHDDashboardMessagesViewController new] initWithStyle:CHDMessagesStyleAllMessages];
    messagesViewController.title = NSLocalizedString(@"Messages", @"");
    CHDCalendarViewController *calendarViewController = [CHDCalendarViewController new];
    CHDTImeRecordingViewController  *timeRecordingViewController = [CHDTImeRecordingViewController new];
    CHDSettingsViewController *settingsViewController = [CHDSettingsViewController new];
    
    UINavigationController *dashboardNavigationController = [UINavigationController chd_sideMenuNavigationControllerWithRootViewController:dashboardTabBar];
    UINavigationController *peopleNavigationController = [UINavigationController chd_sideMenuNavigationControllerWithRootViewController:peopleTabBar];
    UINavigationController *messagesNavigationController = [UINavigationController chd_sideMenuNavigationControllerWithRootViewController:messagesViewController];
    UINavigationController *settingsNavigationController = [UINavigationController chd_sideMenuNavigationControllerWithRootViewController:settingsViewController];
    UINavigationController *calendarNavigationController = [UINavigationController chd_sideMenuNavigationControllerWithRootViewController:calendarViewController];
    UINavigationController *timeRecordingNavigationController = [UINavigationController chd_sideMenuNavigationControllerWithRootViewController:timeRecordingViewController];
    
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
    
    //People
    CHDMenuItem *menuItemPeople = [CHDMenuItem new];
    menuItemPeople.title = NSLocalizedString(@"People", @"");
    menuItemPeople.viewController = peopleNavigationController;//dashboardTabBar;
    menuItemPeople.image = kImgMenuPeople;
    
    //Time Recording
    CHDMenuItem *menuItemTimeManagement = [CHDMenuItem new];
    menuItemTimeManagement.title = NSLocalizedString(@"Time Recording", @"");
    menuItemTimeManagement.viewController = timeRecordingNavigationController;
    menuItemTimeManagement.image = kImgMenuTimeRecording;
    
    //Help and Support
    CHDMenuItem *menuItemHelp = [CHDMenuItem new];
    menuItemHelp.title = NSLocalizedString(@"Help and Support", @"");
    menuItemHelp.image = kImgMenuHelp;
    
    //Settings
    CHDMenuItem *menuItemSettings = [CHDMenuItem new];
    menuItemSettings.title = NSLocalizedString(@"Settings", @"");
    menuItemSettings.image = kImgMenuSettings;
    menuItemSettings.viewController = settingsNavigationController;
    
    NSArray *menuItems = @[menuItemDashboard, menuItemMessages, menuItemCalendar, menuItemPeople, menuItemHelp, menuItemSettings];
    
    CHDLeftViewController *leftViewController = [[CHDLeftViewController alloc] initWithMenuItems:menuItems];
    
    sideMenuController.leftViewController = leftViewController;
    [sideMenuController setSelectedViewController:dashboardNavigationController];
    [sideMenuController rac_liftSelector:@selector(setSelectedViewController:closeMenu:) withSignals:[[[RACObserve([CHDAuthenticationManager sharedInstance], userID) skip:1] filter:^BOOL(id value) {
        return value == nil;
    }] mapReplace:dashboardNavigationController], [RACSignal return:@YES], nil];
    
    RACSignal *notificationSignal = [self rac_signalForSelector:@selector(application:didReceiveRemoteNotification:)];
    
    [dashboardTabBar rac_liftSelector:@selector(handleNotificationEventWithUserInfo:) withSignals:[notificationSignal map:^id(RACTuple *tuple) {
        return tuple.second;
    }], nil];
    
    [sideMenuController rac_liftSelector:@selector(setSelectedViewController:closeMenu:) withSignalOfArguments:[notificationSignal mapReplace:RACTuplePack(dashboardNavigationController, @YES)]];
    [leftViewController rac_liftSelector:@selector(setSelectedViewController:) withSignalOfArguments:[notificationSignal mapReplace:RACTuplePack(dashboardNavigationController)]];
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
    
    [[UIButton appearance] setTintColor:[UIColor shpui_colorWithHexValue:0x0c485a]];
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
            NSLog(@"userid %@", authenticationManager.userID);
            if (authenticationManager.userID) {
                [Intercom registerUserWithEmail:authenticationManager.userID];
            }
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

//check for update
-(BOOL) needsUpdate{
    NSDictionary* infoDictionary = [[NSBundle mainBundle] infoDictionary];
    NSURL* url = [NSURL URLWithString:[NSString stringWithFormat:@"https://itunes.apple.com/lookup?id=994071625"]];
    NSData* data = [NSData dataWithContentsOfURL:url];
    if (data) {
    NSDictionary* lookup = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
    
    if ([lookup[@"resultCount"] integerValue] == 1){
        NSString* appStoreVersion = lookup[@"results"][0][@"version"];
        NSString* currentVersion = infoDictionary[@"CFBundleShortVersionString"];
        if ([appStoreVersion floatValue] > [currentVersion floatValue]){
            NSLog(@"Need to update [%@ != %@]", appStoreVersion, currentVersion);
            return YES;
        }
    }
    }
    return NO;
}

#pragma mark - Push messages

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    NSLog(@"We successfully registered for remote notifications.");
    //sending device token to intercom.
    [Intercom setDeviceToken:deviceToken];
    NSString *deviceTokenString = [deviceToken shp_hexStringRepresentation];
    [CHDAuthenticationManager sharedInstance].deviceToken = deviceTokenString;
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error
{
    NSLog(@"We failed to register for push notifications. Error: %@ %@", [error localizedDescription], [NSBundle mainBundle].bundleIdentifier);
    [CHDAuthenticationManager sharedInstance].deviceToken = nil;
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    // For signaling
}

// alert view delegate
- (void)alertView:(UIAlertView *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
        NSString *iTunesLink = @"https://itunes.apple.com/us/app/churchdesk/id994071625?ls=1&mt=8";
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:iTunesLink]];
}
@end
