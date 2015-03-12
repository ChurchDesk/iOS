//
//  CHDDashboardEventsViewController.m
//  ChurchDesk
//
//  Created by Jakob Vinther-Larsen on 17/02/15.
//  Copyright (c) 2015 Shape A/S. All rights reserved.
//

#import "CHDDashboardEventsViewController.h"
#import "CHDTableViewCell.h"
#import "CHDEventTableViewCell.h"
#import "CHDExpandableButtonView.h"
#import "CHDNewMessageViewController.h"
#import "CHDDashboardEventViewModel.h"
#import "CHDEvent.h"
#import "CHDSite.h"
#import "CHDUser.h"
#import "CHDEventCategory.h"
#import "CHDEnvironment.h"
#import "CHDEventInfoViewController.h"
#import "CHDEditEventViewController.h"

@interface CHDDashboardEventsViewController ()  <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, retain) UITableView* eventTable;
@property (nonatomic, strong) CHDExpandableButtonView *actionButtonView;

@property (nonatomic, strong) CHDDashboardEventViewModel *viewModel;
@end

@implementation CHDDashboardEventsViewController

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.title = NSLocalizedString(@"Dashboard", @"");
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
    return self;
}

#pragma mark - setup views

-(void) makeViews {
    [self.view addSubview:self.eventTable];
    [self.view addSubview:self.actionButtonView];
}

-(void) makeConstraints {
    UIView* superview = self.view;
    [self.eventTable mas_makeConstraints:^(MASConstraintMaker *make){
        make.edges.equalTo(superview);
    }];
    
    [self.actionButtonView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(superview);
        make.bottom.equalTo(superview).offset(-5);
    }];
}

-(void) makeBindings {

    //Setup target action
    [self.actionButtonView.addMessageButton addTarget:self action:@selector(newMessageShow) forControlEvents:UIControlEventTouchUpInside];
    [self.actionButtonView.addEventButton addTarget:self action:@selector(newEventAction:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.eventTable shprac_liftSelector:@selector(reloadData) withSignal:[RACSignal merge: @[RACObserve(self.viewModel, events), RACObserve(self.viewModel, user), RACObserve(self.viewModel, environment)]]];
}

#pragma mark - View methods
- (void)viewDidLoad {
    [super viewDidLoad];

    self.viewModel = [CHDDashboardEventViewModel new];

    [self makeViews];
    [self makeConstraints];
    [self makeBindings];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.eventTable deselectRowAtIndexPath:[self.eventTable indexPathForSelectedRow] animated:animated];
}

- (void) newMessageShow {
    CHDNewMessageViewController* newMessageViewController = [CHDNewMessageViewController new];
    UINavigationController *navigationVC = [[UINavigationController new] initWithRootViewController:newMessageViewController];
    [self presentViewController:navigationVC animated:YES completion:nil];
}

- (void) newEventAction: (id) sender {
    CHDEditEventViewController *vc = [[CHDEditEventViewController alloc] initWithEvent:nil];
    UINavigationController *navigationVC = [[UINavigationController new] initWithRootViewController:vc];
    [self presentViewController:navigationVC animated:YES completion:nil];
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    CHDEvent* event = self.viewModel.events[indexPath.row];
    
    CHDEventInfoViewController *vc = [[CHDEventInfoViewController alloc] initWithEvent:event];
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.viewModel.events? self.viewModel.events.count: 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    static NSString* cellIdentifier = @"dashboardCell";
    CHDEvent* event = self.viewModel.events[indexPath.row];
    CHDUser* user = self.viewModel.user;
    CHDSite* site = [user siteWithId:event.siteId];
    CHDEnvironment *environment = self.viewModel.environment;

    //Get the first eventCategory
    CHDEventCategory *category = (event.eventCategoryIds && event.eventCategoryIds.count > 0)?[environment eventCategoryWithId: event.eventCategoryIds[0]] : nil;

    CHDEventTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    cell.titleLabel.text = event.title;
    cell.locationLabel.text = event.location;
    cell.parishLabel.text = site.name;
    cell.dateTimeLabel.text = [self.viewModel formattedTimeForEvent:event];

    [cell.leftBorder setBackgroundColor:category.color?: [UIColor clearColor]];

    return cell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

#pragma mark - Lazy Initialization

-(UITableView*)eventTable {
    if(!_eventTable){
        _eventTable = [[UITableView alloc] init];
        _eventTable.separatorStyle = UITableViewCellSeparatorStyleNone;
        _eventTable.backgroundView.backgroundColor = [UIColor chd_lightGreyColor];
        _eventTable.backgroundColor = [UIColor chd_lightGreyColor];
        _eventTable.rowHeight = 65;
        [_eventTable registerClass:[CHDEventTableViewCell class] forCellReuseIdentifier:@"dashboardCell"];
        _eventTable.dataSource = self;
        _eventTable.delegate = self;
    }
    return _eventTable;
}


- (CHDExpandableButtonView *)actionButtonView {
    if (!_actionButtonView) {
        _actionButtonView = [CHDExpandableButtonView new];
    }
    return _actionButtonView;
}

@end
