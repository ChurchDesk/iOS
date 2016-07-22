//
//  CHDCreatePersonViewController.m
//  ChurchDesk
//
//  Created by Chirag Sharma on 03/06/16.
//  Copyright © 2016 ChurchDesk ApS. All rights reserved.
//

#import <SHPNetworking/SHPAPIManager+ReactiveExtension.h>
#import "CHDCreatePersonViewController.h"
#import "CHDStatusView.h"
#import "NSObject+SHPKeyboardAwareness.h"
#import "CHDDividerTableViewCell.h"
#import "CHDEventValueTableViewCell.h"
#import "CHDNewMessageTextViewCell.h"
#import "CHDNewMessageTextFieldCell.h"
#import "CHDNewMessageSelectorCell.h"
#import "CHDCreatePersonViewModel.h"
#import "SHPKeyboardEvent.h"
#import "CHDPeople.h"
#import "CHDTag.h"
#import "CHDListSelectorViewController.h"
#import "CHDListSelectorConfigModel.h"
#import "CHDAPIClient.h"
#import "UIImageView+Haneke.h"

typedef NS_ENUM(NSUInteger, newMessagesSections) {
    divider1Section,
    selectReceiverSection,
    selectSenderSection,
    subjectInputSection,
    messageInputSection,
    divider2Section,
    homePhoneSection,
    workPhoneSection,
    jobTitleSection,
    birthdaySection,
    genderSection,
    streetAddressSection,
    citySection,
    postCodeSection,
    divider3Section,
    selecttagsSection,
    newMessagesCountSections
};

static NSString* kCreateMessageDividerCell = @"createMessageDividerCell";
static NSString* kCreateMessageSelectorCell = @"createMessageSelectorCell";
static NSString* kCreateMessageTextFieldCell = @"createMessagTextFieldCell";
static NSString* kCreateMessageTextViewCell = @"createMessageTextViewCell";
static NSString* kCreatePersonSelectorCell = @"createPersonSelectorCell";
NSInteger selectedIndex = 0;
@interface CHDCreatePersonViewController () <UITableViewDataSource, UITableViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIGestureRecognizerDelegate, UIPickerViewDelegate, UIPickerViewDataSource, UIActionSheetDelegate, UITextFieldDelegate >
@property (nonatomic, strong) UITableView* tableView;
@property (nonatomic, strong) CHDStatusView *statusView;
@property (nonatomic, strong) CHDCreatePersonViewModel *personViewModel;
@property (nonatomic, strong) UIImageView* userImageView;
@property (nonatomic, strong) UIButton* editImageButton;
@property (nonatomic, strong) UIView *receiverView;
@property (nonatomic, strong) UIButton *backgroundButton;
@property (nonatomic, strong) UIDatePicker *datePicker;
@property (nonatomic, strong) UIPickerView *pickerView;
@property (nonatomic, retain) NSMutableArray *pickerDataArray;
@end



@implementation CHDCreatePersonViewController
- (instancetype)init
{
    self = [super init];
    if (self) {
        
        
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

-(void)rightBarButtonTouch :(id) sender {
    [self.view endEditing:YES];
    [self didChangeSendingStatus:CHDStatusViewProcessing];
    if (self.personToEdit) {
        //edit a person
        NSMutableDictionary *personDictionary = [[NSMutableDictionary alloc] init];
        [personDictionary setValue:self.personViewModel.firstName forKey:@"firstName"];
        self.personToEdit.firstName = self.personViewModel.firstName;
        [personDictionary setValue:self.personViewModel.lastName forKey:@"lastName"];
        self.personToEdit.lastName = self.personViewModel.lastName;
        self.personToEdit.fullName = [NSString stringWithFormat:@"%@ %@", self.personViewModel.firstName, self.personViewModel.lastName];
        [personDictionary setValue:self.personViewModel.email forKey:@"email"];
        self.personToEdit.email = self.personViewModel.email;
        [personDictionary setValue:self.personViewModel.jobTitle forKey:@"occupation"];
        self.personToEdit.occupation = self.personViewModel.jobTitle;
        NSDictionary *contactDictionay = [[NSDictionary alloc] initWithObjectsAndKeys:self.personViewModel.mobilePhone, @"phone", self.personViewModel.homePhone, @"homePhone", self.personViewModel.workPhone, @"workPhone", self.personViewModel.postCode, @"zipcode", self.personViewModel.address, @"street", self.personViewModel.city, @"city", nil];
        [personDictionary setObject:contactDictionay forKey:@"contact"];
        self.personToEdit.contact = contactDictionay;
        [personDictionary setObject:self.personViewModel.gender forKey:@"gender"];
        self.personToEdit.gender = self.personViewModel.gender;
        //changing date to string
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"];
        NSString *stringFromDate = [formatter stringFromDate:self.personViewModel.birthday];
        self.personToEdit.birthday = self.personViewModel.birthday;
        [personDictionary setValue:stringFromDate forKey:@"birthday"];
        [personDictionary setObject:self.personViewModel.personPicture forKey:@"picture"];
        self.personToEdit.picture = self.personViewModel.personPicture;
        if (self.personViewModel.selectedTags.count >0) {
            NSMutableArray *tagsArray = [[NSMutableArray alloc] init];
            for (int i=0; i < self.personViewModel.selectedTags.count; i++) {
                CHDTag *singleTag = [self.personViewModel tagWithId:[self.personViewModel.selectedTags objectAtIndex:i]];
                NSDictionary *singlTagDictionary = [NSDictionary dictionaryWithObjectsAndKeys:singleTag.tagId, @"id", singleTag.name, @"name", nil];
                [tagsArray addObject:singlTagDictionary];
            }
            self.personToEdit.tags = tagsArray;
            [personDictionary setObject:tagsArray forKey:@"tags"];
        }

        
        [[self.personViewModel editPerson:personDictionary personId:self.personToEdit.peopleId] subscribeError:^(NSError *error) {
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
            [Heap track:@"Person edited successfully"];
        }];

    }
    else{
    //create a new person
    [[self.personViewModel createPerson] subscribeError:^(NSError *error) {
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
        [Heap track:@"Person created successfully"];
    }];
    }
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
    if((newMessagesSections)indexPath.section == selectReceiverSection || (newMessagesSections)indexPath.section == selectSenderSection || (newMessagesSections)indexPath.section == subjectInputSection ||(newMessagesSections)indexPath.section == jobTitleSection || (newMessagesSections)indexPath.section == streetAddressSection || (newMessagesSections)indexPath.section == citySection || (newMessagesSections)indexPath.section == postCodeSection) {
        CHDNewMessageTextFieldCell* cell = [tableView cellForRowAtIndexPath:indexPath]?: [tableView dequeueReusableCellWithIdentifier:kCreateMessageTextFieldCell forIndexPath:indexPath];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        NSString *textString;
        if ((newMessagesSections)indexPath.section == selectReceiverSection) {
            textString = NSLocalizedString(@"First Name", @"");
            cell.textField.text = self.personViewModel.firstName;
            cell.textField.tag = 200;
            [self.personViewModel shprac_liftSelector:@selector(setFirstName:) withSignal:[cell.textField.rac_textSignal takeUntil:cell.rac_prepareForReuseSignal]];
        }
        else if ((newMessagesSections)indexPath.section == selectSenderSection){
            textString = NSLocalizedString(@"Last Name", @"");
            cell.textField.text = self.personViewModel.lastName;
            cell.textField.tag = 201;
            [self.personViewModel shprac_liftSelector:@selector(setLastName:) withSignal:[cell.textField.rac_textSignal takeUntil:cell.rac_prepareForReuseSignal]];
        }
        else if ((newMessagesSections)indexPath.section == subjectInputSection)
        {
            textString = NSLocalizedString(@"Email", @"");
            cell.textField.text = self.personViewModel.email;
            cell.textField.tag = 202;
            [self.personViewModel shprac_liftSelector:@selector(setEmail:) withSignal:[cell.textField.rac_textSignal takeUntil:cell.rac_prepareForReuseSignal]];
            cell.textField.keyboardType = UIKeyboardTypeEmailAddress;
        }
        else if ((newMessagesSections)indexPath.section == jobTitleSection){
            textString = NSLocalizedString(@"Job Title", @"");
            cell.textField.text = self.personViewModel.jobTitle;
            cell.textField.tag = 206;
            [self.personViewModel shprac_liftSelector:@selector(setJobTitle:) withSignal:[cell.textField.rac_textSignal takeUntil:cell.rac_prepareForReuseSignal]];
        }
        else if ((newMessagesSections)indexPath.section == streetAddressSection){
            textString = NSLocalizedString(@"Address", @"");
            cell.textField.text = self.personViewModel.address;
            cell.textField.tag = 207;
            [self.personViewModel shprac_liftSelector:@selector(setAddress:) withSignal:[cell.textField.rac_textSignal takeUntil:cell.rac_prepareForReuseSignal]];
        }
        else if ((newMessagesSections)indexPath.section == citySection){
            textString = NSLocalizedString(@"City", @"");
            cell.textField.text = self.personViewModel.city;
            cell.textField.tag = 208;
            [self.personViewModel shprac_liftSelector:@selector(setCity:) withSignal:[cell.textField.rac_textSignal takeUntil:cell.rac_prepareForReuseSignal]];
        }
        else if ((newMessagesSections)indexPath.section == postCodeSection){
            textString = NSLocalizedString(@"Postal Code", @"");
            cell.textField.text = self.personViewModel.postCode;
            [self.personViewModel shprac_liftSelector:@selector(setPostCode:) withSignal:[cell.textField.rac_textSignal takeUntil:cell.rac_prepareForReuseSignal]];
            cell.textField.keyboardType = UIKeyboardTypeNumberPad;
            cell.textField.tag = 209;
        }
        cell.textField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:textString attributes:@{NSForegroundColorAttributeName: [UIColor shpui_colorWithHexValue:0xa8a8a8]}];
        cell.textField.returnKeyType = UIReturnKeyNext;
        cell.textField.delegate = self;
        return cell;
    }
    if((newMessagesSections)indexPath.section == messageInputSection || (newMessagesSections)indexPath.section == homePhoneSection || (newMessagesSections)indexPath.section == workPhoneSection ){
        CHDNewMessageTextFieldCell* cell = [tableView cellForRowAtIndexPath:indexPath]?: [tableView dequeueReusableCellWithIdentifier:kCreateMessageTextFieldCell forIndexPath:indexPath];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        NSString *textString;
        if ((newMessagesSections)indexPath.section == messageInputSection) {
            textString = NSLocalizedString(@"Phone", @"");
            cell.textField.text = self.personViewModel.mobilePhone;
            cell.textField.tag = 203;
            [self.personViewModel shprac_liftSelector:@selector(setMobilePhone:) withSignal:[cell.textField.rac_textSignal takeUntil:cell.rac_prepareForReuseSignal]];
        }
        else if ((newMessagesSections)indexPath.section == homePhoneSection){
            textString = NSLocalizedString(@"Home Phone", @"");
            cell.textField.text = self.personViewModel.homePhone;
            cell.textField.tag = 204;
            [self.personViewModel shprac_liftSelector:@selector(setHomePhone:) withSignal:[cell.textField.rac_textSignal takeUntil:cell.rac_prepareForReuseSignal]];
        }
        else if ((newMessagesSections)indexPath.section == workPhoneSection){
            textString = NSLocalizedString(@"Work Phone", @"");
            cell.textField.text = self.personViewModel.workPhone;
            cell.textField.tag = 205;
            [self.personViewModel shprac_liftSelector:@selector(setWorkPhone:) withSignal:[cell.textField.rac_textSignal takeUntil:cell.rac_prepareForReuseSignal]];
        }
        cell.textField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:textString attributes:@{NSForegroundColorAttributeName: [UIColor shpui_colorWithHexValue:0xa8a8a8]}];
        cell.textField.keyboardType = UIKeyboardTypePhonePad;
        return cell;
    }
    if ((newMessagesSections)indexPath.section == birthdaySection || (newMessagesSections)indexPath.section == genderSection) {
        CHDNewMessageSelectorCell* cell = [tableView dequeueReusableCellWithIdentifier:kCreateMessageSelectorCell forIndexPath:indexPath];
        if ((newMessagesSections)indexPath.section == birthdaySection) {
            cell.titleLabel.text = NSLocalizedString(@"Birthday", @"");
            if (self.personViewModel.birthday) {
                cell.selectedLabel.text =  [self.personViewModel formatDate:self.personViewModel.birthday];
            }
        }
        else if ((newMessagesSections)indexPath.section == genderSection){
            cell.titleLabel.text = NSLocalizedString(@"Gender", @"");
            cell.selectedLabel.text = self.personViewModel.gender;
        }
        cell.dividerLineHidden = NO;
        return cell;
    }
    if((newMessagesSections)indexPath.section == selecttagsSection){
        CHDEventValueTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kCreatePersonSelectorCell forIndexPath:indexPath];
        cell.titleLabel.text = NSLocalizedString(@"Tags", @"");
        cell.valueLabel.text = self.personViewModel.selectedTags.count <= 1 ? [self.personViewModel tagWithId:self.personViewModel.selectedTags.firstObject].name : [@(self.personViewModel.selectedTags.count) stringValue];
        return cell;
    }
    return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.view endEditing:YES];
    if((newMessagesSections)indexPath.section == selecttagsSection){
        NSMutableArray *items = [NSMutableArray new];
        for (CHDTag *tag in self.personViewModel.tags) {
            BOOL selected = false;
            for (NSNumber *tagId in self.personViewModel.selectedTags) {
                if (tagId.intValue == tag.tagId.intValue) {
                    selected = true;
                }
            }
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
    else if ((newMessagesSections)indexPath.section == birthdaySection) {
        [self showAction:YES];
    }
    else if ((newMessagesSections)indexPath.section == genderSection)
    {
        [self showAction:NO];
    }
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
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
        [moveLabel setText:NSLocalizedString(@"Move and Scale", @"") ];
        [moveLabel setTextAlignment:NSTextAlignmentCenter];
        [moveLabel setTextColor:[UIColor whiteColor]];
        
        [viewController.view addSubview:moveLabel];
    }
}

- (void) imagePickerController:(UIImagePickerController *)picker
 didFinishPickingMediaWithInfo:(NSDictionary *)info {
    //obtaining saving path
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *imagePath = [documentsDirectory stringByAppendingPathComponent:@"people_photo.png"];
    
    //extracting image from the picker and saving it
    NSString *mediaType = [info objectForKey:UIImagePickerControllerMediaType];
    if ([mediaType isEqualToString:@"public.image"]){
        UIImage *editedImage = [info objectForKey:UIImagePickerControllerEditedImage];
        NSData *webData = UIImagePNGRepresentation(editedImage);
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(saveProfilePicture) name:kpeopleImage object:nil];
        [[CHDAPIClient sharedInstance] uploadPicture:webData organizationId:self.organizationId userId:nil];
        [webData writeToFile:imagePath atomically:YES];
    }
    [self.userImageView setImage:[UIImage imageWithContentsOfFile:imagePath]];
    [picker dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Lazy initialization

-(void) makeViews {
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem new] initWithTitle:NSLocalizedString(@"Cancel", @"") style:UIBarButtonItemStylePlain target:self action:@selector(leftBarButtonTouch)];
    self.personViewModel = [CHDCreatePersonViewModel new];
    NSString *rightButtonTitle;
    if (self.personToEdit) {
        self.title = NSLocalizedString(@"Edit Person", @"");
        rightButtonTitle = NSLocalizedString(@"Save", @"");
        [self.personViewModel personInfoDistribution:self.personToEdit];
    }
    else{
        self.title = NSLocalizedString(@"Create Person", @"");
        rightButtonTitle = NSLocalizedString(@"Create", @"");
    }
    UIBarButtonItem *sendButton = [[UIBarButtonItem new] initWithTitle:rightButtonTitle style:UIBarButtonItemStylePlain target:self action:@selector(rightBarButtonTouch:)];
    [sendButton setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys: [UIColor whiteColor],  NSForegroundColorAttributeName,nil] forState:UIControlStateNormal];
    [sendButton setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys: [UIColor chd_menuDarkBlue],  NSForegroundColorAttributeName,nil] forState:UIControlStateDisabled];
    self.navigationItem.rightBarButtonItem = sendButton;
    
    [self.view addSubview:self.tableView];
    [self.view addSubview:self.userImageView];
    [self.view addSubview:self.editImageButton];
    self.statusView = [[CHDStatusView alloc] init];
    if (self.personToEdit) {
        self.statusView.successText = NSLocalizedString(@"Person edited successfully", @"");
        self.statusView.processingText = NSLocalizedString(@"Editing person..", @"");
    }
    else{
        self.statusView.successText = NSLocalizedString(@"Person created successfully", @"");
        self.statusView.processingText = NSLocalizedString(@"Creating person..", @"");
    }
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
    // Init the picker data array.
    _pickerDataArray = [[NSMutableArray alloc] init];
    
    // Add some data for demo purposes.
    [_pickerDataArray addObject:NSLocalizedString(@"Male", @"")];
    [_pickerDataArray addObject:NSLocalizedString(@"Female", @"")];
    if ([self.personViewModel.personPicture valueForKey:@"url"] != (id)[NSNull null]) {
        [self userImageWithUrl:[NSURL URLWithString:[self.personViewModel.personPicture valueForKey:@"url"]]];
    }
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
        [_tableView registerClass:[CHDEventValueTableViewCell class] forCellReuseIdentifier:kCreatePersonSelectorCell];
        [_tableView registerClass:[CHDNewMessageTextViewCell class] forCellReuseIdentifier:kCreateMessageTextViewCell];
        [_tableView registerClass:[CHDNewMessageTextFieldCell class] forCellReuseIdentifier:kCreateMessageTextFieldCell];
        [_tableView registerClass:[CHDNewMessageSelectorCell class] forCellReuseIdentifier:kCreateMessageSelectorCell];
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
        _userImageView.userInteractionEnabled = YES;
        UITapGestureRecognizer *pgr = [[UITapGestureRecognizer alloc]
                                         initWithTarget:self action:@selector(editAction:)];
        pgr.delegate = self;
        [_userImageView addGestureRecognizer:pgr];
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

-(void) showAction :(BOOL) birthday
{
    [self.view endEditing:YES];
    if(!_receiverView){
        [Heap track:@"Send to popup shown"];
        _backgroundButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _backgroundButton.frame = self.view.superview.frame;
        [_backgroundButton addTarget:self action:@selector(removeBirthdayView) forControlEvents:UIControlEventTouchUpInside];
        _backgroundButton.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.3];
        [self.view addSubview:_backgroundButton];
        
        _receiverView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 300, 300)] ;
        _receiverView.center = self.view.superview.center;
        _receiverView.userInteractionEnabled = TRUE;
        _receiverView.backgroundColor = [UIColor whiteColor];
        _receiverView.transform = CGAffineTransformScale(CGAffineTransformIdentity, 0.001, 0.001);
    
        UILabel *selectLabel = [[UILabel alloc] initWithFrame:CGRectMake ( 0, 20, 300, 20)];
        selectLabel.font = [UIFont chd_fontWithFontWeight:CHDFontWeightMedium size:20];
        selectLabel.textAlignment = NSTextAlignmentCenter;
        selectLabel.textColor = [UIColor chd_textDarkColor];
        [_receiverView addSubview:selectLabel];
        
        UIButton *doneButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [doneButton setTitle:NSLocalizedString(@"Done", @"") forState:UIControlStateNormal];
        [doneButton setTitleColor:[UIColor chd_textDarkColor] forState:UIControlStateNormal];
        doneButton.frame = CGRectMake ( 100, 240, 100, 50);
        [_receiverView addSubview:doneButton];
        [self.view addSubview:_receiverView];
        
        if (birthday) {
            selectLabel.text = NSLocalizedString(@"Select Birthday", @"");
            _datePicker=[[UIDatePicker alloc]initWithFrame:CGRectMake(0, 65, 300, 180)];
            _datePicker.datePickerMode=UIDatePickerModeDate;
            _datePicker.maximumDate = [NSDate date];
            [_receiverView addSubview:_datePicker];
            if (self.personViewModel.birthday) {
                [_datePicker setDate:self.personViewModel.birthday];
            }
            [doneButton addTarget:self action:@selector(doneDatePressed) forControlEvents:UIControlEventTouchUpInside];
        }
        else{
            selectLabel.text = NSLocalizedString(@"Select Gender", @"");
            selectLabel.font = [UIFont chd_fontWithFontWeight:CHDFontWeightMedium size:30];
            selectLabel.frame = CGRectMake ( 0, 50, 300, 50);
            _pickerView = [[UIPickerView alloc] init];
            [_pickerView setDataSource: self];
            [_pickerView setDelegate: self];
            [_pickerView setFrame:CGRectMake(25, 100, 250, 100)];
            _pickerView.showsSelectionIndicator = YES;
            [_receiverView addSubview: _pickerView];
            [doneButton addTarget:self action:@selector(donePickerPressed) forControlEvents:UIControlEventTouchUpInside];
        }
    
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

-(void) removeBirthdayView{
    [_datePicker removeFromSuperview];
    _datePicker = nil;
    [_pickerView removeFromSuperview];
    _pickerView = nil;
    [_receiverView removeFromSuperview];
    _receiverView = nil;
    [_backgroundButton removeFromSuperview];
    _backgroundButton = nil;
}

-(void) userImageWithUrl: (NSURL*) URL{
    if(URL) {
        [self.userImageView layoutIfNeeded];
        [self.userImageView hnk_setImageFromURL:URL placeholder:nil];
    }
}

-(void) doneDatePressed{
    self.personViewModel.birthday = [_datePicker date];
    [self.tableView reloadData];
    [self removeBirthdayView];
}

-(void) donePickerPressed{
    self.personViewModel.gender = [_pickerDataArray objectAtIndex:selectedIndex];
    [self.tableView reloadData];
    [self removeBirthdayView];
}

-(void)saveProfilePicture {
    self.personViewModel.personPicture = [[NSUserDefaults standardUserDefaults] objectForKey:kpeopleImage];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Picker delegates
-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView{
    return 1;
}

// Total rows in our component.
-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{
    return [_pickerDataArray count];
}

// Display each row's data.
-(NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component{
    return [_pickerDataArray objectAtIndex: row];
}

// Do something with the selected row.
-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component{
    selectedIndex = row;
}

#pragma mark - TextField Delegate

-(BOOL) textFieldShouldReturn:(UITextField *)textField{
    if (textField.returnKeyType == UIReturnKeyNext) {
        UITextField *nextTextField = (UITextField *)[self.view viewWithTag:textField.tag+1];
        [nextTextField becomeFirstResponder];
    }
    return YES;
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

- (void) dealloc
{
    // If you don't remove yourself as an observer, the Notification Center
    // will continue to try and send notification objects to the deallocated
    // object.
    [[NSNotificationCenter defaultCenter] removeObserver:self];
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
