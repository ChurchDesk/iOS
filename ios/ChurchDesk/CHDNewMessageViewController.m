//
//  CHDNewMessageViewController.m
//  ChurchDesk
//
//  Created by Jakob Vinther-Larsen on 26/02/15.
//  Copyright (c) 2015 Shape A/S. All rights reserved.
//

#import "CHDNewMessageViewController.h"
#import "CHDDividerTableViewCell.h"
#import "CHDNewMessageSelectorCell.h"
#import "CHDNewMessageTextViewCell.h"
#import "CHDNewMessageTextFieldCell.h"

typedef NS_ENUM(NSUInteger, newMessagesSections) {
    divider1Section,
    selectParishSection,
    selectGroupSection,
    devider2Section,
    titleInputSection,
    messageInputSection,
    newMessagesCountSections,
};

static NSString* kNewMessageDividerCell = @"newMessageDeviderCell";
static NSString* kNewMessageSelectorCell = @"newMessageSelectorCell";
static NSString* kNewMessageTextFieldCell = @"newMessagTextFieldCell";
static NSString* kNewMessageTextViewCell = @"newMessageTextViewCell";

@interface CHDNewMessageViewController ()
@property (nonatomic, strong) UITableView* tableView;
@end

@implementation CHDNewMessageViewController

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.title = NSLocalizedString(@"New message", @"");
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem new] initWithTitle:NSLocalizedString(@"Cancel", @"") style:UIBarButtonItemStylePlain target:self action:@selector(leftBarButtonTouch)];
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem new] initWithTitle:NSLocalizedString(@"Send", @"") style:UIBarButtonItemStylePlain target:self action:@selector(rightBarButtonTouch)];

        [self rac_liftSelector:@selector(chd_willShowKeyboard:) withSignals:[[NSNotificationCenter defaultCenter] rac_addObserverForName:UIKeyboardWillShowNotification object:nil], nil];
        [self rac_liftSelector:@selector(chd_willHideKeyboard:) withSignals:[[NSNotificationCenter defaultCenter] rac_addObserverForName:UIKeyboardWillHideNotification object:nil], nil];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    [self makeViews];
    [self makeConstraints];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Bar button handlers
-(void) leftBarButtonTouch{
    //Cancel the creation of new message
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void) rightBarButtonTouch{
    //create a new message
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - TableView delegate

#pragma mark - TableView datasource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return newMessagesCountSections;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    if((newMessagesSections)indexPath.row == divider1Section || (newMessagesSections)indexPath.row == devider2Section){
        CHDDividerTableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:kNewMessageDividerCell forIndexPath:indexPath];
        return cell;
    }
    if((newMessagesSections)indexPath.row == selectParishSection){
        CHDNewMessageSelectorCell* cell = [tableView dequeueReusableCellWithIdentifier:kNewMessageSelectorCell forIndexPath:indexPath];
        cell.titleLabel.text = NSLocalizedString(@"Parish", @"");
        cell.selectedLabel.text = @"Last used";
        return cell;
    }
    if((newMessagesSections)indexPath.row == selectGroupSection){
        CHDNewMessageSelectorCell* cell = [tableView dequeueReusableCellWithIdentifier:kNewMessageSelectorCell forIndexPath:indexPath];
        cell.titleLabel.text = NSLocalizedString(@"Group", @"");
        cell.selectedLabel.text = @"Last used";
        cell.dividerLineHidden = YES;
        return cell;
    }
    if((newMessagesSections)indexPath.row == titleInputSection){
        CHDNewMessageTextFieldCell* cell = [tableView dequeueReusableCellWithIdentifier:kNewMessageTextFieldCell forIndexPath:indexPath];

        return cell;
    }
    if((newMessagesSections)indexPath.row == messageInputSection){
        CHDNewMessageTextViewCell* cell = [tableView dequeueReusableCellWithIdentifier:kNewMessageTextViewCell forIndexPath:indexPath];
        cell.dividerLineHidden = YES;
        cell.tableView = tableView;

        return cell;
    }
    return nil;
}


#pragma mark - Lazy initialization

-(void) makeViews {
    [self.view addSubview:self.tableView];
}

-(void) makeConstraints {
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
}

-(UITableView*)tableView {
    if(!_tableView){
        _tableView = [UITableView new];
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.backgroundView.backgroundColor = [UIColor chd_lightGreyColor];
        _tableView.backgroundColor = [UIColor whiteColor];
        _tableView.rowHeight = UITableViewAutomaticDimension;
        _tableView.estimatedRowHeight = 44;
        [_tableView registerClass:[CHDDividerTableViewCell class] forCellReuseIdentifier:kNewMessageDividerCell];
        [_tableView registerClass:[CHDNewMessageSelectorCell class] forCellReuseIdentifier:kNewMessageSelectorCell];
        [_tableView registerClass:[CHDNewMessageTextViewCell class] forCellReuseIdentifier:kNewMessageTextViewCell];
        [_tableView registerClass:[CHDNewMessageTextFieldCell class] forCellReuseIdentifier:kNewMessageTextFieldCell];

        _tableView.dataSource = self;
    }
    return _tableView;
}

#pragma mark - Keyboard
-(void) chd_willShowKeyboard: (NSNotification*) notification {
    CGSize kbSize = [notification.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue].size;

    //Set content inset
    self.tableView.contentInset = UIEdgeInsetsMake(0, 0, kbSize.height, 0);
}

-(void) chd_willHideKeyboard: (NSNotification*) notification {
    //Set content inset
    self.tableView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0);
}

@end
