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

@interface CHDDashboardMessagesViewController ()

@property(nonatomic, strong) UILabel *emptyMessageLabel;
@property(nonatomic, retain) UITableView* messagesTable;
@property(nonatomic, strong) UIRefreshControl *refreshControl;
@property(nonatomic, strong) CHDDashboardMessagesViewModel *viewModel;
@property(nonatomic) CHDMessagesFilterType messageFilter;

@end

@implementation CHDDashboardMessagesViewController

- (instancetype)initWithFilterType: (CHDMessagesFilterType) filterType
{
    self = [super init];
    if (self) {
        self.title = NSLocalizedString(@"Dashboard", @"");
        self.messageFilter = filterType;
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

    [self rac_liftSelector:@selector(emptyMessageShow:) withSignals:[[RACObserve(self.viewModel, messages) skip:1] map:^id(NSArray *messages) {
        return @(messages.count == 0);
    }], nil];

    if(self.messageFilter == CHDMessagesFilterTypeUnreadMessages && self.chd_tabbarViewController != nil){
        [self rac_liftSelector:@selector(setUnread:) withSignals:[messagesSignal map:^id(NSArray *messages) {
            if(messages != nil){
                return @(messages.count > 0);
            }
            return @(NO);
        }], nil];
    }
    if(self.messageFilter == CHDMessagesFilterTypeAllMessages) {

        RACSignal *refreshSignal = [[RACSignal combineLatest:@[[self rac_signalForSelector:@selector(scrollViewDidEndDecelerating:)], self.viewModel.getMessagesCommand.executing, RACObserve(self.viewModel, canFetchNewMessages)] reduce:^id(RACTuple *tuple, NSNumber *iExecuting, NSNumber *iCanFetch) {
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

        [self.viewModel shprac_liftSelector:@selector(fetchMoreMessages) withSignal:refreshSignal];
    }
}

-(void) setUnread: (BOOL) hasUnread {
    if(self.chd_tabbarViewController) {
        [self.chd_tabbarViewController notificationsForIndex:self.chd_tabbarIdx show:hasUnread];
    }
}

-(void) makeViews {
    [self.view addSubview:self.messagesTable];
    [self.messagesTable addSubview:self.refreshControl];
    [self setupAddButton];
}

-(void) makeConstraints {
    [self.messagesTable mas_makeConstraints:^(MASConstraintMaker *make){
        make.edges.equalTo(self.view);
    }];
}

-(UITableView *) messagesTable {
    if (!_messagesTable) {
        _messagesTable = [[UITableView alloc] init];
        _messagesTable.separatorStyle = UITableViewCellSeparatorStyleNone;
        _messagesTable.backgroundView.backgroundColor = [UIColor chd_lightGreyColor];
        _messagesTable.backgroundColor = [UIColor chd_lightGreyColor];

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
        _emptyMessageLabel.text = self.messageFilter == CHDMessagesFilterTypeUnreadMessages? NSLocalizedString(@"No unread messages", @"") : NSLocalizedString(@"No messages", @"");
        _emptyMessageLabel.textAlignment = NSTextAlignmentCenter;
        _emptyMessageLabel.numberOfLines = 0;
    }
    return _emptyMessageLabel;
}

#pragma mark - View methods

- (void)viewDidLoad {
    [super viewDidLoad];
    self.viewModel = [[CHDDashboardMessagesViewModel new] initWithUnreadOnly:(self.messageFilter == CHDMessagesFilterTypeUnreadMessages)];

    [self setupBindings];
    // Do any additional setup after loading the view.
    [self makeViews];
    [self makeConstraints];
    self.view.backgroundColor = [UIColor whiteColor];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.messagesTable reloadData];
}

#pragma mark - UIScrollView
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    //
}

#pragma mark - UITableViewDataSource
- (void)refresh:(UIRefreshControl *)refreshControl {
    if(self.messageFilter == CHDMessagesFilterTypeUnreadMessages) {
        [self.viewModel reloadUnread];
    }
    if(self.messageFilter == CHDMessagesFilterTypeAllMessages){
        [self.viewModel reloadAll];
    }
}
-(void)endRefresh {
    [self.refreshControl endRefreshing];
}

-(void) markAsReadWithMessageIndexTuple: (RACTuple *) tuple {
    RACTupleUnpack(CHDMessage *message, NSIndexPath *indexPath) = tuple;

    if(self.messageFilter == CHDMessagesFilterTypeUnreadMessages) {
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

    if(self.messageFilter == CHDMessagesFilterTypeAllMessages){
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
    cell.parishLabel.text = [user siteWithId:message.siteId].name;
    cell.receivedTimeLabel.text = [timeInterValFormatter stringForTimeIntervalFromDate:[NSDate new] toDate:message.lastActivityDate];
    cell.groupLabel.text = [environment groupWithId:message.groupId].name;
    cell.authorLabel.text = [self.viewModel authorNameWithId:message.authorId];
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
