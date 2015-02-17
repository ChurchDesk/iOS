//
//  CHDDashboardInvitationsViewController.m
//  ChurchDesk
//
//  Created by Jakob Vinther-Larsen on 17/02/15.
//  Copyright (c) 2015 Shape A/S. All rights reserved.
//

#import "CHDDashboardInvitationsViewController.h"

@interface CHDDashboardInvitationsViewController ()

@end

@implementation CHDDashboardInvitationsViewController

- (instancetype)init
{
  self = [super init];
  if (self) {
    self.title = NSLocalizedString(@"Invitations", @"");
    
     UIBarButtonItem *sideMenuItem = [[UIBarButtonItem alloc] initWithTitle:@"Menu" style:UIBarButtonItemStylePlain target:self action:@selector(touched)];
    self.navigationItem.leftBarButtonItem = sideMenuItem;
  }
  return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    UIColor *color = [UIColor greenColor];
    self.view.backgroundColor = color;
}

- (void) viewWillAppear:(BOOL)animated{
  [super viewWillAppear:animated];
}

- (void)touched {
  NSLog(@"Touched bar button");
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
