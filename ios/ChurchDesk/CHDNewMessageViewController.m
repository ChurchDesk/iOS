//
//  CHDNewMessageViewController.m
//  ChurchDesk
//
//  Created by Jakob Vinther-Larsen on 26/02/15.
//  Copyright (c) 2015 Shape A/S. All rights reserved.
//

#import <SHPNetworking/SHPAPIManager+ReactiveExtension.h>
#import "CHDNewMessageViewController.h"
#import "CHDDividerTableViewCell.h"
#import "CHDNewMessageSelectorCell.h"
#import "CHDNewMessageTextViewCell.h"
#import "CHDNewMessageTextFieldCell.h"
#import "NSObject+SHPKeyboardAwareness.h"
#import "SHPKeyboardEvent.h"
#import "CHDListSelectorViewController.h"
#import "CHDNewMessageViewModel.h"
#import "CHDStatusView.h"

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
@property (nonatomic, strong) CHDNewMessageViewModel *messageViewModel;
@property (nonatomic, strong) CHDStatusView *statusView;
@end

@implementation CHDNewMessageViewController

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.title = NSLocalizedString(@"New message", @"");
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem new] initWithTitle:NSLocalizedString(@"Cancel", @"") style:UIBarButtonItemStylePlain target:self action:@selector(leftBarButtonTouch)];
        UIBarButtonItem *sendButton = [[UIBarButtonItem new] initWithTitle:NSLocalizedString(@"Send", @"") style:UIBarButtonItemStylePlain target:self action:@selector(rightBarButtonTouch)];
        [sendButton setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys: [UIColor whiteColor],  NSForegroundColorAttributeName,nil] forState:UIControlStateNormal];
        [sendButton setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys: [UIColor chd_menuDarkBlue],  NSForegroundColorAttributeName,nil] forState:UIControlStateDisabled];
        self.navigationItem.rightBarButtonItem = sendButton;
        self.messageViewModel = [CHDNewMessageViewModel new];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self makeViews];
    [self makeConstraints];
    [self makeBindings];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.tableView reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Bar button handlers
-(void) leftBarButtonTouch{
    [self.view endEditing:YES];
    
    //Cancel the creation of new message
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void) rightBarButtonTouch{
    [self.view endEditing:YES];
    //create a new message
    [self didChangeSendingStatus:CHDStatusViewProcessing];
    [[self.messageViewModel sendMessage] subscribeError:^(NSError *error) {
        SHPHTTPResponse *response = error.userInfo[SHPAPIManagerReactiveExtensionErrorResponseKey];
        switch(response.statusCode){
            case 406:
            case 400:
                self.statusView.errorText = NSLocalizedString(@"Please check message content", @"");
                break;
            case 401:
                self.statusView.errorText = NSLocalizedString(@"Unauthorized. Please login again", @"");
                break;
            case 403:
                self.statusView.errorText = NSLocalizedString(@"Access denied", @"");
                break;

            case 429:
                self.statusView.errorText = NSLocalizedString(@"Too many requests, try again later", @"");
                break;
            default:
                self.statusView.errorText = NSLocalizedString(@"There was a problem, please try again", @"");
        }
        [self didChangeSendingStatus:CHDStatusViewError];
    } completed:^{
        [self didChangeSendingStatus:CHDStatusViewSuccess];
    }];
}

#pragma mark - TableView delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if((newMessagesSections)indexPath.section == selectParishSection && indexPath.row == 0){
        if(self.messageViewModel.selectableSites.count > 0) {
            CHDListSelectorViewController *selectorViewController = [[CHDListSelectorViewController new] initWithSelectableItems:self.messageViewModel.selectableSites];
            selectorViewController.title = NSLocalizedString(@"Parish", @"");
            selectorViewController.selectMultiple = NO;
            selectorViewController.selectorDelegate = self;

            [self.navigationController pushViewController:selectorViewController animated:YES];
        }
    }

    if((newMessagesSections)indexPath.section == selectGroupSection  && indexPath.row == 0){
        if(self.messageViewModel.selectableGroups.count > 0) {
            CHDListSelectorViewController *selectorViewController = [[CHDListSelectorViewController new] initWithSelectableItems:self.messageViewModel.selectableGroups];
            selectorViewController.title = NSLocalizedString(@"Group", @"");
            selectorViewController.selectMultiple = NO;
            selectorViewController.selectorDelegate = self;
            [self.navigationController pushViewController:selectorViewController animated:YES];
        }
    }
}

#pragma mark - TableView datasource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return newMessagesCountSections;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    newMessagesSections sectionType = section;
    if(sectionType == divider1Section){
        return (self.messageViewModel.canSelectGroup || self.messageViewModel.canSelectParish);
    }
    if(sectionType == selectGroupSection){
        return self.messageViewModel.canSelectGroup;
    }
    if(sectionType == selectParishSection){
        return self.messageViewModel.canSelectParish;
    }
    if( (sectionType == devider2Section) || (sectionType == titleInputSection) || (sectionType == messageInputSection)){
        return 1;
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    if((newMessagesSections)indexPath.section == divider1Section || (newMessagesSections)indexPath.section == devider2Section){
        CHDDividerTableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:kNewMessageDividerCell forIndexPath:indexPath];
        return cell;
    }
    if((newMessagesSections)indexPath.section == selectParishSection){
        CHDNewMessageSelectorCell* cell = [tableView dequeueReusableCellWithIdentifier:kNewMessageSelectorCell forIndexPath:indexPath];
        cell.titleLabel.text = NSLocalizedString(@"Parish", @"");
        RAC(cell.selectedLabel, text) = [RACObserve(self.messageViewModel, selectedParishName) takeUntil: cell.rac_prepareForReuseSignal];

        //Only show the dividing line if groups can be selected
        cell.dividerLineHidden = !self.messageViewModel.canSelectGroup;
        return cell;
    }
    if((newMessagesSections)indexPath.section == selectGroupSection){
        CHDNewMessageSelectorCell* cell = [tableView dequeueReusableCellWithIdentifier:kNewMessageSelectorCell forIndexPath:indexPath];
        cell.titleLabel.text = NSLocalizedString(@"Group", @"");
        RAC(cell.selectedLabel, text) = [RACObserve(self.messageViewModel, selectedGroupName) takeUntil: cell.rac_prepareForReuseSignal];
        cell.dividerLineHidden = YES;
        return cell;
    }
    if((newMessagesSections)indexPath.section == titleInputSection){
        CHDNewMessageTextFieldCell* cell = [tableView dequeueReusableCellWithIdentifier:kNewMessageTextFieldCell forIndexPath:indexPath];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        RAC(self.messageViewModel, title) = [cell.textField.rac_textSignal takeUntil:cell.rac_prepareForReuseSignal];
        return cell;
    }
    if((newMessagesSections)indexPath.section == messageInputSection){
        CHDNewMessageTextViewCell* cell = [tableView dequeueReusableCellWithIdentifier:kNewMessageTextViewCell forIndexPath:indexPath];
        cell.dividerLineHidden = YES;
        cell.tableView = tableView;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;

        RAC(self.messageViewModel, message) = [cell.textView.rac_textSignal takeUntil:cell.rac_prepareForReuseSignal];
        return cell;
    }
    return nil;
}

#pragma mark - Selector Delegate

- (void)chdListSelectorDidSelect:(CHDListSelectorConfigModel *)selection {
    if([selection.refObject isKindOfClass:[CHDGroup class] ]){
        self.messageViewModel.selectedGroup = (CHDGroup *)selection.refObject;
    }

    if([selection.refObject isKindOfClass:[CHDSite class] ]){
        self.messageViewModel.selectedSite = (CHDSite *)selection.refObject;
    }
}


#pragma mark - Lazy initialization

-(void) makeViews {
    [self.view addSubview:self.tableView];
    
    self.statusView = [[CHDStatusView alloc] init];
    self.statusView.successText = NSLocalizedString(@"Your message was sent", @"");
    self.statusView.processingText = NSLocalizedString(@"Sending message..", @"");
    self.statusView.autoHideOnSuccessAfterTime = 0;
    self.statusView.autoHideOnErrorAfterTime = 0;
}

-(void) makeConstraints {
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
}

-(void) makeBindings {
    [self rac_liftSelector:@selector(chd_willToggleKeyboard:) withSignals:[self shp_keyboardAwarenessSignal], nil];

    //Change the state of the send button
    RAC(self.navigationItem.rightBarButtonItem, enabled) = RACObserve(self.messageViewModel, canSendMessage);

    [self.tableView shprac_liftSelector:@selector(reloadData) withSignal:[RACSignal merge:@[RACObserve(self.messageViewModel, canSelectGroup), RACObserve(self.messageViewModel, canSelectParish)]]];
}

-(void) didChangeSendingStatus: (CHDStatusViewStatus) status {
    self.statusView.currentStatus = status;

    if(status == CHDStatusViewProcessing){
        self.statusView.show = YES;
        return;
    }
    if(status == CHDStatusViewSuccess){
        self.statusView.show = YES;
        double delayInSeconds = 2.f;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            self.statusView.show = NO;
            [self dismissViewControllerAnimated:YES completion:nil];
        });
        return;
    }
    if(status == CHDStatusViewError){
        self.statusView.show = YES;
        double delayInSeconds = 2.f;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            self.statusView.show = NO;
        });
        return;
    }
    if(status == CHDStatusViewHidden){
        self.statusView.show = NO;
        return;
    }
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
        _tableView.delegate = self;
    }
    return _tableView;
}

#pragma mark - Keyboard

-(void) chd_willToggleKeyboard: (SHPKeyboardEvent*) keyboardEvent{
    CGFloat offset = 0;
    switch (keyboardEvent.keyboardEventType) {
        case SHPKeyboardEventTypeShow:

            //Set content inset
            self.tableView.contentInset = UIEdgeInsetsMake(0, 0, keyboardEvent.keyboardFrame.size.height, 0);

            // Keyboard will appear. Calculate the new offset from the provided offset
            offset = self.tableView.contentOffset.y - keyboardEvent.requiredViewOffset;

            // Save the current view offset into the event to retrieve it later
            keyboardEvent.originalOffset = self.tableView.contentOffset.y;

            break;
        case SHPKeyboardEventTypeHide:
            self.tableView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0);
            // Keyboard will hide. Reset view offset to its state before keyboard appeared
            offset = keyboardEvent.originalOffset;

            break;
        default:
            break;
    }

    [UIView animateWithDuration:keyboardEvent.keyboardAnimationDuration
                          delay:0
                        options:keyboardEvent.keyboardAnimationOptionCurve
                     animations:^{
                         self.tableView.contentOffset = CGPointMake(self.tableView.contentOffset.x, offset);
                     } completion:nil];
}

@end
