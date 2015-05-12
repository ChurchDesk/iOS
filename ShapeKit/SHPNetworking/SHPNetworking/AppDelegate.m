//
//  AppDelegate.m
//  SHPNetworking
//
//  Created by Kasper Kronborg on 17/11/12.
//  Copyright (c) 2012 SHAPE A/S. All rights reserved.
//

#import "AppDelegate.h"

//
//  API
//
#import "SoundCloudAPI.h"
#import "FitnessWorldAPI.h"
#import "News.h"
#import "SHPHTTPResponse.h"


@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    
    [[SoundCloudAPI sharedInstance] setBaseURL:[NSURL URLWithString:@"https://api.soundcloud.com"]];
    [[SoundCloudAPI sharedInstance] setClientId:@"e12f5797c0720d447290140641d3a241"];
    [[SoundCloudAPI sharedInstance] setClientSecret:@"cb8cf2819363f527f7e4b76ad8effd2b"];

    [[SoundCloudAPI sharedInstance] getUserWithId:16440135 completion:^(SHPHTTPResponse *response, NSError *error) {

        SoundCloudUser *user = response.result;

        if (error) {
            NSLog(@"Error getting user: %@ \n\n Body: %@", error, response.body);
            return;
        }

        NSLog(@"User: %@ \n\n Body: %@", user.username, response.body);
    }];

    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
