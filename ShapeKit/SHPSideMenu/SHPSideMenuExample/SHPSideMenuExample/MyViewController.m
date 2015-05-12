//
//  Created by Peter Gammelgaard on 29/04/14.
//  Copyright (c) 2013 SHAPE A/S. All rights reserved.
//

#import "MyViewController.h"
#import "SHPSideMenuController.h"
#import "View+MASAdditions.h"
#import "MySecondViewController.h"


@interface MyViewController () <UITableViewDataSource>
@end

@implementation MyViewController {

}

- (void)viewDidLoad {
    [super viewDidLoad];

    UITableView *tableView = [[UITableView alloc] initWithFrame:self.view.frame style:UITableViewStylePlain];
    [tableView setAutoresizingMask:UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleTopMargin];
    [tableView setDataSource:self];
    [tableView setDelegate:self];
    [tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"CellIdentifier"];
    [self.view addSubview:tableView];

    [tableView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];

}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    NSLog(@"MyViewcontroller View Will appear");
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

    NSLog(@"MyViewcontroller View did appear");
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];

    NSLog(@"MyViewcontroller View will disappear");
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];

    NSLog(@"MyViewcontroller View did disappear");
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 20;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CellIdentifier" forIndexPath:indexPath];

    cell.textLabel.text = @"cell";

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
//    MySecondViewController *viewController = [MySecondViewController new];
//    [self.navigationController pushViewController:viewController animated:YES];
}


@end