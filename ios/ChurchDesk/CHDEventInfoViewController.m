//
//  CHDEventInfoViewController.m
//  ChurchDesk
//
//  Created by Mikkel Selsøe Sørensen on 26/02/15.
//  Copyright (c) 2015 Shape A/S. All rights reserved.
//

#import "CHDEventInfoViewController.h"
#import "CHDEventInfoViewModel.h"

@interface CHDEventInfoViewController () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) UITableView *tableView;

@end

@implementation CHDEventInfoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupSubviews];
    [self makeConstraints];
}

- (void) setupSubviews {
    [self.view addSubview:self.tableView];
}

- (void) makeConstraints {
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
}

#pragma mark - UITableViewDelegate

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    return nil;
}

#pragma mark - Lazy Initialization

- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [UITableView new];
        _tableView.dataSource = self;
        _tableView.delegate = self;
    }
    return _tableView;
}


@end
