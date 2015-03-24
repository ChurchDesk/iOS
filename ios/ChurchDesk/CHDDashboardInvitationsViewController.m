//
//  CHDDashboardInvitationsViewController.m
//  ChurchDesk
//
//  Created by Jakob Vinther-Larsen on 17/02/15.
//  Copyright (c) 2015 Shape A/S. All rights reserved.
//

#import <FormatterKit/TTTTimeIntervalFormatter.h>
#import "CHDDashboardInvitationsViewController.h"
#import "CHDInvitationsTableViewCell.h"
#import "CHDDashboardInvitationsViewModel.h"
#import "CHDInvitation.h"
#import "CHDEnvironment.h"
#import "CHDUser.h"
#import "CHDSite.h"
#import "CHDDashboardTabBarViewController.h"
#import "UIViewController+UIViewController_ChurchDesk.h"

@interface CHDDashboardInvitationsViewController ()

@property(nonatomic, strong) CHDDashboardInvitationsViewModel *viewModel;
@property(nonatomic, strong) UILabel *emptyMessageLabel;
@property(nonatomic, retain) UITableView*inviteTable;
@property(nonatomic, strong) UIRefreshControl *refreshControl;

@end

@implementation CHDDashboardInvitationsViewController

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.title = NSLocalizedString(@"Dashboard", @"");
    }
    return self;
}
#pragma mark - View methods

- (void)viewDidLoad {
    [super viewDidLoad];
    self.viewModel = [CHDDashboardInvitationsViewModel new];
    
    [self makeViews];
    [self makeConstraints];
    [self setupBindings];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.inviteTable reloadData];
}

#pragma mark - setup views

-(void) makeViews {
    [self.view addSubview:self.inviteTable];
    [self.inviteTable addSubview:self.refreshControl];

    [self setupAddButton];
}

-(void) makeConstraints {
    UIView* superview = self.view;
    [self.inviteTable mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(superview);
    }];
}

- (void) setupBindings {
    [self.inviteTable shprac_liftSelector:@selector(reloadData) withSignal:[RACSignal merge:@[RACObserve(self.viewModel, invitations), RACObserve(self.viewModel, user), RACObserve(self.viewModel, environment)]]];

    [self shprac_liftSelector:@selector(endRefresh) withSignal:RACObserve(self.viewModel, invitations)];

    if(self.chd_tabbarViewController != nil){
        [self rac_liftSelector:@selector(setUnread:) withSignals:[RACObserve(self.viewModel, invitations) map:^id(NSArray *invitations) {
            if(invitations != nil){
                return @(invitations.count > 0);
            }
            return @(NO);
        }], nil];
    }

    [self rac_liftSelector:@selector(emptyMessageShow:) withSignals:[[RACObserve(self.viewModel, invitations) skip:1] map:^id(NSArray *invitations) {
        return @(invitations.count == 0);
    }], nil];
}

-(void) setUnread: (BOOL) hasUnread {
    if(self.chd_tabbarViewController) {
        [self.chd_tabbarViewController notificationsForIndex:self.chd_tabbarIdx show:hasUnread];
    }
}

-(UITableView *)inviteTable {
    if (!_inviteTable) {
        _inviteTable = [[UITableView alloc] init];
        _inviteTable.separatorStyle = UITableViewCellSeparatorStyleNone;
        _inviteTable.backgroundView.backgroundColor = [UIColor chd_lightGreyColor];
        _inviteTable.backgroundColor = [UIColor chd_lightGreyColor];

        _inviteTable.rowHeight = 106;

        [_inviteTable registerClass:[CHDInvitationsTableViewCell class] forCellReuseIdentifier:@"invitationCell"];

        _inviteTable.dataSource = self;
    }
    return _inviteTable;
}

-(UIRefreshControl*) refreshControl {
    if(!_refreshControl){
        _refreshControl = [[UIRefreshControl alloc] init];
        [_refreshControl addTarget:self action:@selector(refresh:) forControlEvents:UIControlEventValueChanged];
    }
    return _refreshControl;
}

-(UILabel *) emptyMessageLabel {
    if(!_emptyMessageLabel){
        _emptyMessageLabel = [UILabel new];
        _emptyMessageLabel.font = [UIFont chd_fontWithFontWeight:CHDFontWeightRegular size:17];
        _emptyMessageLabel.textColor = [UIColor shpui_colorWithHexValue:0xa8a8a8];
        _emptyMessageLabel.text = NSLocalizedString(@"No invitations", @"");
        _emptyMessageLabel.textAlignment = NSTextAlignmentCenter;
        _emptyMessageLabel.numberOfLines = 0;
    }
    return _emptyMessageLabel;
}

#pragma mark - UITableViewDataSource
- (void)refresh:(UIRefreshControl *)refreshControl {
    [self.viewModel reload];
}
-(void)endRefresh {
    [self.refreshControl endRefreshing];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.viewModel.invitations? self.viewModel.invitations.count : 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    TTTTimeIntervalFormatter *timeInterValFormatter = [[TTTTimeIntervalFormatter alloc] init];
    static NSString* cellIdentifier = @"invitationCell";

    CHDInvitationsTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    
    CHDInvitation *invitation = self.viewModel.invitations[indexPath.row];
    CHDEnvironment *environment = self.viewModel.environment;
    CHDUser *user = self.viewModel.user;

    //Get the first eventCategory
    CHDEventCategory *category = (invitation.eventCategories && invitation.eventCategories.count > 0)?[environment eventCategoryWithId: invitation.eventCategories[0]] : nil;
    CHDPeerUser *invitedByUser = [environment userWithId:invitation.invitedByUserId];
    NSString *invitedByString = NSLocalizedString(@"Invited by ", @"");

    invitedByString = invitedByUser.name != nil? [invitedByString stringByAppendingString:invitedByUser.name] : @"";

    cell.titleLabel.text = invitation.title;
    cell.locationLabel.text = invitation.location;
    cell.parishLabel.text = [user siteWithId:invitation.siteId].name;
    cell.invitedByLabel.text = invitedByString;

    cell.eventTimeLabel.text = [self.viewModel getFormattedInvitationTimeFrom:invitation];
    cell.receivedTimeLabel.text = [timeInterValFormatter stringForTimeIntervalFromDate:[NSDate new] toDate:invitation.changeDate];

    //Setup events for the buttons
    RACSignal *invitationAccept = [[cell.acceptButton rac_signalForControlEvents:UIControlEventTouchUpInside] takeUntil:cell.rac_prepareForReuseSignal];
    RACSignal *invitationMaybe = [[cell.maybeButton rac_signalForControlEvents:UIControlEventTouchUpInside] takeUntil:cell.rac_prepareForReuseSignal];
    RACSignal *invitationDecline = [[cell.declineButton rac_signalForControlEvents:UIControlEventTouchUpInside] takeUntil:cell.rac_prepareForReuseSignal];

    [self.viewModel rac_liftSelector:@selector(setInivationAccept:) withSignals:[[invitationAccept map:^id(id value) {
        return invitation;
    }] takeUntil:cell.rac_prepareForReuseSignal], nil];

    [self.viewModel rac_liftSelector:@selector(setInivationMaybe:) withSignals:[[invitationMaybe map:^id(id value) {
        return invitation;
    }] takeUntil:cell.rac_prepareForReuseSignal], nil];

    [self.viewModel rac_liftSelector:@selector(setInivationDecline:) withSignals:[[invitationDecline map:^id(id value) {
        return invitation;
    }] takeUntil:cell.rac_prepareForReuseSignal], nil];

    UIColor *borderColor = category.color?: [UIColor clearColor];
    [cell.leftBorder setBackgroundColor:borderColor];

    return cell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

-(void) accepted {
    NSLog(@"Accepted");
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

@end
