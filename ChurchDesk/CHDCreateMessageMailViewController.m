//
//  CHDCreateMessageMailViewController.m
//  ChurchDesk
//
//  Created by Chirag Sharma on 07/04/16.
//  Copyright © 2016 Shape A/S. All rights reserved.
//

#import <SHPNetworking/SHPAPIManager+ReactiveExtension.h>
#import "NSObject+SHPKeyboardAwareness.h"
#import "CHDDividerTableViewCell.h"
#import "CHDNewMessageSelectorCell.h"
#import "CHDNewMessageTextViewCell.h"
#import "CHDNewMessageTextFieldCell.h"
#import "CHDCreateMessageMailViewController.h"
#import "CHDCreateMessageMailViewModel.h"
#import "CHDPeopleViewController.h"
#import "SHPKeyboardEvent.h"
#import "CHDStatusView.h"
#import "CHDSite.h"
#import "CHDPeople.h"

typedef NS_ENUM(NSUInteger, newMessagesSections) {
    divider1Section,
    selectReceiverSection,
    selectSenderSection,
    divider2Section,
    subjectInputSection,
    messageInputSection,
    newMessagesCountSections,
};

static NSString* kCreateMessageDividerCell = @"createMessageDividerCell";
static NSString* kCreateMessageSelectorCell = @"createMessageSelectorCell";
static NSString* kCreateMessageTextFieldCell = @"createMessagTextFieldCell";
static NSString* kCreateMessageTextViewCell = @"createMessageTextViewCell";

@interface CHDCreateMessageMailViewController ()<UIActionSheetDelegate>
@property (nonatomic, strong) UITableView* tableView;
@property (nonatomic, strong) CHDCreateMessageMailViewModel *messageViewModel;
@property (nonatomic, strong) CHDStatusView *statusView;
@end

@implementation CHDCreateMessageMailViewController

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.title = NSLocalizedString(@"Create email", @"");
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem new] initWithTitle:NSLocalizedString(@"Cancel", @"") style:UIBarButtonItemStylePlain target:self action:@selector(leftBarButtonTouch)];
        UIBarButtonItem *sendButton = [[UIBarButtonItem new] initWithTitle:NSLocalizedString(@"Send", @"") style:UIBarButtonItemStylePlain target:self action:@selector(rightBarButtonTouch)];
        [sendButton setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys: [UIColor whiteColor],  NSForegroundColorAttributeName,nil] forState:UIControlStateNormal];
        [sendButton setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys: [UIColor chd_menuDarkBlue],  NSForegroundColorAttributeName,nil] forState:UIControlStateDisabled];
        self.navigationItem.rightBarButtonItem = sendButton;
        self.messageViewModel = [CHDCreateMessageMailViewModel new];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self makeViews];
    [self makeConstraints];
    [self makeBindings];
    if (_selectedSender == nil) {
        _selectedSender = _currentUser.name;
    }
    // Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:YES];
    [self.tableView reloadData];
    self.messageViewModel.selectedPeople = _selectedPeopleArray;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Bar button handlers
-(void) leftBarButtonTouch{
    [self.view endEditing:YES];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setBool:NO forKey:ktoPeopleClicked];
    [defaults setValue:@"" forKey:kpeopleSubjectText];
    [defaults setValue:@"" forKey:kPeopleMessageText];
    //Cancel the creation of new message
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void) rightBarButtonTouch{
    [self.view endEditing:YES];
    self.messageViewModel.selectedPeople = _selectedPeopleArray;
    self.messageViewModel.organizationId = _organizationId;
    if ([_selectedSender isEqualToString:_currentUser.name]) {
        self.messageViewModel.from = @"user";
    }
    else
        self.messageViewModel.from = @"church";
    
    //create a new message
    [self didChangeSendingStatus:CHDStatusViewProcessing];
    [[self.messageViewModel sendMessage] subscribeError:^(NSError *error) {
        SHPHTTPResponse *response = error.userInfo[SHPAPIManagerReactiveExtensionErrorResponseKey];
        switch(response.statusCode){
            case 406:
            case 400:
                self.statusView.errorText = NSLocalizedString(@"An unknown error occured, please try again", @"");
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
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setValue:@"" forKey:kpeopleSubjectText];
        [defaults setValue:@"" forKey:kPeopleMessageText];
        [defaults setBool:NO forKey:ktoPeopleClicked];
        [defaults setBool:YES forKey:ksuccessfulPeopleMessage];
    }];
}

#pragma mark - TableView delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.view endEditing:YES];
    if((newMessagesSections)indexPath.section == selectReceiverSection && indexPath.row == 0){
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:ktoPeopleClicked];
        [[NSUserDefaults standardUserDefaults] setValue:self.messageViewModel.title forKey:kpeopleSubjectText];
        [[NSUserDefaults standardUserDefaults] setValue:self.messageViewModel.message forKey:kPeopleMessageText];
        [self dismissViewControllerAnimated:YES completion:nil];
    }
    
    if((newMessagesSections)indexPath.section == selectSenderSection  && indexPath.row == 0){
        CHDSite *selectedSite = [_currentUser siteWithId:_organizationId];
        UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:NSLocalizedString(@"Select Sender", @"")                                                                           delegate:self
                                                        cancelButtonTitle:@"Cancel"
                                                        destructiveButtonTitle:nil
                                                        otherButtonTitles:_currentUser.name, selectedSite.name, nil];
        [actionSheet showInView:self.view];
    }
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}

#pragma mark - TableView datasource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return newMessagesCountSections;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if((newMessagesSections)indexPath.section == divider1Section || (newMessagesSections)indexPath.section == divider2Section){
        CHDDividerTableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:kCreateMessageDividerCell forIndexPath:indexPath];
        return cell;
    }
    if((newMessagesSections)indexPath.section == selectReceiverSection){
        CHDNewMessageSelectorCell* cell = [tableView dequeueReusableCellWithIdentifier:kCreateMessageSelectorCell forIndexPath:indexPath];
        cell.titleLabel.text = NSLocalizedString(@"To", @"");
        if (_selectedPeopleArray.count > 0) {
            if (_selectedPeopleArray.count == 1) {
                CHDPeople *selectedPeople = [_selectedPeopleArray firstObject];
                cell.selectedLabel.text = selectedPeople.fullName;
            }
            else{
            cell.selectedLabel.text = [NSString stringWithFormat:@"%d %@", [_selectedPeopleArray count],  NSLocalizedString(@"People", @"")];
            }
        }
        else{
            cell.selectedLabel.text = @"";
        }
        cell.dividerLineHidden = NO;
        return cell;
    }
    if((newMessagesSections)indexPath.section == selectSenderSection){
        CHDNewMessageSelectorCell* cell = [tableView dequeueReusableCellWithIdentifier:kCreateMessageSelectorCell forIndexPath:indexPath];
        cell.titleLabel.text = NSLocalizedString(@"From", @"");
        cell.selectedLabel.text = _selectedSender;
        cell.dividerLineHidden = YES;
        return cell;
    }
    if((newMessagesSections)indexPath.section == subjectInputSection){
        CHDNewMessageTextFieldCell* cell = [tableView cellForRowAtIndexPath:indexPath]?: [tableView dequeueReusableCellWithIdentifier:kCreateMessageTextFieldCell forIndexPath:indexPath];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.textField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:NSLocalizedString(@"Subject", @"") attributes:@{NSForegroundColorAttributeName: [UIColor shpui_colorWithHexValue:0xa8a8a8]}];
        cell.textField.text = self.messageViewModel.title;
        [self.messageViewModel shprac_liftSelector:@selector(setTitle:) withSignal:[cell.textField.rac_textSignal takeUntil:cell.rac_prepareForReuseSignal]];
        return cell;
    }
    if((newMessagesSections)indexPath.section == messageInputSection){
        CHDNewMessageTextViewCell* cell = [tableView dequeueReusableCellWithIdentifier:kCreateMessageTextViewCell forIndexPath:indexPath];
        cell.dividerLineHidden = YES;
        cell.textView.text = self.messageViewModel.message;
        cell.tableView = tableView;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        [self.messageViewModel shprac_liftSelector:@selector(setMessage:) withSignal:[cell.textView.rac_textSignal takeUntil:cell.rac_prepareForReuseSignal]];
        return cell;
    }
    return nil;
}


#pragma mark - Action Sheet delgate methods
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex != 2) {
       // CHDNewMessageSelectorCell* cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:1]];
        _selectedSender = [actionSheet buttonTitleAtIndex:buttonIndex];
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:selectSenderSection];
        //cell.selectedLabel.text = [actionSheet buttonTitleAtIndex:buttonIndex];
        [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
        
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
    
    //put text if exists
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if ([defaults objectForKey:kpeopleSubjectText]) {
        self.messageViewModel.title = [defaults objectForKey:kpeopleSubjectText];
    }
    if ([defaults objectForKey:kPeopleMessageText]) {
        self.messageViewModel.message = [defaults objectForKey:kPeopleMessageText];
    }
   
    //Change the state of the send button
    RAC(self.navigationItem.rightBarButtonItem, enabled) = RACObserve(self.messageViewModel, canSendMessage);
}

-(void) didChangeSendingStatus: (CHDStatusViewStatus) status {
    self.statusView.currentStatus = status;
    
    if(status == CHDStatusViewProcessing){
        self.statusView.show = YES;
        return;
    }
    if(status == CHDStatusViewSuccess){
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:knewMessageBool];
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
        [_tableView registerClass:[CHDDividerTableViewCell class] forCellReuseIdentifier:kCreateMessageDividerCell];
        [_tableView registerClass:[CHDNewMessageSelectorCell class] forCellReuseIdentifier:kCreateMessageSelectorCell];
        [_tableView registerClass:[CHDNewMessageTextViewCell class] forCellReuseIdentifier:kCreateMessageTextViewCell];
        [_tableView registerClass:[CHDNewMessageTextFieldCell class] forCellReuseIdentifier:kCreateMessageTextFieldCell];
        
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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
