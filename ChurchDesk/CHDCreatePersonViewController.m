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
#import "CHDTag.h"
#import "CHDListSelectorViewController.h"
#import "CHDListSelectorConfigModel.h"

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

@interface CHDCreatePersonViewController () <UITableViewDataSource, UITableViewDelegate, UIActionSheetDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate>
@property (nonatomic, strong) UITableView* tableView;
@property (nonatomic, strong) CHDStatusView *statusView;
@property (nonatomic, strong) CHDCreatePersonViewModel *personViewModel;
@property (nonatomic, strong) UIImageView* userImageView;
@property (nonatomic, strong) UIButton* editImageButton;
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

- (void)editAction: (id) sender {
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera] )
    {
        
            UIActionSheet *actionSheet = [[UIActionSheet alloc]
                                          initWithTitle:nil
                                          delegate:self
                                          cancelButtonTitle:NSLocalizedString(@"Cancel", @"")
                                          destructiveButtonTitle:nil
                                          otherButtonTitles:NSLocalizedString(@"Choose Photo", @""), NSLocalizedString(@"Take Photo", @""), nil];
            actionSheet.tag = 100;
            [actionSheet showFromToolbar:[[self navigationController] toolbar]];
    }
    else{
            UIActionSheet *actionSheet = [[UIActionSheet alloc]
                                          initWithTitle:nil
                                          delegate:self
                                          cancelButtonTitle:NSLocalizedString(@"Cancel", @"")
                                          destructiveButtonTitle:nil
                                          otherButtonTitles:NSLocalizedString(@"Choose Photo", @""), nil];
            actionSheet.tag = 102;
            [actionSheet showFromToolbar:[[self navigationController] toolbar]];
    }
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
        NSMutableArray *items = [NSMutableArray new];
        for (CHDTag *tag in self.personViewModel.tags) {
            BOOL selected = false;
//            for (NSNumber *categoryId in event.eventCategoryIds) {
//                if (categoryId.intValue == category.categoryId.intValue) {
//                    selected = true;
//                }
//            }
            [items addObject:[[CHDListSelectorConfigModel alloc] initWithTitle:tag.name color:nil selected:selected refObject:tag.tagId]];
        }
        CHDListSelectorViewController *vc = [[CHDListSelectorViewController alloc] initWithSelectableItems:items];
        vc.title = NSLocalizedString(@"Select Tags", @"");
        vc.selectMultiple = YES;
        vc.isTag = YES;
        RACSignal *selectedSignal = [[[RACObserve(vc, selectedItems) map:^id(NSArray *selectedItems) {
            return [selectedItems valueForKey:@"refObject"];
        }] skip:1] takeUntil:vc.rac_willDeallocSignal];
        
        [self.personViewModel shprac_liftSelector:@selector(setSelectedTags:) withSignal:selectedSignal];
        CGPoint offset = self.tableView.contentOffset;
        [self.tableView rac_liftSelector:@selector(setContentOffset:) withSignals:[[[self rac_signalForSelector:@selector(viewDidLayoutSubviews)] takeUntil:vc.rac_willDeallocSignal] mapReplace:[NSValue valueWithCGPoint:offset]], nil];
        [self.navigationController pushViewController:vc animated:YES];
    }
}

#pragma mark - Actionsheet delegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (actionSheet.tag == 100)
    {
        if (buttonIndex == 0)
        {//Choose Photo
            UIImagePickerController *picker = [[UIImagePickerController alloc] init];
            picker.delegate = self;
            picker.allowsEditing = YES;
            picker.sourceType=UIImagePickerControllerSourceTypePhotoLibrary;
            [self presentViewController:picker animated:YES completion:nil];
            picker = nil;
        }
        else if (buttonIndex == 1)
        {//Take Photo
            UIImagePickerController *picker = [[UIImagePickerController alloc] init];
            picker.delegate = self;
            picker.allowsEditing = YES;
            picker.sourceType=UIImagePickerControllerSourceTypeCamera;
            //    [self presentModalViewController: picker animated:YES];
            [self presentViewController:picker animated:YES completion:nil];
            picker = nil;
        }
    }
    else if(actionSheet.tag == 102){
        if (buttonIndex == 0)
        {//Choose Photo
            UIImagePickerController *picker = [[UIImagePickerController alloc] init];
            picker.delegate = self;
            picker.allowsEditing = YES;
            picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
            [self presentViewController:picker animated:YES completion:nil];
            picker = nil;
        }
    }
}

- (void)navigationController:(UINavigationController *)navigationController didShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    if ([navigationController.viewControllers count] == 3)
    {
        CGFloat screenHeight = [[UIScreen mainScreen] bounds].size.height;
        
        UIView *plCropOverlay = [[[viewController.view.subviews objectAtIndex:1]subviews] objectAtIndex:0];
        
        plCropOverlay.hidden = YES;
        
        int position = 0;
        
        if (screenHeight == 568)
        {
            position = 124;
        }
        else
        {
            position = 80;
        }
        
        CAShapeLayer *circleLayer = [CAShapeLayer layer];
        
        UIBezierPath *path2 = [UIBezierPath bezierPathWithOvalInRect:
                               CGRectMake(0.0f, position, 320.0f, 320.0f)];
        [path2 setUsesEvenOddFillRule:YES];
        
        [circleLayer setPath:[path2 CGPath]];
        
        [circleLayer setFillColor:[[UIColor clearColor] CGColor]];
        UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(0, 0, 320, screenHeight-72) cornerRadius:0];
        
        [path appendPath:path2];
        [path setUsesEvenOddFillRule:YES];
        
        CAShapeLayer *fillLayer = [CAShapeLayer layer];
        fillLayer.path = path.CGPath;
        fillLayer.fillRule = kCAFillRuleEvenOdd;
        fillLayer.fillColor = [UIColor blackColor].CGColor;
        fillLayer.opacity = 0.8;
        [viewController.view.layer addSublayer:fillLayer];
        
        UILabel *moveLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 10, 320, 50)];
        [moveLabel setText:@"Move and Scale"];
        [moveLabel setTextAlignment:NSTextAlignmentCenter];
        [moveLabel setTextColor:[UIColor whiteColor]];
        
        [viewController.view addSubview:moveLabel];
    }
}
#pragma mark - Lazy initialization

-(void) makeViews {
    [self.view addSubview:self.tableView];
    [self.view addSubview:self.userImageView];
    [self.view addSubview:self.editImageButton];
    self.statusView = [[CHDStatusView alloc] init];
    self.statusView.successText = NSLocalizedString(@"Person created successfully", @"");
    self.statusView.processingText = NSLocalizedString(@"Creating person..", @"");
    self.statusView.autoHideOnSuccessAfterTime = 0;
    self.statusView.autoHideOnErrorAfterTime = 0;
}

-(void) makeConstraints {
    UIView *containerView = self.view;
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.equalTo(containerView);
        make.top.equalTo(containerView).with.offset(150);
    }];
    
    [self.userImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(containerView).with.offset(10);
        make.centerX.equalTo(containerView);
        make.width.height.equalTo(@104);
    }];
    
    [self.editImageButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(containerView);
        make.top.equalTo(containerView).with.offset(115);
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

-(UIImageView*)userImageView{
    if(!_userImageView){
        _userImageView = [UIImageView new];
        _userImageView.layer.cornerRadius = 52;
        _userImageView.layer.backgroundColor = [UIColor chd_lightGreyColor].CGColor;
        _userImageView.layer.masksToBounds = YES;
        _userImageView.contentMode = UIViewContentModeScaleAspectFill;
    }
    return _userImageView;
}

- (UIButton *)editImageButton {
    if (!_editImageButton) {
        _editImageButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_editImageButton setTitle:NSLocalizedString(@"Edit", @"") forState:UIControlStateNormal];
        [_editImageButton setTitleColor:[UIColor chd_textDarkColor] forState:UIControlStateNormal];
        [_editImageButton addTarget:self action:@selector(editAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _editImageButton;
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
