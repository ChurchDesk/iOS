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
#import "CHDSegmentsViewController.h"
#import "SHPKeyboardEvent.h"
#import "CHDStatusView.h"
#import "CHDSite.h"
#import "CHDPeople.h"
#import "CHDSegment.h"

typedef NS_ENUM(NSUInteger, newMessagesSections) {
    divider1Section,
    selectReceiverSection,
    selectSenderSection,
    divider2Section,
    subjectInputSection,
    messageInputSection,
    newMessagesCountSections,
};

typedef NS_ENUM(NSUInteger, newSMSSections) {
    divider3Section,
    selectSMSReceiverSection,
    divider4Section,
    messageSMSInputSection,
    newSMSCountSections,
};

static NSString* kCreateMessageDividerCell = @"createMessageDividerCell";
static NSString* kCreateMessageSelectorCell = @"createMessageSelectorCell";
static NSString* kCreateMessageTextFieldCell = @"createMessagTextFieldCell";
static NSString* kCreateMessageTextViewCell = @"createMessageTextViewCell";

@interface CHDCreateMessageMailViewController ()<UIActionSheetDelegate>
@property (nonatomic, strong) UITableView* tableView;
@property (nonatomic, strong) CHDCreateMessageMailViewModel *messageViewModel;
@property (nonatomic, strong) CHDStatusView *statusView;
@property (nonatomic, strong) UIView *receiverView;
@property (nonatomic, strong) UIButton *backgroundButton;
@property (nonatomic, strong) UILabel *textLimitLabel;
@end

@implementation CHDCreateMessageMailViewController

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem new] initWithTitle:NSLocalizedString(@"Cancel", @"") style:UIBarButtonItemStylePlain target:self action:@selector(leftBarButtonTouch)];
        UIBarButtonItem *sendButton = [[UIBarButtonItem new] initWithTitle:NSLocalizedString(@"Send", @"") style:UIBarButtonItemStylePlain target:self action:@selector(rightBarButtonTouch)];
        [sendButton setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys: [UIColor whiteColor],  NSForegroundColorAttributeName,nil] forState:UIControlStateNormal];
        [sendButton setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys: [UIColor chd_menuDarkBlue],  NSForegroundColorAttributeName,nil] forState:UIControlStateDisabled];
        self.navigationItem.rightBarButtonItem = sendButton;
    }
    return self;
}

- (void)viewDidLoad {
    self.messageViewModel = [[CHDCreateMessageMailViewModel alloc] initAsSMSorEmail:_isSMS];
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
    if ([self.messageViewModel.title length] > 0 || [self.messageViewModel.message length] > 0) {
    [self.view endEditing:YES];
    [Heap track:@"People create message: Cancel clicked"];
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@""                                                                           delegate:self
                                                    cancelButtonTitle:NSLocalizedString(@"Cancel", @"")
                                               destructiveButtonTitle:nil
                                                    otherButtonTitles:NSLocalizedString(@"Delete message", @""), NSLocalizedString(@"Finish later", @""), nil];
    actionSheet.tag = 101;
    [actionSheet showInView:self.view];
    }
    else
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
    [[self.messageViewModel sendMessage:_isSegment] subscribeError:^(NSError *error) {
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
        [Heap track:@"People message successfully sent"];
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setValue:@"" forKey:kpeopleSubjectText];
        [defaults setValue:@"" forKey:kPeopleMessageText];
        [defaults setBool:NO forKey:ktoPeopleClicked];
        [defaults setBool:YES forKey:ksuccessfulPeopleMessage];
    }];
}

-(void) sendSelectedPeopleArray: (NSArray *)selectedPeopleArray{
    _selectedPeopleArray = selectedPeopleArray;
}

-(void) saveMessageForLater{
    [[NSUserDefaults standardUserDefaults] setValue:self.messageViewModel.title forKey:kpeopleSubjectText];
    [[NSUserDefaults standardUserDefaults] setValue:self.messageViewModel.message forKey:kPeopleMessageText];
}


#pragma mark - TableView delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.view endEditing:YES];
    if((newMessagesSections)indexPath.section == selectReceiverSection && indexPath.row == 0){
        [Heap track:@"People create message to clicked"];
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:ktoPeopleClicked];
        [self saveMessageForLater];
        if (_selectedPeopleArray.count == 0) {
            [self addReceiverView];
        }
        else {
        if (_isSegment) {
            [self segmentPressed];
        }
        else{
            [self peoplePressed];
        }
        }
    }
    if(!_isSMS && (newMessagesSections)indexPath.section == selectSenderSection  && indexPath.row == 0){
        [Heap track:@"People create message: from clicked"];
        CHDSite *selectedSite = [_currentUser siteWithId:_organizationId];
        UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:NSLocalizedString(@"Select Sender", @"")                                                                           delegate:self
                                                        cancelButtonTitle:@"Cancel"
                                                        destructiveButtonTitle:nil
                                                        otherButtonTitles:_currentUser.name, selectedSite.name, nil];
        actionSheet.tag = 102;
        [actionSheet showInView:self.view];
    }
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}

-(void)peoplePressed{
    [Heap track:@"People create message: to people"];
    _isSegment = NO;
    CHDPeopleViewController *pvc = [[CHDPeopleViewController alloc] init];
    pvc.selectedPeopleArray = [NSMutableArray arrayWithArray:_selectedPeopleArray] ;
    pvc.createMessage = YES;
    pvc.delegate = self;
    pvc.title = NSLocalizedString(@"People", @"");
    if (_receiverView) {
        [self removeSendToView];
    }
    [self.navigationController pushViewController:pvc animated:YES];
}

-(void) segmentPressed{
    [Heap track:@"People create message: to segments"];
    _isSegment = YES;
    CHDSegmentsViewController *svc = [[CHDSegmentsViewController alloc] init];
    svc.selectedSegmentsArray = [NSMutableArray arrayWithArray:_selectedPeopleArray] ;
    svc.title = NSLocalizedString(@"Segments", @"");
    svc.createMessage = YES;
    svc.segmentDelegate = self;
    if (_receiverView) {
        [self removeSendToView];
    }
    [self.navigationController pushViewController:svc animated:YES];
}

-(void) removeSendToView{
    [_receiverView removeFromSuperview];
    _receiverView = nil;
    [_backgroundButton removeFromSuperview];
    _backgroundButton = nil;
}
#pragma mark - TableView datasource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (_isSMS) {
        return newSMSCountSections;
    }
    else
    return newMessagesCountSections;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    //checking if SMS or email was chosen and showing the view appropriately
    if((!_isSMS && ((newMessagesSections)indexPath.section == divider1Section || (newMessagesSections)indexPath.section == divider2Section)) || (_isSMS && ((newSMSSections)indexPath.section == divider3Section || (newSMSSections)indexPath.section == divider4Section)) ){
        CHDDividerTableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:kCreateMessageDividerCell forIndexPath:indexPath];
        return cell;
    }
    if( (!_isSMS && (newMessagesSections)indexPath.section == selectReceiverSection) || (_isSMS && (newSMSSections)indexPath.section == selectSMSReceiverSection)){
        CHDNewMessageSelectorCell* cell = [tableView dequeueReusableCellWithIdentifier:kCreateMessageSelectorCell forIndexPath:indexPath];
        cell.titleLabel.text = NSLocalizedString(@"To", @"");
        if (_selectedPeopleArray.count > 0) {
            if (_selectedPeopleArray.count == 1) {
                if (_isSegment) {
                    CHDSegment *selectedSegment = [_selectedPeopleArray firstObject];
                    cell.selectedLabel.text = selectedSegment.name;
                }
                else{
                    CHDPeople *selectedPeople = [_selectedPeopleArray firstObject];
                    cell.selectedLabel.text = selectedPeople.fullName;
                }
            }
            else{
                if (_isSegment) {
                    cell.selectedLabel.text = [NSString stringWithFormat:@"%lu %@", (unsigned long)[_selectedPeopleArray count],  NSLocalizedString(@"Segments", @"")];
                }
                else{
                    cell.selectedLabel.text = [NSString stringWithFormat:@"%lu %@", (unsigned long)[_selectedPeopleArray count],  NSLocalizedString(@"People", @"")];
                }
            }
        }
        else{
            cell.selectedLabel.text = @"";
        }
        cell.dividerLineHidden = NO;
        return cell;
    }
    if( !_isSMS && (newMessagesSections)indexPath.section == selectSenderSection){
        CHDNewMessageSelectorCell* cell = [tableView dequeueReusableCellWithIdentifier:kCreateMessageSelectorCell forIndexPath:indexPath];
        cell.titleLabel.text = NSLocalizedString(@"From", @"");
        cell.selectedLabel.text = _selectedSender;
        cell.dividerLineHidden = YES;
        return cell;
    }
    if(!_isSMS && (newMessagesSections)indexPath.section == subjectInputSection){
        CHDNewMessageTextFieldCell* cell = [tableView cellForRowAtIndexPath:indexPath]?: [tableView dequeueReusableCellWithIdentifier:kCreateMessageTextFieldCell forIndexPath:indexPath];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.textField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:NSLocalizedString(@"Subject", @"") attributes:@{NSForegroundColorAttributeName: [UIColor shpui_colorWithHexValue:0xa8a8a8]}];
        cell.textField.text = self.messageViewModel.title;
        [self.messageViewModel shprac_liftSelector:@selector(setTitle:) withSignal:[cell.textField.rac_textSignal takeUntil:cell.rac_prepareForReuseSignal]];
        return cell;
    }
    if((!_isSMS && (newMessagesSections)indexPath.section == messageInputSection) || (_isSMS && (newSMSSections)indexPath.section == messageSMSInputSection)){
        CHDNewMessageTextViewCell* cell = [tableView dequeueReusableCellWithIdentifier:kCreateMessageTextViewCell forIndexPath:indexPath];
        cell.dividerLineHidden = YES;
        cell.textView.text = self.messageViewModel.message;
        [cell textDidChange:self.messageViewModel.message];
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
    if (actionSheet.tag == 101) {
        if (buttonIndex != 2) {
            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
            [defaults setBool:NO forKey:ktoPeopleClicked];
        if (buttonIndex == 0) {
            [Heap track:@"Delete message clicked"];
            [defaults setValue:@"" forKey:kpeopleSubjectText];
            [defaults setValue:@"" forKey:kPeopleMessageText];
            //Cancel the creation of new message
            [self dismissViewControllerAnimated:YES completion:nil];
        }
        else if (buttonIndex == 1){
            [self saveMessageForLater];
            [Heap track:@"Finish later clicked"];
            [self dismissViewControllerAnimated:YES completion:nil];
        }
        }
    }
    else if (actionSheet.tag == 102){
    if (buttonIndex != 2) {
        _selectedSender = [actionSheet buttonTitleAtIndex:buttonIndex];
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:selectSenderSection];
        //cell.selectedLabel.text = [actionSheet buttonTitleAtIndex:buttonIndex];
        [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
        }
    }
}

#pragma mark - Lazy initialization

-(void) makeViews {
    [self.view addSubview:self.tableView];
    [self.view addSubview:self.textLimitLabel];
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
    
    [self.textLimitLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view).with.offset(10);
        make.centerX.equalTo(self.view);
    }];
}

-(void) makeBindings {
    if (self.isSMS) {
        self.title = NSLocalizedString(@"Create SMS", @"");
    }
    else{
        self.title = NSLocalizedString(@"Create email", @"");
    }
    self.messageViewModel.isSMS = _isSMS;
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
    RAC(self.textLimitLabel, text) = RACObserve(self.messageViewModel, textLimit);
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

-(void)addReceiverView{
    if(!_receiverView){
        [Heap track:@"Send to popup shown"];
    _backgroundButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _backgroundButton.frame = self.view.superview.frame;
    [_backgroundButton addTarget:self action:@selector(removeSendToView) forControlEvents:UIControlEventTouchUpInside];
        _backgroundButton.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.3];
    [self.view addSubview:_backgroundButton];
        
    _receiverView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 300, 300)] ;
    _receiverView.center = self.view.superview.center;
    _receiverView.userInteractionEnabled = TRUE;
    _receiverView.backgroundColor = [UIColor whiteColor];
    
    UILabel *sendToLabel = [[UILabel alloc] initWithFrame:CGRectMake ( 0, 50, 300, 50)];
    sendToLabel.font = [UIFont chd_fontWithFontWeight:CHDFontWeightMedium size:30];
    sendToLabel.text = NSLocalizedString(@"Send to..", @"");
    sendToLabel.textAlignment = NSTextAlignmentCenter;
    sendToLabel.textColor = [UIColor chd_textDarkColor];
    [_receiverView addSubview:sendToLabel];
    
    UIButton *peopleButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [peopleButton setImage:kImgButtonPeople forState:UIControlStateNormal];
    [peopleButton addTarget:self action:@selector(peoplePressed) forControlEvents:UIControlEventTouchUpInside];
    peopleButton.frame = CGRectMake ( 30, 120, 100, 100);
    [_receiverView addSubview:peopleButton];
    
    UILabel *peopleLabel = [[UILabel alloc] initWithFrame:CGRectMake ( 30, 210, 100, 20)];
    peopleLabel.font = [UIFont chd_fontWithFontWeight:CHDFontWeightMedium size:16];
    peopleLabel.text = NSLocalizedString(@"People", @"");
    peopleLabel.textAlignment = NSTextAlignmentCenter;
    peopleLabel.textColor = [UIColor chd_textDarkColor];
    [_receiverView addSubview:peopleLabel];
    
    UIButton *segmentsButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [segmentsButton setImage:kImgButtonSegments forState:UIControlStateNormal];
    [segmentsButton addTarget:self action:@selector(segmentPressed) forControlEvents:UIControlEventTouchUpInside];
    segmentsButton.frame = CGRectMake ( 170, 120, 100, 100);
    [_receiverView addSubview:segmentsButton];
    
    UILabel *segmentsLabel = [[UILabel alloc] initWithFrame:CGRectMake ( 170, 210, 100, 20)];
    segmentsLabel.font = [UIFont chd_fontWithFontWeight:CHDFontWeightMedium size:16];
    segmentsLabel.text = NSLocalizedString(@"Segments", @"");
    segmentsLabel.textAlignment = NSTextAlignmentCenter;
    segmentsLabel.textColor = [UIColor chd_textDarkColor];
    [_receiverView addSubview:segmentsLabel];
    
        _receiverView.transform = CGAffineTransformScale(CGAffineTransformIdentity, 0.001, 0.001);
        
        [self.view addSubview:_receiverView];
        
        [UIView animateWithDuration:0.3/1.5 animations:^{
            _receiverView.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1.1, 1.1);
        } completion:^(BOOL finished) {
            [UIView animateWithDuration:0.3/2 animations:^{
                _receiverView.transform = CGAffineTransformScale(CGAffineTransformIdentity, 0.9, 0.9);
            } completion:^(BOOL finished) {
                [UIView animateWithDuration:0.3/2 animations:^{
                    _receiverView.transform = CGAffineTransformIdentity;
                }];
            }];
        }];
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

-(UILabel *)textLimitLabel{
    if(!_textLimitLabel){
        _textLimitLabel = [UILabel new];
        _textLimitLabel.font = [UIFont chd_fontWithFontWeight:CHDFontWeightRegular size:15];
        _textLimitLabel.textColor = [UIColor blackColor];
        _textLimitLabel.text = @"160";
    }
    return _textLimitLabel;
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
