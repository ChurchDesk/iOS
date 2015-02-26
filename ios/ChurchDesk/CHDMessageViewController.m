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
@property (nonatomic, strong) MASConstraint *tableViewEdge;
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

        //self.replyView.replyTextView.resignFirstResponder;

        [[[NSNotificationCenter defaultCenter] rac_addObserverForName:UIKeyboardWillShowNotification object:nil]
            subscribeNext:^(NSNotification* notification) {
                CGSize kbSize = [notification.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue].size;

                self.tableViewEdge.insets(UIEdgeInsetsMake(0, 0, kbSize.height + 50, 0));

                self.replyBottomConstraint.offset(-kbSize.height);
                [self.replyView setNeedsLayout];

                [UIView beginAnimations:nil context:NULL];
                [UIView setAnimationDuration:[notification.userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue]];
                [UIView setAnimationCurve:[notification.userInfo[UIKeyboardAnimationCurveUserInfoKey] integerValue]];
                [UIView setAnimationBeginsFromCurrentState:YES];

                [self.replyView layoutIfNeeded];

                [UIView commitAnimations];
            }
        ];

        [[[NSNotificationCenter defaultCenter] rac_addObserverForName:UIKeyboardWillHideNotification object:nil]
            subscribeNext:^(NSNotification* notification) {

                self.tableViewEdge.insets(UIEdgeInsetsMake(0, 0, 50, 0));

                self.replyBottomConstraint.offset(0);
                [self.replyView setNeedsLayout];

                [UIView beginAnimations:nil context:NULL];
                [UIView setAnimationDuration:[notification.userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue]];
                [UIView setAnimationCurve:[notification.userInfo[UIKeyboardAnimationCurveUserInfoKey] integerValue]];
                [UIView setAnimationBeginsFromCurrentState:YES];

                [self.replyView layoutIfNeeded];

                [UIView commitAnimations];
            }
        ];
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
        self.tableViewEdge = make.edges.equalTo(containerView).insets(UIEdgeInsetsMake(0, 0, 50, 0));
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
        //_tableView.contentInset = UIEdgeInsetsMake(0, 0, 50, 0);
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

/*- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewAutomaticDimension;
}*/

@end
