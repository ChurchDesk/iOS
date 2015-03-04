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
@end

static NSString* kMessageCommentsCellIdentifier = @"messageCommentsCell";
static NSString* kMessageLoadCommentsCellIdentifier = @"messageLoadCommentsCell";
static NSString* kMessageCellIdentifier = @"messageCell";

@implementation CHDMessageViewController
- (instancetype)init
{
    self = [super init];
    if (self) {
        self.view.backgroundColor = [UIColor whiteColor];
        self.title = NSLocalizedString(@"Message", @"");

        //Setup bindings for handling keyboard show/hide and drag in tableview
        [self rac_liftSelector:@selector(chd_willShowKeyboard:) withSignals:[[NSNotificationCenter defaultCenter] rac_addObserverForName:UIKeyboardWillShowNotification object:nil], nil];
        [self rac_liftSelector:@selector(chd_willHideKeyboard:) withSignals:[[NSNotificationCenter defaultCenter] rac_addObserverForName:UIKeyboardWillHideNotification object:nil], nil];
        [self rac_liftSelector:@selector(chd_didChangeKeyboardFrame:) withSignals:[[NSNotificationCenter defaultCenter] rac_addObserverForName:CHDInputAccessoryViewKeyboardFrameDidChangeNotification object:nil], nil];
    }
    return self;
}

#pragma mark - ViewController methods
- (void)viewDidLoad {
    [super viewDidLoad];
    [self makeViews];
    [self makeConstraints];
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

#pragma mark - TableView Delegates

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if((messageSections)section == messageSection){
        return 1;
    }
    if((messageSections)section == commentsSection){
        return 1;
    }
    if((messageSections)section == loadCommentsSection){
        return 1;
    }
    return 0;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return messageSectionsCount;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if((messageSections)indexPath.section == messageSection){
        CHDMessageTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kMessageCellIdentifier forIndexPath:indexPath];
        cell.titleLabel.text = @"Title";
        cell.groupLabel.text = @"Group";
        cell.createdDateLabel.text = @"1 day ago";
        cell.messageLabel.text = @"Um dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum.";
        cell.parishLabel.text = @"Parish";
        cell.userNameLabel.text = @"Username";
        //cell.profileImageView.image =
        return cell;
    }
    if((messageSections)indexPath.section == commentsSection){
        CHDMessageCommentsTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kMessageCommentsCellIdentifier forIndexPath:indexPath];
        cell.messageLabel.text = @"Nemo enim ipsam voluptatem quia voluptas sit aspernatur aut odit aut fugit, sed quia consequuntur magni dolores eos qui ratione. Sed quia consequuntur magni dolores.";
        cell.createdDateLabel.text = @"5 hours ago";
        //cell.profileImageView.image =
        cell.userNameLabel.text = @"Arren Mulvaney";

        return cell;
    }
    if((messageSections)indexPath.section == loadCommentsSection){
        CHDMessageLoadCommentsTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kMessageLoadCommentsCellIdentifier forIndexPath:indexPath];
        cell.messageLabel.text = NSLocalizedString(@"Load more comments", @"");
        cell.countLabel.text = @"(32)";

        return cell;
    }
    return nil;
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
