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
#import "CHDAnalyticsManager.h"
#import "MBProgressHUD.h"
#import "CHDEventInfoViewController.h"
#import "CHDEvent.h"

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
        self.viewModel = [CHDDashboardInvitationsViewModel new];

        [self rac_liftSelector:@selector(setUnread:) withSignals:[[RACObserve(self.viewModel, invitations) combinePreviousWithStart:nil reduce:^id(NSArray *previousInvitations, NSArray *currentInvitations) {
            if (previousInvitations == nil && currentInvitations.count > 0) {
                return @YES;
            } else if (currentInvitations.count > previousInvitations.count) {
                return @YES;
            }
            return @NO;
        }] filter:^BOOL(NSNumber *iShouldFire) {
            return iShouldFire.boolValue;
        }], nil];
    }
    return self;
}
#pragma mark - View methods

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self makeViews];
    [self makeConstraints];
    [self setupBindings];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[CHDAnalyticsManager sharedInstance] trackVisitToScreen:@"dashboard_invitations"];
    [self.inviteTable deselectRowAtIndexPath:[self.inviteTable indexPathForSelectedRow] animated:YES];
    [self.inviteTable reloadData];
    [self setUnread:NO];

    NSDate *timestamp = [[NSUserDefaults standardUserDefaults] valueForKey:kinvitationsTimestamp];
    NSDate *currentTime = [NSDate date];
    NSTimeInterval timeDifference = [currentTime timeIntervalSinceDate:timestamp];
    if (timeDifference/60 > 10) {
        [self.viewModel reload];
    }
    
    [self shprac_liftSelector:@selector(showProgress:) withSignal:[[RACObserve(self.viewModel, invitations) map:^id(id value) {
        return @(value == nil);
    }] takeUntil:[self rac_signalForSelector:@selector(viewWillDisappear:)]]];
}

-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self setUnread:NO];
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
    RACSignal *invitationsSignal = [[RACObserve(self.viewModel, isEditingMessages) filter:^BOOL(NSNumber *isEditing) {
        return !isEditing.boolValue;
    }] flattenMap:^RACStream *(id value) {
        return RACObserve(self.viewModel, invitations);
    }];
    [self.inviteTable shprac_liftSelector:@selector(reloadData) withSignal:[RACSignal merge:@[invitationsSignal, RACObserve(self.viewModel, user), RACObserve(self.viewModel, environment)]]];

    [self shprac_liftSelector:@selector(endRefresh) withSignal:RACObserve(self.viewModel, invitations)];

    [self rac_liftSelector:@selector(emptyMessageShow:) withSignals:[RACObserve(self.viewModel, invitations) map:^id(NSArray *invitations) {
        if(invitations == nil){
            return @NO;
        }
        return @(invitations.count == 0);
    }], nil];

    [self shprac_liftSelector:@selector(showProgress:) withSignal:[[self rac_signalForSelector:@selector(viewWillDisappear:)] map:^id(id value) {
        return @NO;
    }]];
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
        _inviteTable.delegate = self;

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

#pragma mark - CHDNotificationEventResponder

- (BOOL)canHandleEventWithUserInfo:(NSDictionary *)userInfo {
    NSDictionary *content = userInfo[@"aps"][@"alert"][@"identifier"];
    return ([content[@"type"] isEqualToString:@"invitation-new"] || [content[@"type"] isEqualToString:@"invitation-updated"]);
}

- (void)handleEventWithUserInfo:(NSDictionary *)userInfo {
    NSDictionary *content = userInfo[@"aps"][@"alert"][@"identifier"];
    if ([content[@"type"] isEqualToString:@"invitation-new"] || [content[@"type"] isEqualToString:@"invitation-updated"]) {
        CHDEvent *event = [CHDEvent new];
        event.eventId = content[@"id"];
        event.siteId = content[@"site"];
        CHDEventInfoViewController *vc = [[CHDEventInfoViewController alloc] initWithEvent:event];
        [self.navigationController pushViewController:vc animated:YES];
    }
}

#pragma mark -TableView delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [Heap track:@"Invitation details view"];
    CHDInvitation *invitation = (CHDInvitation *)self.viewModel.invitations[indexPath.row];

    CHDEvent *event = [CHDEvent new];
    event.eventId = [invitation.invitationId copy];
    event.siteId = [invitation.siteId copy];

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
    CHDEventCategory *category = [environment eventCategoryWithId: invitation.eventCategories siteId: invitation.siteId];
    NSString *invitedByString = NSLocalizedString(@"Invited by ", @"");

    invitedByString = invitation.invitedByUser;

    cell.titleLabel.text = invitation.title;
    cell.locationLabel.text = invitation.location;
    cell.parishLabel.text = (user.sites.count > 1)? [user siteWithId:invitation.siteId].name : @"";
    cell.invitedByLabel.text = invitedByString;

    cell.eventTimeLabel.text = [self.viewModel getFormattedInvitationTimeFrom:invitation];
    cell.receivedTimeLabel.text = [timeInterValFormatter stringForTimeIntervalFromDate:[NSDate new] toDate:invitation.changeDate];

    //Setup events for the buttons
    [self rac_liftSelector:@selector(markAsAcceptedWithInvitationTuple:) withSignals:[[[cell.acceptButton rac_signalForControlEvents:UIControlEventTouchUpInside] takeUntil:cell.rac_prepareForReuseSignal] map:^id(id value) {
        return RACTuplePack(invitation, indexPath);
    }], nil];

    [self rac_liftSelector:@selector(markAsMaybeWithInvitationTuple:) withSignals:[[[cell.maybeButton rac_signalForControlEvents:UIControlEventTouchUpInside] takeUntil:cell.rac_prepareForReuseSignal] map:^id(id value) {
        return RACTuplePack(invitation, indexPath);
    }], nil];

    [self rac_liftSelector:@selector(markAsDeclineWithInvitationTuple:) withSignals:[[[cell.declineButton rac_signalForControlEvents:UIControlEventTouchUpInside] takeUntil:cell.rac_prepareForReuseSignal] map:^id(id value) {
        return RACTuplePack(invitation, indexPath);
    }], nil];

    UIColor *borderColor = category.color?: [UIColor clearColor];
    [cell.cellBackgroundView setBorderColor:borderColor];

    return cell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

#pragma mark -other methods
-(void) removeInvitationFromTableWithIndexPath:(NSIndexPath *) indexPath{
    //Set flag on viewModel to avoid reload of data while editing
    self.viewModel.isEditingMessages = YES;

    //Remove index from table
    [self.inviteTable beginUpdates];

    //Remove index from model
    if ([self.viewModel removeInvitationWithIndexPath:indexPath]) {

        [self.inviteTable deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }
    [self.inviteTable endUpdates];

    self.viewModel.isEditingMessages = NO;
}

-(void) markAsAcceptedWithInvitationTuple: (RACTuple*) tuple {
    RACTupleUnpack(CHDInvitation *invitation, NSIndexPath *indexPath) = tuple;
    [self removeInvitationFromTableWithIndexPath:indexPath];
    [self.viewModel setInivationAccept:invitation];
}

-(void) markAsMaybeWithInvitationTuple: (RACTuple*) tuple {
    RACTupleUnpack(CHDInvitation *invitation, NSIndexPath *indexPath) = tuple;
    [self removeInvitationFromTableWithIndexPath:indexPath];
    [self.viewModel setInivationMaybe:invitation];
}

-(void) markAsDeclineWithInvitationTuple: (RACTuple*) tuple {
    RACTupleUnpack(CHDInvitation *invitation, NSIndexPath *indexPath) = tuple;
    [self removeInvitationFromTableWithIndexPath:indexPath];
    [self.viewModel setInivationDecline:invitation];
}

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
    if(show) {
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
