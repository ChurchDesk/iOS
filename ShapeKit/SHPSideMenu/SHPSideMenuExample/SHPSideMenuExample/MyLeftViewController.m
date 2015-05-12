//
//  Created by Peter Gammelgaard on 29/04/14.
//  Copyright (c) 2013 SHAPE A/S. All rights reserved.
//

#import <SHPSideMenu/SHPSideMenuController.h>
#import "MyLeftViewController.h"
#import "MySecondViewController.h"

@interface MyLeftViewController () <UITableViewDataSource>
@end

@implementation MyLeftViewController {

}

- (void)viewDidLoad {
    [super viewDidLoad];

    UIButton *button1 = [[UIButton alloc] initWithFrame:CGRectMake(20, 40, 80, 40)];
    [button1 setTitle:@"Button1" forState:UIControlStateNormal];
    [button1 addTarget:self action:@selector(didPressButton1) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button1];

    UIButton *button2 = [[UIButton alloc] initWithFrame:CGRectMake(20, 80, 80, 40)];
    [button2 setTitle:@"Button2" forState:UIControlStateNormal];
    [button2 addTarget:self action:@selector(didPressButton2) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button2];
}

- (void)didPressButton1 {
    [self.shp_sideMenuController setSelectedIndex:0 closeMenu:YES];
}

- (void)didPressButton2 {
    MySecondViewController *viewController = [MySecondViewController new];
    [self presentViewController:viewController animated:YES completion:nil];
//    [self.shp_sideMenuController setSelectedIndex:1 closeMenu:YES];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 20;
}

@end