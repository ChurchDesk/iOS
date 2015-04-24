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
#import "MBProgressHUD.h"
#import "CHDAnalyticsManager.h"

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

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[CHDAnalyticsManager sharedInstance] trackVisitToScreen:@"message"];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self showProgress:NO];
}

#pragma mark - Setup views constrains etc.

-(void) makeViews {
    [self.view addSubview:self.tableView];
    [self.view addSubview:self.replyView];
}

-(void) makeConstraints {
    UIView *containerView = self.view;
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.bottom.equalTo(containerView);
        //make.bottom.equalTo(self.replyView.mas_top);
    }];

    [self.replyView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.left.equalTo(self.view);
        make.top.greaterThanOrEqualTo(self.view);
        self.replyBottomConstraint = make.bottom.equalTo(self.view);
    }];
}

-(void) makeBindings {
    //Setup bindings for handling keyboard show/hide and drag in tableview
    [self rac_liftSelector:@selector(chd_willShowKeyboard:) withSignals:[[NSNotificationCenter defaultCenter] rac_addObserverForName:UIKeyboardWillShowNotification object:nil], nil];
    [self rac_liftSelector:@selector(chd_willHideKeyboard:) withSignals:[[NSNotificationCenter defaultCenter] rac_addObserverForName:UIKeyboardWillHideNotification object:nil], nil];
    [self rac_liftSelector:@selector(chd_didChangeKeyboardFrame:) withSignals:[[NSNotificationCenter defaultCenter] rac_addObserverForName:CHDInputAccessoryViewKeyboardFrameDidChangeNotification object:nil], nil];

    [self shprac_liftSelector:@selector(showAllComments) withSignal:RACObserve(self.viewModel, showAllComments)];

    RACSignal *showAllCommentsSignal = [[RACObserve(self.viewModel, showAllComments) skip:1] take:1];

    //Stop the signal from latests when all is shown
    RACSignal *latestCommentsSignal = [[RACObserve(self.viewModel, latestComments) combinePreviousWithStart:@[] reduce:^id(NSArray *previous, NSArray *current) {
        return RACTuplePack(previous, current);
    }] takeUntil:showAllCommentsSignal];

    //Setup signal when all comments are shown
    RACSignal *allCommentsSignal = [showAllCommentsSignal flattenMap:^RACStream *(id value) {
        return [[RACObserve(self.viewModel, allComments) combinePreviousWithStart:@[] reduce:^id(NSArray *previous, NSArray *current) {
            return RACTuplePack(previous, current);
        }] skip:1];
    }];

    RACSignal *messageSignal = [RACObserve(self.viewModel, message) combinePreviousWithStart:nil reduce:^id(CHDMessage *previous, CHDMessage *current) {
        return RACTuplePack(previous, current);
    }];

    //On first load the message and previous comments should not animate in, only new comments should
    RACSignal *firstMessageSignal = [[messageSignal skip:1] take:1];
    RACSignal *MessageUpdateSignal = [messageSignal skip:2];

    RACSignal *firstCommentSignal = [[latestCommentsSignal skip:1] take:1];
    RACSignal *latestCommentsUpdateSignal = [latestCommentsSignal skip:2];

    [self rac_liftSelector:@selector(updateTableWithMessageTuple:) withSignals:MessageUpdateSignal, nil];
    [self rac_liftSelector:@selector(updateTableWithCommentsTuble:) withSignals:[RACSignal merge:@[latestCommentsUpdateSignal, allCommentsSignal]], nil];

    [self.tableView shprac_liftSelector:@selector(reloadData) withSignal:[RACSignal merge: @[firstMessageSignal, firstCommentSignal, RACObserve(self.viewModel, environment),RACObserve(self.viewModel, user)]]];

    //Bind the input field to the viewModel
    RACSignal *validCommentTextSignal = RACObserve(self.replyView, hasText);

    RAC(self.replyView.replyButton, enabled) = [RACSignal combineLatest:@[validCommentTextSignal, self.viewModel.saveCommand.executing, self.viewModel.commentUpdateCommand.executing, RACObserve(self.viewModel, hasMessage)] reduce:^(NSNumber *iCanSend, NSNumber *iExecuting, NSNumber *iUpdateExecuting, NSNumber *iHasMessage) {
        return @(iCanSend.boolValue && !iExecuting.boolValue && !iUpdateExecuting.boolValue && iHasMessage.boolValue);
    }];

    RAC(self.replyView.replyTextView, editable) = [RACSignal combineLatest:@[[self.viewModel.saveCommand.executing not], [self.viewModel.commentUpdateCommand.executing not], RACObserve(self.viewModel, hasMessage)] reduce:^(NSNumber *iNotExecuting, NSNumber *iNotUpdateExecuting, NSNumber *iHasMessage) {
        return @(iNotExecuting.boolValue && iNotUpdateExecuting.boolValue && iHasMessage.boolValue);
    }];

    [self.replyView.replyButton addTarget:self action:@selector(sendAction:) forControlEvents:UIControlEventTouchUpInside];

    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(touchedTableView:)];
    tap.numberOfTapsRequired = 1;
    tap.numberOfTouchesRequired = 1;
    tap.cancelsTouchesInView = NO;

    [self.tableView addGestureRecognizer:tap];

    [self.replyView rac_liftSelector:@selector(setTextInput:) withSignals:[RACObserve(self.viewModel, commentEdit) map:^id(CHDComment *comment) {
        return comment != nil? comment.body : @"";
    }], nil];

    [self.replyView.replyTextView shprac_liftSelector:@selector(becomeFirstResponder) withSignal:[RACObserve(self.viewModel, commentEdit) filter:^BOOL(CHDComment *comment) {
        return comment != nil;
    }]];

    [self.replyView rac_liftSelector:@selector(setState:) withSignals:[RACObserve(self.viewModel, commentEdit) map:^id(CHDComment *comment) {
        return (!comment)? @(CHDCommentViewStateReply) : @(CHDCommentViewStateUpdate);
    }], nil];

    [self shprac_liftSelector:@selector(showProgress:) withSignal:[RACSignal merge:@[self.viewModel.saveCommand.executing, self.viewModel.commentDeleteCommand.executing, self.viewModel.commentUpdateCommand.executing, self.viewModel.loadMessageCommand.executing]]];
}

#pragma mark -Actions

-(void) touchedTableView: (id) sender {
    [self.view endEditing:YES];
    self.viewModel.commentEdit = nil;
}

- (void) sendAction: (id) sender {
    if(!self.viewModel.commentEdit) {
        NSString *commentText = self.replyView.replyTextView.text;
        RACSignal *commentSentSignal = [[[self.viewModel sendCommentWithText:commentText] catch:^RACSignal *(NSError *error) {
                //Error Handling
                NSString *title = NSLocalizedString(@"Error sending comment", @"");
                NSString *message = NSLocalizedString(@"Please try again later", @"");
                NSString *cancelBtnTitle = NSLocalizedString(@"ok", @"");
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title message:message delegate:nil cancelButtonTitle:cancelBtnTitle otherButtonTitles:nil];
                [alertView show];
                return [RACSignal empty];
            }] map:^id(id value) {
                return nil;
            }];
        [self.replyView shprac_liftSelector:@selector(clearTextInput) withSignal:commentSentSignal];
    }else{
        NSString *commentText = self.replyView.replyTextView.text;
        self.viewModel.commentEdit.body = commentText;
        RACSignal *commentEditedSignal = [[[self.viewModel commentUpdateWithComment:self.viewModel.commentEdit] catch:^RACSignal *(NSError *error) {
                //Error Handling
                NSString *title = NSLocalizedString(@"Error updating comment", @"");
                NSString *message = NSLocalizedString(@"Please try again later", @"");
                NSString *cancelBtnTitle = NSLocalizedString(@"ok", @"");
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title message:message delegate:nil cancelButtonTitle:cancelBtnTitle otherButtonTitles:nil];
                [alertView show];
                return [RACSignal empty];
            }] map:^id(id value) {
                return nil;
            }];
        [self.viewModel rac_liftSelector:@selector(setCommentEdit:) withSignals:commentEditedSignal, nil];

        [self.replyView shprac_liftSelector:@selector(clearTextInput) withSignal:commentEditedSignal];
    }
}

-(void) showProgress: (BOOL) show {
    if(show) {
        [MBProgressHUD hideAllHUDsForView:self.navigationController.view animated:YES];
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];

        // Configure for text only and offset down
        hud.mode = MBProgressHUDModeIndeterminate;
        hud.color = [UIColor colorWithWhite:1 alpha:0.7];
        hud.labelColor = [UIColor chd_textDarkColor];
        hud.activityIndicatorColor = [UIColor blackColor];
        hud.margin = 10.f;
        hud.removeFromSuperViewOnHide = YES;
        hud.userInteractionEnabled = NO;
    }else{
        [MBProgressHUD hideAllHUDsForView:self.navigationController.view animated:YES];
    }
}

#pragma mark - Lazy initializing

-(UITableView*) tableView{
    if(!_tableView){
        _tableView = [UITableView new];
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.backgroundView.backgroundColor = [UIColor chd_lightGreyColor];
        _tableView.backgroundColor = [UIColor chd_lightGreyColor];
        _tableView.rowHeight = UITableViewAutomaticDimension;
        _tableView.estimatedRowHeight = 140;
        _tableView.contentInset = UIEdgeInsetsMake(0, 0, 50, 0);
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

#pragma mark -Tableview Comment update

-(void) updateTableWithMessageTuple: (RACTuple*) messageTuple {
    RACTupleUnpack(CHDMessage *previousMessage, CHDMessage *currentMessage) = messageTuple;

    //Insert new message in tableView
    if(previousMessage == nil && currentMessage != nil){
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:messageSection];

        [self.tableView beginUpdates];

        [self.tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationTop];

        [self.tableView endUpdates];
    }else{
        [self.tableView reloadData];
    }
}

-(void) updateTableWithCommentsTuble: (RACTuple*) commentTuple {
    RACTupleUnpack(NSArray *previousComments, NSArray *currentComments) = commentTuple;

    if(previousComments.count < currentComments.count){
        NSIndexPath *loadCommentsIndexPath = [NSIndexPath indexPathForRow:0 inSection:loadCommentsSection];

        NSUInteger startIndex = previousComments.count; // == 0? 0 : previousComments.count;
        NSUInteger numberOfNewComments = currentComments.count;

        NSMutableArray *commentsIndexs = [[NSMutableArray alloc] init];

        for(; startIndex < numberOfNewComments; startIndex++) {
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:startIndex inSection:commentsSection];
            [commentsIndexs addObject:indexPath];
        }

        BOOL insertLoadComments = previousComments.count == 0 && self.viewModel.notShownCommentCount > 0;

        [self.tableView beginUpdates];

        if(insertLoadComments){
            [self.tableView insertRowsAtIndexPaths:@[loadCommentsIndexPath] withRowAnimation:UITableViewRowAnimationTop];
        }

        [self.tableView insertRowsAtIndexPaths:commentsIndexs withRowAnimation:UITableViewRowAnimationTop];

        [self.tableView endUpdates];
    }
}

-(void) showAllComments {

    if(!self.viewModel.showAllComments){return;}

    NSMutableArray *newIndexPaths = [[NSMutableArray alloc]init];
    //Create indexpaths to insert
    [self.viewModel.allComments enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if(idx < self.viewModel.notShownCommentCount){
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
            return self.viewModel.latestComments.count;
        }
    }
    if((messageSections)section == loadCommentsSection){
        return (self.viewModel.showAllComments || self.viewModel.notShownCommentCount < 1 )? 0 : 1;
    }
    return 0;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return messageSectionsCount;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    TTTTimeIntervalFormatter *timeInterValFormatter = [[TTTTimeIntervalFormatter alloc] init];

    if((messageSections)indexPath.section == messageSection){

        CHDMessage *message = self.viewModel.message;
        CHDEnvironment *environment = self.viewModel.environment;
        CHDUser *user = self.viewModel.user;
        CHDGroup *group = [environment groupWithId:message.groupId];
        CHDPeerUser *authorUser = [environment userWithId: message.authorId siteId:message.siteId];
        CHDSite *authorSite = [user siteWithId:authorUser.siteId];

        CHDMessageTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kMessageCellIdentifier forIndexPath:indexPath];
        cell.titleLabel.text = message.title;
        cell.groupLabel.text = group? group.name : @"";
        cell.createdDateLabel.text = message.changeDate? [timeInterValFormatter stringForTimeIntervalFromDate:[NSDate new] toDate:message.changeDate] : @"";
        cell.messageLabel.text = message.body;
        cell.parishLabel.text = (user.sites.count > 1)? authorSite ? authorSite.name : @"" : @"";
        cell.userNameLabel.text = authorUser? authorUser.name : @"";
        cell.profileImageView.image = authorUser? [UIImage imageWithData:[NSData dataWithContentsOfURL:authorUser.pictureURL]] : nil;

        return cell;
    }
    if((messageSections)indexPath.section == commentsSection){
        CHDMessageCommentsTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kMessageCommentsCellIdentifier forIndexPath:indexPath];

        CHDComment* comment = (self.viewModel.showAllComments)? self.viewModel.allComments[indexPath.row] : self.viewModel.latestComments[indexPath.row];
        CHDPeerUser *author = [self.viewModel.environment userWithId:comment.authorId siteId:self.viewModel.message.siteId];

        cell.messageLabel.text = comment.body;
        cell.createdDateLabel.text = comment.createdDate? [timeInterValFormatter stringForTimeIntervalFromDate:[NSDate new] toDate:comment.createdDate] : @"";
        cell.profileImageView.image = author? [UIImage imageWithData:[NSData dataWithContentsOfURL:author.pictureURL]] : nil;
        cell.userNameLabel.text = ![comment.authorName isEqualToString:@""]? comment.authorName : author? author.name : @"";
        cell.canEdit = comment.canEdit || comment.canDelete;


        [self rac_liftSelector:@selector(editCommentAction:) withSignals:[[[cell.editButton rac_signalForControlEvents:UIControlEventTouchUpInside] map:^id(id sender) {
            return RACTuplePack(sender, comment);
        }] takeUntil:cell.rac_prepareForReuseSignal], nil];

        return cell;
    }
    if((messageSections)indexPath.section == loadCommentsSection){
        CHDMessageLoadCommentsTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kMessageLoadCommentsCellIdentifier forIndexPath:indexPath];
        cell.messageLabel.text = NSLocalizedString(@"Load more comments", @"");
        cell.countLabel.text = [NSString stringWithFormat:@"(%@)", @(self.viewModel.notShownCommentCount)];
        return cell;
    }
    return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if((messageSections)indexPath.section == loadCommentsSection){
        self.viewModel.showAllComments = YES;
    }
}
#pragma mark - Actions
-(void) editCommentAction: (RACTuple*) tuple {
    CHDComment *comment = tuple.second;

    UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:nil delegate:nil cancelButtonTitle:NSLocalizedString(@"Cancel", @"") destructiveButtonTitle:nil otherButtonTitles:NSLocalizedString(@"Edit", @""), NSLocalizedString(@"Delete", @""), nil];
    sheet.destructiveButtonIndex = 1;
    [self rac_liftSelector:@selector(editCommentSheetAction:) withSignals:[[sheet.rac_buttonClickedSignal ignore:@(sheet.cancelButtonIndex)] map:^id(NSNumber *buttonIndex) {
        return RACTuplePack(buttonIndex, comment);
    }], nil];
    [sheet showInView:self.view];
}

-(void) editCommentSheetAction: (RACTuple*) tuple {
    //This is called when an action within the action sheet is chosen
    RACTupleUnpack(NSNumber *buttonIndex, CHDComment *comment) = tuple;

    if(buttonIndex.integerValue == 0){
        //edit
        NSLog(@"Edit comment %@", comment.body);
        self.viewModel.commentEdit = comment;
    }else if(buttonIndex.integerValue == 1){
        //Delete
        NSLog(@"Delete comment %@", comment.body);
        [self.viewModel commentDeleteWithComment:comment];
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
    if (![self.replyView.replyTextView isFirstResponder]){
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

    double duration = [notification.userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    UIViewAnimationOptions options = (UIViewAnimationOptions)[notification.userInfo[UIKeyboardAnimationCurveUserInfoKey] integerValue];// | UIViewAnimationOptionBeginFromCurrentState;

    self.replyView.textViewMaxHeight = (NSInteger)(self.view.frame.size.height - kbSize.height);

        [UIView animateWithDuration:duration delay:0.0 options:options animations:^{
            [self.replyView layoutIfNeeded];
            self.tableView.contentInset = UIEdgeInsetsMake(0, 0, kbSize.height + 50, 0);
        }                completion:^(BOOL finished) {
            if (finished) {
                if(self.viewModel.commentEdit == nil) {
                    NSInteger rowCount = [self tableView:self.tableView numberOfRowsInSection:commentsSection];
                    if (rowCount > 0) {
                        NSInteger lastIndex = rowCount - 1;
                        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:lastIndex inSection:commentsSection];

                        [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionNone animated:YES];
                    }
                }
            }
        }];


    self.movingKeyboard = NO;
}

-(void) chd_willHideKeyboard: (NSNotification*) notification {
    self.replyBottomConstraint.offset(0);
    [self.replyView setNeedsLayout];

    double duration = [notification.userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    UIViewAnimationOptions options = (UIViewAnimationOptions)[notification.userInfo[UIKeyboardAnimationCurveUserInfoKey] integerValue];// | UIViewAnimationOptionBeginFromCurrentState;

    self.replyView.textViewMaxHeight = (NSInteger)(self.view.frame.size.height);
    [UIView animateWithDuration:duration delay:0.0 options:options animations:^{
        [self.replyView layoutIfNeeded];
        self.tableView.contentInset = UIEdgeInsetsMake(0, 0, 50, 0);
    } completion:^(BOOL finished) {
        if(finished){
//            if(self.viewModel.commentEdit == nil) {
//                NSInteger rowCount = [self tableView:self.tableView numberOfRowsInSection:commentsSection];
//                if (rowCount > 0) {
//                    NSInteger lastIndex = rowCount - 1;
//                    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:lastIndex inSection:commentsSection];
//
//                    [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionNone animated:YES];
//                }
//            }
        }
    }];

    self.movingKeyboard = NO;
}


@end
