//
//  CHDEventInfoViewController.m
//  ChurchDesk
//
//  Created by Mikkel Selsøe Sørensen on 26/02/15.
//  Copyright (c) 2015 Shape A/S. All rights reserved.
//

#import "CHDEventInfoViewController.h"
#import "CHDEventInfoViewModel.h"
#import "CHDEventInfoTableViewCell.h"
#import "CHDEventGroupTableViewCell.h"
#import "CHDEventLocationTableViewCell.h"
#import "CHDDividerTableViewCell.h"

@interface CHDEventInfoViewController () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) CHDEventInfoViewModel *viewModel;

@end

@implementation CHDEventInfoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.viewModel = [[CHDEventInfoViewModel alloc] initWithEventId:@2];
    
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

- (void) setupBindings {
    [self.tableView shprac_liftSelector:@selector(reloadData) withSignal:RACObserve(self.viewModel, event)];
}

#pragma mark - UITableViewDelegate

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.viewModel.sections.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.viewModel rowsForSection:self.viewModel.sections[section]].count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSArray *sections = self.viewModel.sections;
    NSString *section = sections[indexPath.section];
    NSArray *rows = [self.viewModel rowsForSection:section];
    NSString *row = rows[indexPath.row];
    
    if ([row isEqualToString:CHDEventInfoRowGroup]) {
        CHDEventGroupTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"group" forIndexPath:indexPath];
        cell.titleLabel.text = @"Group name";
        cell.groupLabel.text = @"Parish";
        return cell;
    }
    if ([row isEqualToString:CHDEventInfoRowDate]) {
        CHDEventInfoTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
        cell.iconImageView.image = kImgEventTime;
        cell.titleLabel.text = @"Date and time";
        return cell;
    }
    if ([row isEqualToString:CHDEventInfoRowLocation]) {
        CHDEventLocationTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"location" forIndexPath:indexPath];
        cell.titleLabel.text = @"Vor Frue Kirke";
        return cell;
    }
    if ([section isEqualToString:CHDEventInfoSectionDivider]) {
        return [tableView dequeueReusableCellWithIdentifier:@"divider" forIndexPath:indexPath];
    }
    
    else {
        CHDEventInfoTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
        cell.titleLabel.text = row;
        return cell;
    }
}

#pragma mark - Lazy Initialization

- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [UITableView new];
        _tableView.dataSource = self;
        _tableView.delegate = self;
        _tableView.rowHeight = UITableViewAutomaticDimension;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;

        [_tableView registerClass:[CHDEventInfoTableViewCell class] forCellReuseIdentifier:@"cell"];
        [_tableView registerClass:[CHDEventGroupTableViewCell class] forCellReuseIdentifier:@"group"];
        [_tableView registerClass:[CHDEventLocationTableViewCell class] forCellReuseIdentifier:@"location"];
        [_tableView registerClass:[CHDDividerTableViewCell class] forCellReuseIdentifier:@"divider"];
    }
    return _tableView;
}


@end
