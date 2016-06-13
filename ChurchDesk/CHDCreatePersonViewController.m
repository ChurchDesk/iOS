//
//  CHDCreatePersonViewController.m
//  ChurchDesk
//
//  Created by Chirag Sharma on 03/06/16.
//  Copyright © 2016 ChurchDesk ApS. All rights reserved.
//

#import "CHDCreatePersonViewController.h"
#import "CHDStatusView.h"
#import "NSObject+SHPKeyboardAwareness.h"
#import "CHDDividerTableViewCell.h"
#import "CHDEventCategoriesTableViewCell.h"
#import "CHDNewMessageTextViewCell.h"
#import "CHDNewMessageTextFieldCell.h"
#import "CHDCreatePersonViewModel.h"
#import "SHPKeyboardEvent.h"
#import "CHDPeople.h"

typedef NS_ENUM(NSUInteger, newMessagesSections) {
    divider1Section,
    selectReceiverSection,
    selectSenderSection,
    divider2Section,
    subjectInputSection,
    messageInputSection,
    divider3Section,
    selecttagsSection,
    newMessagesCountSections
};

static NSString* kCreateMessageDividerCell = @"createMessageDividerCell";
static NSString* kCreateMessageSelectorCell = @"createMessageSelectorCell";
static NSString* kCreateMessageTextFieldCell = @"createMessagTextFieldCell";
static NSString* kCreateMessageTextViewCell = @"createMessageTextViewCell";
static NSString* kCreatePersonSelectorCell = @"createPersonSelectorCell";

@interface CHDCreatePersonViewController () <UITableViewDataSource, UITableViewDelegate>
@property (nonatomic, strong) UITableView* tableView;
@property (nonatomic, strong) CHDStatusView *statusView;
@property (nonatomic, strong) CHDCreatePersonViewModel *personViewModel;
@end



@implementation CHDCreatePersonViewController

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.title = NSLocalizedString(@"Create Person", @"");
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem new] initWithTitle:NSLocalizedString(@"Cancel", @"") style:UIBarButtonItemStylePlain target:self action:@selector(leftBarButtonTouch)];
        UIBarButtonItem *sendButton = [[UIBarButtonItem new] initWithTitle:NSLocalizedString(@"Create", @"") style:UIBarButtonItemStylePlain target:self action:@selector(rightBarButtonTouch)];
        [sendButton setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys: [UIColor whiteColor],  NSForegroundColorAttributeName,nil] forState:UIControlStateNormal];
        [sendButton setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys: [UIColor chd_menuDarkBlue],  NSForegroundColorAttributeName,nil] forState:UIControlStateDisabled];
        self.navigationItem.rightBarButtonItem = sendButton;
        self.personViewModel = [CHDCreatePersonViewModel new];
        
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self makeViews];
    [self makeConstraints];
    [self makeBindings];
    [self.view setBackgroundColor:[UIColor whiteColor]];
    // Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:YES];
    [self.tableView reloadData];
}

-(void) leftBarButtonTouch{
    [self.view endEditing:YES];
    //Cancel the creation of new message
    [self dismissViewControllerAnimated:YES completion:nil];
}


-(void)rightBarButtonTouch {
    
}

#pragma mark - TableView datasource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return newMessagesCountSections;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if((newMessagesSections)indexPath.section == divider1Section || (newMessagesSections)indexPath.section == divider2Section || (newMessagesSections)indexPath.section == divider3Section){
        CHDDividerTableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:kCreateMessageDividerCell forIndexPath:indexPath];
        return cell;
    }
    if((newMessagesSections)indexPath.section == selectReceiverSection){
        CHDNewMessageTextFieldCell* cell = [tableView cellForRowAtIndexPath:indexPath]?: [tableView dequeueReusableCellWithIdentifier:kCreateMessageTextFieldCell forIndexPath:indexPath];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.textField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:NSLocalizedString(@"First Name", @"") attributes:@{NSForegroundColorAttributeName: [UIColor shpui_colorWithHexValue:0xa8a8a8]}];
        [self.personViewModel shprac_liftSelector:@selector(setFirstName:) withSignal:[cell.textField.rac_textSignal takeUntil:cell.rac_prepareForReuseSignal]];
        return cell;
    }
    if((newMessagesSections)indexPath.section == selectSenderSection){
        CHDNewMessageTextFieldCell* cell = [tableView cellForRowAtIndexPath:indexPath]?: [tableView dequeueReusableCellWithIdentifier:kCreateMessageTextFieldCell forIndexPath:indexPath];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.textField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:NSLocalizedString(@"Last Name", @"") attributes:@{NSForegroundColorAttributeName: [UIColor shpui_colorWithHexValue:0xa8a8a8]}];
        [self.personViewModel shprac_liftSelector:@selector(setLastName:) withSignal:[cell.textField.rac_textSignal takeUntil:cell.rac_prepareForReuseSignal]];
        return cell;
    }
    if((newMessagesSections)indexPath.section == subjectInputSection){
        CHDNewMessageTextFieldCell* cell = [tableView cellForRowAtIndexPath:indexPath]?: [tableView dequeueReusableCellWithIdentifier:kCreateMessageTextFieldCell forIndexPath:indexPath];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.textField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:NSLocalizedString(@"Email", @"") attributes:@{NSForegroundColorAttributeName: [UIColor shpui_colorWithHexValue:0xa8a8a8]}];
        [self.personViewModel shprac_liftSelector:@selector(setEmail:) withSignal:[cell.textField.rac_textSignal takeUntil:cell.rac_prepareForReuseSignal]];
        return cell;
    }
    if((newMessagesSections)indexPath.section == messageInputSection){
        CHDNewMessageTextFieldCell* cell = [tableView cellForRowAtIndexPath:indexPath]?: [tableView dequeueReusableCellWithIdentifier:kCreateMessageTextFieldCell forIndexPath:indexPath];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.textField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:NSLocalizedString(@"Phone", @"") attributes:@{NSForegroundColorAttributeName: [UIColor shpui_colorWithHexValue:0xa8a8a8]}];
        cell.textField.keyboardType = UIKeyboardTypePhonePad;
        [self.personViewModel shprac_liftSelector:@selector(setPhoneNumber:) withSignal:[cell.textField.rac_textSignal takeUntil:cell.rac_prepareForReuseSignal]];
        return cell;
    }
    if((newMessagesSections)indexPath.section == selecttagsSection){
        CHDEventCategoriesTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kCreatePersonSelectorCell forIndexPath:indexPath];
        cell.titleLabel.text = NSLocalizedString(@"Tags", @"");
        
        return cell;
    }
    return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if((newMessagesSections)indexPath.section == selecttagsSection){
        
    }
}

#pragma mark - Lazy initialization

-(void) makeViews {
    [self.view addSubview:self.tableView];
    
    self.statusView = [[CHDStatusView alloc] init];
    self.statusView.successText = NSLocalizedString(@"Person created successfully", @"");
    self.statusView.processingText = NSLocalizedString(@"Creating person..", @"");
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
    RAC(self.navigationItem.rightBarButtonItem, enabled) = RACObserve(self.personViewModel, canCreatePerson);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
        [_tableView registerClass:[CHDEventCategoriesTableViewCell class] forCellReuseIdentifier:kCreatePersonSelectorCell];
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
