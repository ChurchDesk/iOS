//
//  CHDDashboardTabBarViewController.m
//  ChurchDesk
//
//  Created by Jakob Vinther-Larsen on 17/02/15.
//  Copyright (c) 2015 Shape A/S. All rights reserved.
//

#import "CHDDashboardTabBarViewController.h"
#import "CHDDashboardEventsViewController.h"
#import "CHDDashboardInvitationsViewController.h"
#import "CHDDashboardNavigationController.h"
#import "CHDDashboardMessagesViewController.h"

@interface CHDDashboardTabBarViewController ()

@end

@implementation CHDDashboardTabBarViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    UIColor *color = [UIColor redColor];
    self.view.backgroundColor = color;

    CHDDashboardEventsViewController *dashboardEventsViewController = [CHDDashboardEventsViewController new];
    CHDDashboardInvitationsViewController *dashboardInvitationsViewController = [CHDDashboardInvitationsViewController new];
    CHDDashboardMessagesViewController *dashboardMessagesViewController = [CHDDashboardMessagesViewController new];

    CHDDashboardNavigationController *eventsNavViewController = [[CHDDashboardNavigationController new] initWithRootViewController:dashboardEventsViewController];
    CHDDashboardNavigationController *invitationsNavViewController = [[CHDDashboardNavigationController new] initWithRootViewController:dashboardInvitationsViewController];
    CHDDashboardNavigationController *messagesNavViewController = [[CHDDashboardNavigationController new] initWithRootViewController:dashboardMessagesViewController];

    NSArray *viewControllersArray = [NSArray arrayWithObjects:eventsNavViewController, invitationsNavViewController, messagesNavViewController, nil];

    [self setViewControllers:viewControllersArray animated:NO];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
