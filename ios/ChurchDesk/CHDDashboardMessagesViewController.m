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

@interface CHDDashboardMessagesViewController ()

@property(nonatomic, retain) UITableView* messagesTable;
@property(nonatomic, strong) CHDDashboardMessagesViewModel *viewModel;
@property (nonatomic) CHDMessagesFilterType messageFilter;

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

    RACSignal *messagesEditingSignal = RACObserve(self.viewModel, isEditingMessages);
    RACSignal *messagesSignal = RACObserve(self.viewModel, messages);

    RACSignal *messagesReloadSignal = [[messagesEditingSignal filter:^BOOL(NSNumber *isEditing) {
        return !isEditing.boolValue;
    }] flattenMap:^RACStream *(id value) {
        return messagesSignal;
    }];

    
    [self.messagesTable shprac_liftSelector:@selector(reloadData) withSignal:[RACSignal merge: @[messagesReloadSignal, RACObserve(self.viewModel, user), RACObserve(self.viewModel, environment)]]];

    if(self.messageFilter == CHDMessagesFilterTypeAllMessages) {
        RACSignal *refreshSignal = [[[self rac_signalForSelector:@selector(scrollViewDidEndDecelerating:)] map:^id(RACTuple *tuple) {
            return tuple.first;
        }] filter:^BOOL(UITableView *tableView) {
            CGFloat contentHeight = tableView.contentSize.height;
            CGFloat heightOffset = tableView.contentOffset.y;

            NSInteger sectionCount = tableView.numberOfSections;
            NSInteger rowCount = [tableView numberOfRowsInSection:sectionCount - 1];
            return contentHeight - heightOffset < contentHeight * 0.2 && sectionCount > 0 && rowCount > 0;
        }];

        CHDDashboardMessagesViewModel *viewModel = self.viewModel;
        [self.viewModel rac_liftSelector:@selector(fetchMoreMessagesFromDate:) withSignals:[[refreshSignal map:^id(UITableView *tableView) {
            NSInteger sectionCount = tableView.numberOfSections;
            NSInteger rowCount = [tableView numberOfRowsInSection:sectionCount - 1];
            CHDMessage *message = viewModel.messages[rowCount - 1];
            return [message.changeDate dateByAddingTimeInterval:0.01];
        }] startWith:[NSDate date]], nil];
    }
}

-(void) makeViews {
    [self.view addSubview:self.messagesTable];
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
}
     
#pragma mark - UITableViewDataSource
-(void) markAsReadWithMessageIndexTuple: (RACTuple *) tuple {
    RACTupleUnpack(CHDMessage *message, NSIndexPath *indexPath) = tuple;

    //Set flag on viewModel to avoid reload of data while editing
    self.viewModel.isEditingMessages = YES;

    //Remove index from table
    [self.messagesTable beginUpdates];

    //Remove index from model
    if([self.viewModel removeMessageWithIndex:indexPath.row]){

        [self.messagesTable deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationTop];

    }
    [self.messagesTable endUpdates];

    //Setup some handling for errors and success
    [self.viewModel setMessageAsRead:message];

    self.viewModel.isEditingMessages = NO;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    CHDMessage* message = self.viewModel.messages[indexPath.row];
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

@end
