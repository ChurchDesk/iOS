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

@interface CHDDashboardMessagesViewController ()

@property(nonatomic, retain) UITableView* messagesTable;
@property(nonatomic, strong) CHDDashboardMessagesViewModel *viewModel;

@end

@implementation CHDDashboardMessagesViewController

- (instancetype)initWithFilterType: (CHDMessagesFilterType) filterType
{
    self = [super init];
    if (self) {
        self.title = NSLocalizedString(@"Dashboard", @"");
    }
    return self;
}

#pragma mark - setup views

- (void) setupBindings {
    [self.messagesTable shprac_liftSelector:@selector(reloadData) withSignal:RACObserve(self.viewModel, messages)];
    
    RACSignal *refreshSignal = [[[self rac_signalForSelector:@selector(scrollViewDidEndDecelerating:)] map:^id(RACTuple *tuple) {
        return tuple.first;
    }] filter:^BOOL(UITableView *tableView) {
        CGFloat contentHeight = tableView.contentSize.height;
        CGFloat heightOffset = tableView.contentOffset.y;
        
        NSInteger sectionCount = tableView.numberOfSections;
        NSInteger rowCount = [tableView numberOfRowsInSection:sectionCount-1];
        return contentHeight - heightOffset < contentHeight*0.2 && sectionCount > 0 && rowCount > 0;
    }];
    
    CHDDashboardMessagesViewModel *viewModel = self.viewModel;
    [self.viewModel rac_liftSelector:@selector(fetchMoreMessagesFromDate:) withSignals:[[refreshSignal map:^id(UITableView *tableView) {
        NSInteger sectionCount = tableView.numberOfSections;
        NSInteger rowCount = [tableView numberOfRowsInSection:sectionCount-1];
        CHDMessage *message = viewModel.messages[rowCount-1];
        return [message.changeDate dateByAddingTimeInterval:0.01];
    }] startWith:[NSDate date]], nil];
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
    self.viewModel = [CHDDashboardMessagesViewModel new];

    [self setupBindings];
    // Do any additional setup after loading the view.
    [self makeViews];
    [self makeConstraints];
    self.view.backgroundColor = [UIColor whiteColor];
}

#pragma mark - UIScrollView
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    //
}
     
#pragma mark - UITableViewDataSource

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    CHDMessage* message = self.viewModel.messages[indexPath.row];
    CHDMessageViewController *messageViewController = [[CHDMessageViewController new] initWithMessageId:message.messageId site:message.site];

    [self.navigationController pushViewController:messageViewController animated:YES];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.viewModel.messages.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString* cellIdentifier = @"messagesCell";

    CHDMessage* message = self.viewModel.messages[indexPath.row];

    CHDMessagesTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    cell.parishLabel.text = @"Parish";
    cell.receivedTimeLabel.text = message.lastActivityDate.description;
    cell.groupLabel.text = message.groupId.stringValue;
    cell.authorLabel.text = [self.viewModel authorNameWithId:message.authorId];
    cell.contentLabel.text = message.messageLine;
    cell.receivedDot.dotColor = message.read? [UIColor clearColor] : [UIColor chd_blueColor];

    return cell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

@end
