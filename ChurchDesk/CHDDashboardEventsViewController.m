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
#import "UIViewController+UIViewController_ChurchDesk.h"
#import "CHDAnalyticsManager.h"
#import "MBProgressHUD.h"

@interface CHDDashboardEventsViewController ()  <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, retain) UITableView* eventTable;
@property(nonatomic, strong) UILabel *emptyMessageLabel;
@property (nonatomic, strong) CHDDashboardEventViewModel *viewModel;
@property(nonatomic, strong) UIRefreshControl *refreshControl;
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
    [self.eventTable addSubview:self.refreshControl];
    [self setupAddButton];
}

-(void) makeConstraints {
    UIView* superview = self.view;
    [self.eventTable mas_makeConstraints:^(MASConstraintMaker *make){
        make.edges.equalTo(superview);
    }];
}

-(void) makeBindings {
    RACSignal *newEventsSignal = RACObserve(self.viewModel, events);
    [self.eventTable shprac_liftSelector:@selector(reloadData) withSignal:[RACSignal merge: @[newEventsSignal, RACObserve(self.viewModel, user), RACObserve(self.viewModel, environment)]]];
    [self rac_liftSelector:@selector(emptyMessageShow:) withSignals:[RACObserve(self.viewModel, events) map:^id(NSArray *events) {
        if(events == nil){
            return @NO;
        }
        return @(events.count == 0);
    }], nil];

    [self shprac_liftSelector:@selector(endRefresh) withSignal:newEventsSignal];

    [self shprac_liftSelector:@selector(showProgress:) withSignal:[[self rac_signalForSelector:@selector(viewWillDisappear:)] map:^id(id value) {
        return @NO;
    }]];
}

#pragma mark - CHDNotificationEventResponder

- (BOOL)canHandleEventWithUserInfo:(NSDictionary *)userInfo {
    NSDictionary *content = userInfo[@"aps"][@"alert"][@"identifier"];
    return [content[@"type"] isEqualToString:@"bookingUpdate"] || [content[@"type"] isEqualToString:@"bookingCanceled"];
}

- (void)handleEventWithUserInfo:(NSDictionary *)userInfo {
    NSDictionary *content = userInfo[@"aps"][@"alert"][@"identifier"];
    if ([content[@"type"] isEqualToString:@"bookingUpdate"] || [content[@"type"] isEqualToString:@"bookingCanceled"]) {
        CHDEventInfoViewController *vc = [[CHDEventInfoViewController alloc] initWithEventId:content[@"id"] siteId:content[@"site"]];
        [self.navigationController pushViewController:vc animated:YES];
    }
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
    [[CHDAnalyticsManager sharedInstance] trackVisitToScreen:@"dashboard_events"];
    [self.eventTable deselectRowAtIndexPath:[self.eventTable indexPathForSelectedRow] animated:YES];
    NSDate *timestamp = [[NSUserDefaults standardUserDefaults] valueForKey:keventsTimestamp];
    NSDate *currentTime = [NSDate date];
    NSTimeInterval timeDifference = [currentTime timeIntervalSinceDate:timestamp];
    if (timeDifference/60 > 10 || [[NSUserDefaults standardUserDefaults] boolForKey:kSavedEventBool]) {
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:kSavedEventBool];
        [self.viewModel reload];
    }
    NSLog(@"timestamp %@ currentTime %@ time difference %f", timestamp, currentTime, timeDifference);
    [self shprac_liftSelector:@selector(showProgress:) withSignal:[[RACObserve(self.viewModel, events) map:^id(id value) {
        return @(value == nil);
    }] takeUntil:[self rac_signalForSelector:@selector(viewWillDisappear:)]]];
    
}

-(void)viewDidAppear:(BOOL)animated {
    
    [super viewDidAppear:animated];
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    CHDEvent* event = self.viewModel.events[indexPath.row];
    CHDEventInfoViewController *vc = [[CHDEventInfoViewController alloc] initWithEvent:event];
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - UITableViewDataSource
- (void)refresh:(UIRefreshControl *)refreshControl {
    [self.viewModel reload];
}

-(void)endRefresh {
    [self.refreshControl endRefreshing];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.viewModel.events? self.viewModel.events.count: 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    static NSString* cellIdentifier = @"dashboardCell";
    CHDEvent* event = self.viewModel.events[indexPath.row];
    CHDUser* user = self.viewModel.user;
    CHDSite* site = [user siteWithId:event.siteId];
    
    CHDEventTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    cell.locationLabel.text = event.location;
    if ([event.type isEqualToString:kAbsence]) {
        cell.titleLabel.text = [NSString stringWithFormat:@"    %@", event.title];
        cell.titleLabel.textColor = [UIColor grayColor];
        cell.absenceIconView.hidden = false;
    }
    else{
        cell.titleLabel.text = event.title;
        cell.titleLabel.textColor = [UIColor chd_textDarkColor];
        cell.absenceIconView.hidden = true;
    }
    cell.parishLabel.text = user.sites.count > 1? site.name : @"";
    cell.dateTimeLabel.text = [self.viewModel formattedTimeForEvent:event];

    if ([event.type isEqualToString:kAbsence]) {
        CHDAbsenceCategory *category = [self.viewModel.environment absenceCategoryWithId:event.eventCategoryIds.firstObject siteId: event.siteId];
        [cell.cellBackgroundView setBorderColor:category.color?: [UIColor clearColor]];
    }
    else{
        CHDEventCategory *category = [self.viewModel.environment eventCategoryWithId:event.eventCategoryIds.firstObject siteId: event.siteId];
        [cell.cellBackgroundView setBorderColor:category.color?: [UIColor clearColor]];
    }

    return cell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

#pragma mark - Lazy Initialization

-(UIRefreshControl*) refreshControl {
    if(!_refreshControl){
        _refreshControl = [[UIRefreshControl alloc] init];
        [_refreshControl addTarget:self action:@selector(refresh:) forControlEvents:UIControlEventValueChanged];
    }
    return _refreshControl;
}

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

-(UILabel *) emptyMessageLabel {
    if(!_emptyMessageLabel){
        _emptyMessageLabel = [UILabel new];
        _emptyMessageLabel.font = [UIFont chd_fontWithFontWeight:CHDFontWeightRegular size:17];
        _emptyMessageLabel.textColor = [UIColor shpui_colorWithHexValue:0xa8a8a8];
        _emptyMessageLabel.text = NSLocalizedString(@"No events today", @"");
        _emptyMessageLabel.textAlignment = NSTextAlignmentCenter;
        _emptyMessageLabel.numberOfLines = 0;
    }
    return _emptyMessageLabel;
}

#pragma mark -other methods
-(void) emptyMessageShow: (BOOL) show {
    if(show){
        [self.view addSubview:self.emptyMessageLabel];
        [self.emptyMessageLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self.view).offset(-30);
            make.centerX.equalTo(self.view);
            make.left.greaterThanOrEqualTo(self.view).offset(15);
            make.right.lessThanOrEqualTo(self.view).offset(-15);
        }];
    }else {
        [self.emptyMessageLabel removeFromSuperview];
    }
}
-(void) showProgress: (BOOL) show {
    if(show && self.navigationController.view) {
        [MBProgressHUD hideAllHUDsForView:self.navigationController.view animated:YES];
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];

        // Configure for text only and offset down
        hud.mode = MBProgressHUDModeIndeterminate;
        hud.color = [UIColor colorWithWhite:0.7 alpha:0.7];
        hud.labelColor = [UIColor chd_textDarkColor];
        hud.margin = 10.f;
        hud.removeFromSuperViewOnHide = YES;
        hud.userInteractionEnabled = NO;
    }else{
        [MBProgressHUD hideAllHUDsForView:self.navigationController.view animated:YES];
    }
}
@end
