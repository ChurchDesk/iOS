//
//  CHDAbstractViewController.m
//  ChurchDesk
//
//  Created by Mikkel Selsøe Sørensen on 25/02/15.
//  Copyright (c) 2015 Shape A/S. All rights reserved.
//

#import "CHDAbstractViewController.h"
#import "CHDDashboardTabBarViewController.h"

@interface CHDAbstractViewController ()

@end

@implementation CHDAbstractViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
 
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
}

@end
