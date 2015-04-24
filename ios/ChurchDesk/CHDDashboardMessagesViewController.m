//
//  CHDDashboardMessagesViewController.m
//  ChurchDesk
//
//  Created by Jakob Vinther-Larsen on 17/02/15.
//  Copyright (c) 2015 Shape A/S. All rights reserved.
//

#import "CHDDashboardMessagesViewController.h"
#import "CHDMessagesTableViewCell.h"
#import "CHDMessagesViewModelProtocol.h"
#import "CHDMessage.h"
#import "CHDDashboardMessagesViewModel.h"
#import "CHDMessageViewController.h"
#import "TTTTimeIntervalFormatter.h"
#import "CHDEnvironment.h"
#import "CHDGroup.h"
#import "CHDUser.h"
#import "CHDSite.h"
#import "CHDDashboardTabBarViewController.h"
#import "UIViewController+UIViewController_ChurchDesk.h"
#import "CHDMagicNavigationBarView.h"
#import "CHDFilterView.h"
#import "CHDPassthroughTouchView.h"
#import "CHDAnalyticsManager.h"

@interface CHDDashboardMessagesViewController () <UISearchBarDelegate>
@property (nonatomic, strong) UIView *contentView;
@property (nonatomic, strong) CHDMagicNavigationBarView *magicNavigationBar;
@property (nonatomic, strong) CHDFilterView *filterView;
@property (nonatomic, strong) UIButton *searchButton;
@property (nonatomic, strong) CHDPassthroughTouchView *drawerBlockOutView;
@property(nonatomic, strong) UILabel *emptyMessageLabel;
@property(nonatomic, retain) UITableView* messagesTable;
@property(nonatomic, strong) UIRefreshControl *refreshControl;
@property(nonatomic, strong) CHDDashboardMessagesViewModel *viewModel;
@property(nonatomic) CHDMessagesStyle messageStyle;

@end

@implementation CHDDashboardMessagesViewController

- (instancetype)initWithStyle: (CHDMessagesStyle) style
{
    self = [super init];
    if (self) {
        self.title = style == CHDMessagesStyleSearch ? nil : NSLocalizedString(@"Dashboard", @"");
        self.messageStyle = style;

        //Model is loaded from init to be able to show unread messages in Dashboard
        if (self.messageStyle == CHDMessagesStyleUnreadMessages) {
            self.viewModel = [[CHDDashboardMessagesViewModel new] initWithUnreadOnly:YES];
        }

        if(self.messageStyle == CHDMessagesStyleUnreadMessages){
            [self rac_liftSelector:@selector(setUnread:) withSignals:[RACObserve(self.viewModel, messages) combinePreviousWithStart:@[] reduce:^id(NSArray *previousMessages, NSArray *currentMessages) {
                return @(currentMessages.count > previousMessages.count);
            }], nil];
            self.messageStyle = style;
        }
    }
    return self;
}

#pragma mark - setup views

- (void) setupBindings {

    RACSignal *messagesSignal = [[RACObserve(self.viewModel, isEditingMessages) filter:^BOOL(NSNumber *isEditing) {
        return !isEditing.boolValue;
    }] flattenMap:^RACStream *(id value) {
        return RACObserve(self.viewModel, messages);
    }];

    [self.messagesTable shprac_liftSelector:@selector(reloadData) withSignal:[RACSignal merge: @[messagesSignal, RACObserve(self.viewModel, user), RACObserve(self.viewModel, environment)]]];

    [self shprac_liftSelector:@selector(endRefresh) withSignal:messagesSignal];

    [self rac_liftSelector:@selector(emptyMessageShow:) withSignals:[RACObserve(self.viewModel, messages) map:^id(NSArray *messages) {
        return @(messages.count == 0);
    }], nil];

    if(self.messageStyle == CHDMessagesStyleUnreadMessages && self.chd_tabbarViewController != nil){
        [self rac_liftSelector:@selector(setUnread:) withSignals:[messagesSignal map:^id(NSArray *messages) {
            if(messages != nil){
                return @(messages.count > 0);
            }
            return @(NO);
        }], nil];
    }

    [self.emptyMessageLabel shprac_liftSelector:@selector(setText:) withSignal:[RACObserve(self, messageStyle) map:^id(NSNumber *style) {
        if(style.unsignedIntegerValue == CHDMessagesStyleUnreadMessages){
            return NSLocalizedString(@"No unread messages", @"");
        }
        else if(style.unsignedIntegerValue == CHDMessagesStyleSearch){
            return NSLocalizedString(@"No messages", @"");
        }else{
            return NSLocalizedString(@"No messages", @"");
        }
    }]];

    if(self.messageStyle == CHDMessagesStyleAllMessages || self.messageStyle == CHDMessagesStyleSearch) {

        RACSignal *refreshSignal = [[RACSignal combineLatest:@[[self rac_signalForSelector:@selector(scrollViewDidEndDecelerating:)], self.viewModel.getMessagesCommand.executing, RACObserve(self.viewModel, canFetchMoreMessages)] reduce:^id(RACTuple *tuple, NSNumber *iExecuting, NSNumber *iCanFetch) {
            if(iExecuting.boolValue || !iCanFetch.boolValue){
                return nil;
            }
            return tuple.first;
        }] filter:^BOOL(UITableView *tableView) {
            if(tableView == nil){return NO;}
            CGFloat contentHeight = tableView.contentSize.height;
            CGFloat heightOffset = tableView.contentOffset.y;

            NSInteger sectionCount = tableView.numberOfSections;
            NSInteger rowCount = [tableView numberOfRowsInSection:sectionCount - 1];

            return contentHeight - heightOffset < contentHeight * 0.2 && sectionCount > 0 && rowCount > 0;
        }];

        __block NSString *lastSearchQuery = nil;
        CHDDashboardMessagesViewModel *viewModel = self.viewModel;
        [self.viewModel rac_liftSelector:@selector(fetchMoreMessagesWithQuery:continuePagination:) withSignals:RACObserve(viewModel, searchQuery), [refreshSignal flattenMap:^RACStream *(id value) {
            RACSignal *continuePaginationSignal = [[RACObserve(viewModel, searchQuery) take:1] map:^id(NSString *searchQuery) {
                return @(searchQuery == lastSearchQuery || [searchQuery isEqualToString:lastSearchQuery]);
            }];
            lastSearchQuery = viewModel.searchQuery;
            return continuePaginationSignal;
        }], nil];

        if (self.messageStyle != CHDMessagesStyleSearch) {
            [self rac_liftSelector:@selector(changeStyle:) withSignals:[RACObserve(self.filterView, selectedFilter) skip:1], nil];

            [self shprac_liftSelector:@selector(blockOutViewTouched) withSignal:[self.drawerBlockOutView rac_signalForSelector:@selector(touchesBegan:withEvent:)]];

            //Handle when the drawer is shown/hidden
            RACSignal *drawerIsShownSignal = RACObserve(self.magicNavigationBar, drawerIsHidden);

            [self shprac_liftSelector:@selector(drawerDidHide) withSignal:[drawerIsShownSignal filter:^BOOL(NSNumber *iIsHidden) {
                return iIsHidden.boolValue;
            }]];

            [self shprac_liftSelector:@selector(drawerWillShow) withSignal:[drawerIsShownSignal filter:^BOOL(NSNumber *iIsHidden) {
                return !iIsHidden.boolValue;
            }]];
        }
    }
}

-(void) makeViews {
    self.view.backgroundColor = [UIColor chd_lightGreyColor];
    [self.view addSubview:self.contentView];
    [self.contentView addSubview:self.messagesTable];
    [self.messagesTable addSubview:self.refreshControl];

    if(self.messageStyle == CHDMessagesStyleAllMessages) {
        [self.view addSubview:self.magicNavigationBar];
        [self.magicNavigationBar.drawerView addSubview:self.filterView];
        [self.magicNavigationBar.drawerView addSubview:self.searchButton];

        [self.filterView setupFiltersWithTitels:@[NSLocalizedString(@"Show all", @""), NSLocalizedString(@"Show unread", @"")] filters:@[@(CHDMessagesStyleAllMessages), @(CHDMessagesStyleUnreadMessages)]];
        self.filterView.selectedFilter = CHDMessagesStyleAllMessages;
        [self.view addSubview:self.drawerBlockOutView];
    }
    if (self.messageStyle == CHDMessagesStyleSearch) {
        UIBarButtonItem *cancelItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Cancel", @"") style:UIBarButtonItemStylePlain target:self action:@selector(searchCloseAction:)];
        self.navigationItem.rightBarButtonItem = cancelItem;

        UIView *view = [cancelItem valueForKey:@"view"];
        CGFloat cancelItemWidth;
        if(view){
            cancelItemWidth = [view frame].size.width;
        }
        else{
            cancelItemWidth = (CGFloat)0.0;
        }

        CGFloat searchbarWidth = self.view.bounds.size.width - (cancelItemWidth + 40);

        UISearchBar *searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, searchbarWidth, 40)];
//        searchBar.placeholder = NSLocalizedString(@"Search", @"");
        [searchBar setImage:kImgSearchActive forSearchBarIcon:UISearchBarIconSearch state:UIControlStateNormal];
        searchBar.delegate = self;
        UIBarButtonItem *searchItem = [[UIBarButtonItem alloc] initWithCustomView:searchBar];
        self.navigationItem.leftBarButtonItem = searchItem;

    }
    else {
        [self setupAddButton];
    }
}

-(void) makeConstraints {
    if(self.messageStyle == CHDMessagesStyleAllMessages){
        [self.drawerBlockOutView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.contentView);
        }];

        [self.contentView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.bottom.right.equalTo(self.view);
            self.magicNavigationBar.bottomConstraint = make.top.equalTo(self.view);
        }];

        [self.magicNavigationBar mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.equalTo(self.view);
            make.bottom.equalTo(self.contentView.mas_top);
        }];
        [self.filterView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.magicNavigationBar.drawerView);
        }];

        [self.searchButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(self.magicNavigationBar.drawerView).offset(-4.5);
            make.width.height.equalTo(@44);
            make.bottom.equalTo(self.magicNavigationBar.drawerView);
        }];

    }else{
        [self.contentView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.view);
        }];
    }

    [self.messagesTable mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.contentView);
    }];
}

#pragma mark - CHDNotificationEventResponder

- (BOOL)canHandleEventWithUserInfo:(NSDictionary *)userInfo {
    NSDictionary *content = userInfo[@"identifier"];
    return [content[@"type"] isEqualToString:@"message"];
}

- (void)handleEventWithUserInfo:(NSDictionary *)userInfo {
    NSDictionary *content = userInfo[@"identifier"];
    if ([content[@"type"] isEqualToString:@"message"]) {
        CHDMessageViewController *messageViewController = [[CHDMessageViewController new] initWithMessageId:content[@"id"] site:content[@"site"]];
        [self.navigationController pushViewController:messageViewController animated:NO];
    }
}

#pragma mark -Lazy initialisation
- (UIView *)contentView {
    if (!_contentView) {
        _contentView = [UIView new];
    }
    return _contentView;
}

-(UITableView *) messagesTable {
    if (!_messagesTable) {
        _messagesTable = [[UITableView alloc] init];
        _messagesTable.separatorStyle = UITableViewCellSeparatorStyleNone;
        _messagesTable.backgroundView.backgroundColor = [UIColor clearColor];
        _messagesTable.backgroundColor = [UIColor clearColor];

        _messagesTable.rowHeight = 85;

        [_messagesTable registerClass:[CHDMessagesTableViewCell class] forCellReuseIdentifier:@"messagesCell"];

        _messagesTable.dataSource = self;
        _messagesTable.delegate = self;
    }
    return _messagesTable;
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
        _emptyMessageLabel.text = self.messageStyle == CHDMessagesStyleUnreadMessages? NSLocalizedString(@"No unread messages", @"") : NSLocalizedString(@"No messages", @"");
        _emptyMessageLabel.textAlignment = NSTextAlignmentCenter;
        _emptyMessageLabel.numberOfLines = 0;
    }
    return _emptyMessageLabel;
}

- (CHDMagicNavigationBarView *)magicNavigationBar {
    if (!_magicNavigationBar) {
        _magicNavigationBar = [[CHDMagicNavigationBarView alloc] initWithNavigationController:self.navigationController navigationItem:self.navigationItem];
    }
    return _magicNavigationBar;
}

- (CHDFilterView *)filterView {
    if(!_filterView){
        _filterView = [CHDFilterView new];
    }
    return _filterView;
}

-(CHDPassthroughTouchView*) drawerBlockOutView {
    if(!_drawerBlockOutView){
        _drawerBlockOutView = [CHDPassthroughTouchView new];
        _drawerBlockOutView.backgroundColor = [UIColor colorWithWhite:1 alpha:0];
    }
    return _drawerBlockOutView;
}

- (UIButton *)searchButton {
    if (!_searchButton) {
        _searchButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_searchButton setImage:kImgSearchPassive forState:UIControlStateNormal];
        [_searchButton setImage:kImgSearchActive forState:UIControlStateHighlighted];
        [_searchButton addTarget:self action:@selector(searchAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _searchButton;
}

#pragma mark - View methods

- (void)viewDidLoad {
    [super viewDidLoad];
    //Only load search model in did load
    if (self.messageStyle == CHDMessagesStyleSearch) {
        self.viewModel = [[CHDDashboardMessagesViewModel new] initWaitForSearch:YES];
    }else if(self.messageStyle == CHDMessagesStyleAllMessages){
        self.viewModel = [[CHDDashboardMessagesViewModel new] initWithUnreadOnly:NO];
    }

    [self setupBindings];
    // Do any additional setup after loading the view.
    [self makeViews];
    [self makeConstraints];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.messagesTable deselectRowAtIndexPath:[self.messagesTable indexPathForSelectedRow] animated:YES];
    if(self.messageStyle == CHDMessagesStyleUnreadMessages) {
        [[CHDAnalyticsManager sharedInstance] trackVisitToScreen:@"dashboard_messages"];
    }
    else if(self.messageStyle == CHDMessagesStyleAllMessages) {
        [[CHDAnalyticsManager sharedInstance] trackVisitToScreen:@"messages"];
    }
    else if(self.messageStyle == CHDMessagesStyleSearch) {
        [[CHDAnalyticsManager sharedInstance] trackVisitToScreen:@"messages_search"];
    }
    [self.messagesTable reloadData];
    [self setUnread:NO];
}

#pragma mark - UISearchBarDelegate

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [self setUnread:NO];
    self.viewModel.searchQuery = searchBar.text;
}

#pragma mark - UIScrollView
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    //
}

#pragma mark - UITableViewDataSource
- (void)refresh:(UIRefreshControl *)refreshControl {
    if(self.messageStyle == CHDMessagesStyleUnreadMessages) {
        [self.viewModel reloadUnread];
    }
    if(self.messageStyle == CHDMessagesStyleAllMessages){
        [self.viewModel reloadAll];
    }
}
-(void)endRefresh {
    [self.refreshControl endRefreshing];
}

-(void) markAsReadWithMessageIndexTuple: (RACTuple *) tuple {
    RACTupleUnpack(CHDMessage *message, NSIndexPath *indexPath) = tuple;

    if(self.messageStyle == CHDMessagesStyleUnreadMessages) {
        //Set flag on viewModel to avoid reload of data while editing
        self.viewModel.isEditingMessages = YES;

        //Remove index from table
        [self.messagesTable beginUpdates];

        //Remove index from model
        if ([self.viewModel removeMessageWithIndex:indexPath.row]) {

            [self.messagesTable deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationTop];

        }
        [self.messagesTable endUpdates];

        //Setup some handling for errors and success
        [self.viewModel setMessageAsRead:message];

        self.viewModel.isEditingMessages = NO;
        return;
    }

    if(self.messageStyle == CHDMessagesStyleAllMessages){
        [self.viewModel setMessageAsRead:message];
        [self.messagesTable reloadData];
        return;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    CHDMessage* message = self.viewModel.messages[indexPath.row];
    message.read = YES;
    CHDMessageViewController *messageViewController = [[CHDMessageViewController new] initWithMessageId:message.messageId site:message.siteId];

    [self.navigationController pushViewController:messageViewController animated:YES];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.viewModel.messages.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    TTTTimeIntervalFormatter *timeInterValFormatter = [[TTTTimeIntervalFormatter alloc] init];
    static NSString* cellIdentifier = @"messagesCell";

    CHDMessage* message = self.viewModel.messages[indexPath.row];
    CHDUser* user = self.viewModel.user;
    CHDEnvironment *environment = self.viewModel.environment;

    CHDMessagesTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    cell.parishLabel.text = (user.sites.count > 1)? [user siteWithId:message.siteId].name : @"";
    cell.receivedTimeLabel.text = [timeInterValFormatter stringForTimeIntervalFromDate:[NSDate new] toDate:message.lastActivityDate];
    cell.groupLabel.text = [environment groupWithId:message.groupId].name;
    cell.authorLabel.text = [self.viewModel authorNameWithId:message.authorId authorSiteId:message.siteId];
    cell.contentLabel.text = message.messageLine;
    cell.receivedDot.dotColor = message.read? [UIColor clearColor] : [UIColor chd_blueColor];
    cell.accessoryEnabled = !message.read;

    RACSignal *markAsRead = [[cell.markAsReadButton rac_signalForControlEvents:UIControlEventTouchUpInside] takeUntil:cell.rac_prepareForReuseSignal];

    [self rac_liftSelector:@selector(markAsReadWithMessageIndexTuple:) withSignals:[[markAsRead map:^id(id value) {
        return RACTuplePack(message, indexPath);
    }] takeUntil:cell.rac_prepareForReuseSignal], nil];

    return cell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

#pragma mark -other methods

- (void)searchAction: (id) sender {
    CHDDashboardMessagesViewController *messagesVC = [[CHDDashboardMessagesViewController alloc] initWithStyle:CHDMessagesStyleSearch];
    UINavigationController *navCtrl = [[UINavigationController alloc] initWithRootViewController:messagesVC];
    navCtrl.navigationBar.barTintColor = [UIColor chd_darkBlueColor];

    [self presentViewController:navCtrl animated:YES completion:nil];
}

- (void) searchCloseAction: (id) sender {
    [self.navigationItem.leftBarButtonItem.customView endEditing:YES];
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

-(void) setUnread: (BOOL) hasUnread {
    if(self.chd_tabbarViewController) {
        [self.chd_tabbarViewController notificationsForIndex:self.chd_tabbarIdx show:hasUnread];
    }
}

-(void) changeStyle: (CHDMessagesStyle) style {
    NSAssert(style != CHDMessagesStyleSearch, @"Cannot change to search style");
    self.messageStyle = style;
    self.viewModel.unreadOnly = style == CHDMessagesStyleUnreadMessages;

    [[CHDAnalyticsManager sharedInstance] trackEventWithCategory:ANALYTICS_CATEGORY_MESSAGES action:ANALYTICS_ACTION_FILTER label:style == CHDMessagesStyleUnreadMessages? ANALYTICS_LABEL_UNREAD : ANALYTICS_LABEL_ALL];
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

- (void) blockOutViewTouched {
    [self.magicNavigationBar setShowDrawer:NO animated:YES];
}

- (void) drawerWillShow {
    self.drawerBlockOutView.touchesPassThrough = NO;
}

-(void) drawerDidHide {
    self.drawerBlockOutView.touchesPassThrough = YES;
}

@end
