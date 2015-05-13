//
//  CHDEventUserDetailsViewController.m
//  ChurchDesk
//
//  Created by Mikkel Selsøe Sørensen on 26/03/15.
//  Copyright (c) 2015 Shape A/S. All rights reserved.
//

#import "CHDEventUserDetailsViewController.h"
#import "CHDUserAttendanceTableViewCell.h"
#import "CHDEvent.h"
#import "Haneke.h"
#import "CHDEventUserDetailsViewModel.h"

@interface CHDEventUserDetailsViewController () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) CHDEvent *event;
@property (nonatomic, strong) CHDEventUserDetailsViewModel *viewModel;

@end

@implementation CHDEventUserDetailsViewController

- (instancetype)initWithEvent: (CHDEvent*) event {
    self = [super init];
    if (self) {
        _event = event;
        self.viewModel = [CHDEventUserDetailsViewModel new];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.backgroundColor = [UIColor chd_lightGreyColor];
    self.title = NSLocalizedString(@"Users booked", @"");
    
    [self setupSubviews];
    [self makeConstraints];
    [self setupBindings];
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
    [self.tableView shprac_liftSelector:@selector(reloadData) withSignal:RACObserve(self.viewModel, environment)];
}

#pragma mark - UITableViewDelegate

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.event.userIds.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    CHDUserAttendanceTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    
    NSNumber *userId = self.event.userIds[indexPath.row];
    CHDPeerUser *user = [self.viewModel.environment userWithId:userId siteId:self.event.siteId];
    
    [cell layoutIfNeeded];
    [cell.userImageView hnk_setImageFromURL:user.pictureURL placeholder:nil];
    cell.nameLabel.text = user.name;
    cell.status = [self.event attendanceStatusForUserWithId:userId];
    cell.topLineHidden = indexPath.row > 0;
    cell.bottomLineFull = [tableView numberOfRowsInSection:indexPath.section]-1 == indexPath.row;
    
    return cell;
}

#pragma mark - Lazy Initialization

- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [UITableView new];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.contentInset = UIEdgeInsetsMake(35, 0, 35, 0);
        
        [_tableView registerClass:[CHDUserAttendanceTableViewCell class] forCellReuseIdentifier:@"cell"];
    }
    return _tableView;
}

@end
