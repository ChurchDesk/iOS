//
//  CHDDashboardNavigationController.m
//  ChurchDesk
//
//  Created by Jakob Vinther-Larsen on 17/02/15.
//  Copyright (c) 2015 Shape A/S. All rights reserved.
//

#import "CHDDashboardNavigationController.h"
#import "SHPSideMenuController.h"

@interface CHDDashboardNavigationController ()

@end

@implementation CHDDashboardNavigationController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    UIColor *color = [UIColor greenColor];
    self.view.backgroundColor = color;

    [self.navigationBar setTranslucent:NO];
}

@end
