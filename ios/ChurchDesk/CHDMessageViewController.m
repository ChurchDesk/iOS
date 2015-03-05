//
//  CHDMessageViewController.m
//  ChurchDesk
//
//  Created by Jakob Vinther-Larsen on 25/02/15.
//  Copyright (c) 2015 Shape A/S. All rights reserved.
//

#import "CHDMessageViewController.h"
#import "CHDMessageCommentsTableViewCell.h"
#import "CHDMessageLoadCommentsTableViewCell.h"
#import "CHDMessageTableViewCell.h"
#import "CHDMessageCommentView.h"
#import "CHDInputAccessoryObserveView.h"
#import "CHDMessageViewModel.h"
#import "CHDComment.h"
#import "CHDMessage.h"
#import "CHDEnvironment.h"
#import "CHDGroup.h"
#import "CHDPeerUser.h"
#import "TTTTimeIntervalFormatter.h"
#import "CHDUser.h"
#import "CHDSite.h"

typedef NS_ENUM(NSUInteger, messageSections) {
    messageSection,
    loadCommentsSection,
    commentsSection,
    messageSectionsCount,
};

@interface CHDMessageViewController ()
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) CHDMessageCommentView *replyView;
@property (nonatomic, strong) MASConstraint *replyBottomConstraint;
@property (nonatomic, assign, getter = isMovingKeyboard) BOOL movingKeyboard;

@property (nonatomic, strong) CHDMessageViewModel *viewModel;
@end

static NSString* kMessageCommentsCellIdentifier = @"messageCommentsCell";
static NSString* kMessageLoadCommentsCellIdentifier = @"messageLoadCommentsCell";
static NSString* kMessageCellIdentifier = @"messageCell";

@implementation CHDMessageViewController
- (instancetype)initWithMessageId: (NSNumber*)messageId site: (NSString*) site {
    self = [super init];
    if (self) {
        self.title = NSLocalizedString(@"Message", @"");

        self.viewModel = [[CHDMessageViewModel new] initWithMessageId:messageId siteId:site];
    }
    return self;
}

#pragma mark - ViewController methods
- (void)viewDidLoad {
    [super viewDidLoad];
    [self makeViews];
    [self makeConstraints];
    [self makeBindings];

    self.view.backgroundColor = [UIColor whiteColor];
}

#pragma mark - Lazy initializing
-(void) makeViews {
    [self.view addSubview:self.tableView];
    [self.view addSubview:self.replyView];
}

-(void) makeConstraints {
    UIView *containerView = self.view;
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.equalTo(containerView);
        make.bottom.equalTo(self.replyView.mas_top);
    }];

    [self.replyView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.left.equalTo(self.view);
        self.replyBottomConstraint = make.bottom.equalTo(self.view);
    }];
}

-(void) makeBindings {
    //Setup bindings for handling keyboard show/hide and drag in tableview
    [self rac_liftSelector:@selector(chd_willShowKeyboard:) withSignals:[[NSNotificationCenter defaultCenter] rac_addObserverForName:UIKeyboardWillShowNotification object:nil], nil];
    [self rac_liftSelector:@selector(chd_willHideKeyboard:) withSignals:[[NSNotificationCenter defaultCenter] rac_addObserverForName:UIKeyboardWillHideNotification object:nil], nil];
    [self rac_liftSelector:@selector(chd_didChangeKeyboardFrame:) withSignals:[[NSNotificationCenter defaultCenter] rac_addObserverForName:CHDInputAccessoryViewKeyboardFrameDidChangeNotification object:nil], nil];

    [self.tableView shprac_liftSelector:@selector(reloadData) withSignal:[RACSignal merge: @[RACObserve(self.viewModel, message), RACObserve(self.viewModel, environment), RACObserve(self.viewModel, latestComment), RACObserve(self.viewModel, user)]]];
    [self shprac_liftSelector:@selector(showAllComments) withSignal:RACObserve(self.viewModel, showAllComments)];
}

-(UITableView*) tableView{
    if(!_tableView){
        _tableView = [UITableView new];
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.backgroundView.backgroundColor = [UIColor chd_lightGreyColor];
        _tableView.backgroundColor = [UIColor chd_lightGreyColor];
        _tableView.rowHeight = UITableViewAutomaticDimension;
        _tableView.estimatedRowHeight = 140;
        [_tableView registerClass:[CHDMessageCommentsTableViewCell class] forCellReuseIdentifier:kMessageCommentsCellIdentifier];
        [_tableView registerClass:[CHDMessageTableViewCell class] forCellReuseIdentifier:kMessageCellIdentifier];
        [_tableView registerClass:[CHDMessageLoadCommentsTableViewCell class] forCellReuseIdentifier:kMessageLoadCommentsCellIdentifier];
        _tableView.dataSource = self;
        _tableView.delegate = self;
        _tableView.keyboardDismissMode = UIScrollViewKeyboardDismissModeInteractive;
    }
    return _tableView;
}

-(CHDMessageCommentView *) replyView{
    if(!_replyView){
        _replyView = [CHDMessageCommentView new];
    }
    return _replyView;
}

-(void) showAllComments {

    if(!self.viewModel.showAllComments){return;}

    NSMutableArray *newIndexPaths = [[NSMutableArray alloc]init];
    //Create indexpaths to insert
    [self.viewModel.allComments enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if(idx < self.viewModel.allComments.count -1){
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:idx inSection:commentsSection];
            [newIndexPaths addObject:indexPath];
        }
    }];

    if(newIndexPaths.count > 0) {
        NSIndexPath *showAllCommentsRow = [NSIndexPath indexPathForRow:0 inSection:loadCommentsSection];

        [self.tableView beginUpdates];

        [self.tableView deleteRowsAtIndexPaths:@[showAllCommentsRow] withRowAnimation:UITableViewRowAnimationBottom];
        [self.tableView insertRowsAtIndexPaths:newIndexPaths withRowAnimation:UITableViewRowAnimationTop];

        [self.tableView endUpdates];
    }
}

#pragma mark - TableView Delegates

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if((messageSections)section == messageSection){
        return (self.viewModel.hasMessage)? 1 : 0;
    }
    if((messageSections)section == commentsSection){
        if(self.viewModel.showAllComments) {
            return self.viewModel.allComments.count;
        }else{
            return (self.viewModel.latestComment != nil)? 1 : 0;
        }
    }
    if((messageSections)section == loadCommentsSection){
        return (self.viewModel.showAllComments || self.viewModel.commentCount <= 1)? 0 : 1;
    }
    return 0;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return messageSectionsCount;
}



- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    TTTTimeIntervalFormatter *timeInterValFormatter = [[TTTTimeIntervalFormatter alloc] init];

    if((messageSections)indexPath.section == messageSection){
        CHDMessageTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kMessageCellIdentifier forIndexPath:indexPath];
        cell.titleLabel.text = self.viewModel.message.title;
        cell.groupLabel.text = ([self.viewModel.environment groupWithId:self.viewModel.message.groupId]).name;
        cell.createdDateLabel.text = [timeInterValFormatter stringForTimeIntervalFromDate:[NSDate new] toDate:self.viewModel.message.changeDate];
        cell.messageLabel.text = self.viewModel.message.body;
        cell.parishLabel.text = [self.viewModel.user siteWithId:self.viewModel.message.siteId].name;
        cell.userNameLabel.text = [self.viewModel.environment userWithId:self.viewModel.message.authorId].name;
        cell.profileImageView.image = [UIImage imageWithData:[NSData dataWithContentsOfURL:([self.viewModel.environment userWithId:self.viewModel.message.authorId]).pictureURL]];
        return cell;
    }
    if((messageSections)indexPath.section == commentsSection){
        CHDMessageCommentsTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kMessageCommentsCellIdentifier forIndexPath:indexPath];

        CHDComment* comment = (self.viewModel.showAllComments)? self.viewModel.allComments[indexPath.row] : self.viewModel.latestComment;

        cell.messageLabel.text = comment.body;
        cell.createdDateLabel.text = [timeInterValFormatter stringForTimeIntervalFromDate:[NSDate new] toDate:comment.createdDate];
        cell.profileImageView.image = [UIImage imageWithData:[NSData dataWithContentsOfURL:([self.viewModel.environment userWithId:comment.authorId]).pictureURL]];
        cell.userNameLabel.text = [self.viewModel.environment userWithId:comment.authorId].name;

        return cell;
    }
    if((messageSections)indexPath.section == loadCommentsSection){
        CHDMessageLoadCommentsTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kMessageLoadCommentsCellIdentifier forIndexPath:indexPath];
        cell.messageLabel.text = NSLocalizedString(@"Load more comments", @"");
        cell.countLabel.text = [NSString stringWithFormat:@"(%@)", @(self.viewModel.commentCount-1)];
        return cell;
    }
    return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if((messageSections)indexPath.section == loadCommentsSection){
        self.viewModel.showAllComments = YES;
    }
}

#pragma mark - Keyboard

- (void)chd_didChangeKeyboardFrame:(NSNotification *)notification {
    // Skips if the view isn't visible
    if (!self.view.window) {
        return;
    }

    // Skips this if it's not the expected textView.
    // Checking the keyboard height constant helps to disable the view constraints update on iPad when the keyboard is undocked.
    // Checking the keyboard status allows to keep the inputAccessoryView valid when still reacing the bottom of the screen.
    if (![self.replyView.replyTextView isFirstResponder]){// || (self.keyboardHC.constant == 0 && self.keyboardStatus == SLKKeyboardStatusDidHide)) {
        return;
    }
    if(self.tableView.isDragging){
        self.movingKeyboard = YES;
    }
    if (self.isMovingKeyboard == NO) {
        return;
    }

    //Get the distance from the bottom of the screen to the top of the keyboard
    CGFloat keyboardFrameY = self.replyView.replyTextView.inputAccessoryView.superview.frame.origin.y;

    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGFloat screenHeight = screenRect.size.height;
    CGFloat keyboardOffsetHeight = screenHeight - keyboardFrameY;

    self.replyBottomConstraint.offset( (keyboardOffsetHeight  < 0)? 0 : -keyboardOffsetHeight);

    // layoutIfNeeded must be called before any further scrollView internal adjustments (content offset and size)
    [self.replyView setNeedsLayout];
    [self.replyView layoutIfNeeded];
}

-(void) chd_willShowKeyboard: (NSNotification*) notification {
    CGRect kbRect = [notification.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    CGSize kbSize = kbRect.size;

    CGRect screenRect = [[UIScreen mainScreen] bounds];
    if(kbRect.origin.y >= screenRect.size.height){return;}

    self.replyBottomConstraint.offset(-kbSize.height);
    [self.replyView setNeedsLayout];

    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:[notification.userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue]];
    [UIView setAnimationCurve:[notification.userInfo[UIKeyboardAnimationCurveUserInfoKey] integerValue]];
    [UIView setAnimationBeginsFromCurrentState:YES];

    [self.replyView layoutIfNeeded];

    [UIView commitAnimations];

    self.movingKeyboard = NO;
}

-(void) chd_willHideKeyboard: (NSNotification*) notification {
    self.replyBottomConstraint.offset(0);
    [self.replyView setNeedsLayout];

    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:[notification.userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue]];
    [UIView setAnimationCurve:[notification.userInfo[UIKeyboardAnimationCurveUserInfoKey] integerValue]];
    [UIView setAnimationBeginsFromCurrentState:YES];

    [self.replyView layoutIfNeeded];

    [UIView commitAnimations];

    self.movingKeyboard = NO;
}

@end
