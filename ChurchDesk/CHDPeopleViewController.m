//
//  CHDPeopleViewController.m
//  ChurchDesk
//
//  Created by Chirag Sharma on 17/03/16.
//  Copyright © 2016 Shape A/S. All rights reserved.
//

#import "CHDPeopleViewController.h"
#import "CHDPeopleTabBarController.h"
#import "CHDPeopleViewModel.h"
#import "CHDEventTableViewCell.h"
#import "CHDAPIClient.h"
#import "CHDUser.h"
#import "CHDSite.h"
#import "CHDPeople.h"
#import "MBProgressHUD.h"
#import "CHDCreateMessageMailViewController.h"
#import "CHDPeopleProfileViewController.h"
#import "CHDCreatePersonViewController.h"

static const CGFloat k45Degrees = -0.785398163f;
static const CGPoint kDefaultCenterPoint = {124.0f, 117.0f};

@interface CHDPeopleViewController () <UITableViewDelegate, UITableViewDataSource, UISearchDisplayDelegate, UIScrollViewDelegate, UIActionSheetDelegate>
@property (nonatomic, strong) UIView *buttonContainer;
@property (nonatomic, strong) UIButton *toggleButton;
@property(nonatomic, strong) UIButton *messageButton;
@property(nonatomic, strong) UIButton *addPersonButton;
@property (nonatomic, retain) UITableView* peopletable;
@property(nonatomic, strong) CHDPeopleViewModel *viewModel;
@property(nonatomic, strong) UIRefreshControl *refreshControl;

@property (nonatomic, strong) MASConstraint *messageCenterConstraint;
@property (nonatomic, strong) MASConstraint *addPersonCenterConstraint;
@property (nonatomic, retain) UIView* noAccessView;
@property (nonatomic, assign) BOOL isExpanded;

@end

@implementation CHDPeopleViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.viewModel = [[CHDPeopleViewModel alloc] initWithSegmentIds:_segmentIds];
    if (self.viewModel.peopleAccess) {
        [self makeViews];
        [self makeConstraints];
        [self makeBindings];
    }
    else{
        [[NSNotificationCenter defaultCenter] postNotificationName:khideTabButtons object:nil];
        [self createNoAccessView];
    }
    
    // Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if (self.viewModel.peopleAccess) {
    //[self.peopletable deselectRowAtIndexPath:[self.peopletable indexPathForSelectedRow] animated:YES];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSDate *timestamp = [defaults valueForKey:kpeopleTimestamp];
    NSDate *currentTime = [NSDate date];
    NSTimeInterval timeDifference = [currentTime timeIntervalSinceDate:timestamp];
    //[self getSelectedPeopleArray];
    if (_selectedPeopleArray.count == 0) {
        _selectedPeopleArray = [[NSMutableArray alloc] init];
    }
//    [self.viewModel reload];
    [self.peopletable reloadData];
    //self.chd_people_tabbarViewController.title = [NSString stringWithFormat:@"(%d) %@",NSLocalizedString(@"People", @""), self.viewModel.people.count];
    if (timeDifference/60 > 10) {
        
    }
    
    if ([defaults boolForKey:ksuccessfulPeopleMessage]) {
        self.peopletable.editing = NO;
        [[NSNotificationCenter defaultCenter] postNotificationName:khideTabButtons object:nil];
        [defaults setBool:NO forKey:ksuccessfulPeopleMessage];
        self.peopletable.frame = CGRectMake(self.peopletable.frame.origin.x, self.peopletable.frame.origin.y, self.peopletable.frame.size.width, self.peopletable.frame.size.height - 50);
    }
    else if ([defaults boolForKey:ktoPeopleClicked]){
        self.peopletable.editing = YES;
        [defaults setBool:NO forKey:ktoPeopleClicked];
    }
    else if ([defaults boolForKey:kpersonSuccessfullyAdded]){
        [self.viewModel reload];
        [defaults setBool:NO forKey:kpersonSuccessfullyAdded];
    }
    NSString *rightBarButtonTitle;
    if (self.peopletable.isEditing) {
        rightBarButtonTitle = NSLocalizedString(@"Cancel", @"");
    }
    else {
        rightBarButtonTitle = NSLocalizedString(@"Select", @"");
    }
    if (_segmentIds.count > 0) {
        [_toggleButton setHidden:YES];
    }
    else {
        self.chd_people_tabbarViewController.navigationItem.rightBarButtonItem.title = rightBarButtonTitle;
    }
    [self.chd_people_tabbarViewController.navigationItem.rightBarButtonItem setTarget:self];
    [self.chd_people_tabbarViewController.navigationItem.rightBarButtonItem setAction:@selector(selectAction:)];
    NSLog(@"timestamp %@ currentTime %@ time difference %f", timestamp, currentTime, timeDifference);
    }
}

-(void) makeViews {
    [self.view addSubview:self.peopletable];
    [self.view addSubview:self.buttonContainer];
    [self.buttonContainer addSubview:self.messageButton];
    [self.buttonContainer addSubview:self.addPersonButton];
    [self.view addSubview:self.toggleButton];
    UIBarButtonItem *saveButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Select", @"") style:UIBarButtonItemStylePlain target:self action:@selector(selectAction:)];
    [saveButtonItem setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys: [UIColor whiteColor],  NSForegroundColorAttributeName,nil] forState:UIControlStateNormal];
    [saveButtonItem setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys: [UIColor chd_menuDarkBlue],  NSForegroundColorAttributeName,nil] forState:UIControlStateDisabled];
    self.chd_people_tabbarViewController.navigationItem.rightBarButtonItem = saveButtonItem;
    
    if (_createMessage) {
        self.navigationItem.rightBarButtonItem = saveButtonItem;
        self.navigationItem.rightBarButtonItem.title = NSLocalizedString(@"Done", @"");
        [self.toggleButton setHidden:YES];
    }
    self.buttonContainer.hidden = true;
}

-(void) makeConstraints {
    UIView* superview = self.view;
    [self.buttonContainer mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(superview.mas_bottom).offset(-5);
        make.right.equalTo(self.view);
        make.width.equalTo(@353);
        make.height.equalTo(@323);
    }];
    NSValue *vCenterPoint = [NSValue valueWithCGPoint:kDefaultCenterPoint];
    NSLog(@"center point %@", vCenterPoint);
    [self.toggleButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(superview.mas_bottom).offset(-15);
        make.right.equalTo(superview.mas_right).offset(-20);
    }];
    [self.messageButton mas_makeConstraints:^(MASConstraintMaker *make) {
        self.messageCenterConstraint = make.center.equalTo(vCenterPoint);
    }];
    [self.addPersonButton mas_makeConstraints:^(MASConstraintMaker *make) {
        self.addPersonCenterConstraint = make.center.equalTo(vCenterPoint);
    }];
    [self.peopletable mas_makeConstraints:^(MASConstraintMaker *make){
        make.edges.equalTo(superview);
    }];
}

-(void) makeBindings {
    RACSignal *newPeopleSignal = RACObserve(self.viewModel, people);
    [self shprac_liftSelector:@selector(updatePeople) withSignal:[RACSignal merge:@[newPeopleSignal]]];
    
    [self shprac_liftSelector:@selector(endRefresh) withSignal:newPeopleSignal];
    
    [self shprac_liftSelector:@selector(showProgress:) withSignal:[[self rac_signalForSelector:@selector(viewWillDisappear:)] map:^id(id value) {
        return @NO;
    }]];
}

-(void) updatePeople{
        [self.viewModel refreshData];
        [self.peopletable reloadData];
}

-(void)saveSelectedPeopleArray{
    NSData *encodedUser = [NSKeyedArchiver archivedDataWithRootObject:_selectedPeopleArray];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:encodedUser forKey:kselectedPeopleArray];
}

-(void)getSelectedPeopleArray{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSData *encodedObject = [defaults objectForKey:kselectedPeopleArray];
    _selectedPeopleArray = [NSKeyedUnarchiver unarchiveObjectWithData:encodedObject];
}

-(BOOL) isPeopleSelected :(CHDPeople *) people{
    for (CHDPeople *selectedPeople in _selectedPeopleArray) {
        if ([selectedPeople.peopleId isEqualToString:people.peopleId]) {
            return YES;
            break;
        }
    }
    return NO;
}

#pragma mark - Actions

- (void) toggleButtonAction: (id) sender {
    BOOL toggleOn = CGAffineTransformEqualToTransform(self.buttonContainer.transform, CGAffineTransformIdentity);
    [self buttonOn:toggleOn];
}

-(void) buttonOn: (BOOL) on {
    self.isExpanded = on;
    
    CGAffineTransform transform = on ? CGAffineTransformMakeRotation(-k45Degrees) : CGAffineTransformIdentity;
    CGPoint messageOffset = on ? CGPointMake(125, -53) : kDefaultCenterPoint;
    CGPoint addPeopleOffset = on ? CGPointMake(85, -93) : kDefaultCenterPoint;
    if (on) {
        self.buttonContainer.hidden = false;
    }
    [self.messageCenterConstraint setCenterOffset:messageOffset];
    [self.addPersonCenterConstraint setCenterOffset:addPeopleOffset];
    
    [UIView animateWithDuration:on ? 0.7 : 0.4 delay:0 usingSpringWithDamping:on ? 0.6 : 0.8 initialSpringVelocity:1.0 options: UIViewAnimationOptionAllowUserInteraction animations:^{
        self.toggleButton.transform = transform;
        self.buttonContainer.transform = transform;
        [self.view layoutIfNeeded];
    } completion:^(BOOL finished) {
        if (!on) {
            self.buttonContainer.hidden = true;
        }
    }];
}

- (void)selectAction: (id) sender {
    UIBarButtonItem *clickedButton = (UIBarButtonItem *)sender;
    if ([clickedButton.title isEqualToString:@""]) {
        
    }
    else if ([clickedButton.title isEqualToString:NSLocalizedString(@"Select", @"")]) {
        [Heap track:@"People: Select clicked"];
        clickedButton.title = NSLocalizedString(@"Cancel", @"");
        self.peopletable.editing = YES;
        if (_segmentIds.count > 0) {
            self.navigationItem.hidesBackButton = YES;
        }
        [[NSNotificationCenter defaultCenter] postNotificationName:khideTabButtons object:nil];
        self.peopletable.frame = CGRectMake(self.peopletable.frame.origin.x, self.peopletable.frame.origin.y, self.peopletable.frame.size.width, self.peopletable.frame.size.height + 50);
    }
    else if ([clickedButton.title isEqualToString:NSLocalizedString(@"Done", @"")]){
        [Heap track:@"People: Done clicked"];
        [_delegate sendSelectedPeopleArray:_selectedPeopleArray];
        [self.navigationController popViewControllerAnimated:YES];
    }
    else{// cancel
        [Heap track:@"People: Cancel clicked"];
        [_selectedPeopleArray removeAllObjects];
        //[self saveSelectedPeopleArray];
        if (_segmentIds.count > 0) {
            self.navigationItem.hidesBackButton = NO;
            self.navigationItem.rightBarButtonItem.title = NSLocalizedString(@"Select", @"");
        }
        else{
            self.chd_people_tabbarViewController.navigationItem.rightBarButtonItem.title = NSLocalizedString(@"Select", @"");
        }
        self.peopletable.editing = NO;
        [[NSNotificationCenter defaultCenter] postNotificationName:khideTabButtons object:nil];
        self.peopletable.frame = CGRectMake(self.peopletable.frame.origin.x, self.peopletable.frame.origin.y, self.peopletable.frame.size.width, self.peopletable.frame.size.height - 50);
    }
    [self.peopletable reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    CHDPeople* selectedPeople = [[self.viewModel.peopleArrangedAccordingToIndex objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    if (self.peopletable.isEditing) {
        if (![self isPeopleSelected:selectedPeople]) {
            [_selectedPeopleArray addObject:selectedPeople];
            //[self saveSelectedPeopleArray];
        }
    }
    else{
        [Heap track:@"People detail clicked"];
        NSLog(@"selected id %@", selectedPeople.peopleId);
        [tableView deselectRowAtIndexPath:indexPath animated:NO];
        CHDPeopleProfileViewController *ppvc = [[CHDPeopleProfileViewController alloc] init];
        ppvc.people = selectedPeople;
        ppvc.currentUser = self.viewModel.user;
        ppvc.organizationId = self.viewModel.organizationId;
        [self.navigationController pushViewController:ppvc animated:YES];
    }
}

-(void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath{
    CHDPeople* selectedPeople = [[self.viewModel.peopleArrangedAccordingToIndex objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    for (CHDPeople *selectedPeopleFromArray in _selectedPeopleArray) {
        if ([selectedPeopleFromArray.peopleId isEqualToString:selectedPeople.peopleId]) {
            [_selectedPeopleArray removeObject:selectedPeopleFromArray];
            //[self saveSelectedPeopleArray];
            break;
        }
    }
}

#pragma mark - UITableViewDataSource
- (void)refresh:(UIRefreshControl *)refreshControl {
    [self.viewModel reload];
}

-(void)endRefresh {
    [self.refreshControl endRefreshing];
    if (self.isViewLoaded && self.view.window) {
        if (self.viewModel.people.count == 0) {
            self.toggleButton.hidden = TRUE;
            self.chd_people_tabbarViewController.navigationItem.rightBarButtonItem.title = @"";
            [self noPeopleView];
        }
        else{
            [_noAccessView removeFromSuperview];
            _noAccessView = nil;
        }
    }
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView
{
    return self.viewModel.sectionIndices;
}

-(UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath{
    return UITableViewCellEditingStyleInsert;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString* cellIdentifier = @"peopleCell";
    CHDPeople* people = [[self.viewModel.peopleArrangedAccordingToIndex objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    CHDEventTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    
    if (_sendSMS) {
        cell.locationLabel.text = ([people.contact objectForKey:@"phone"] != (id)[NSNull null]) ?[people.contact objectForKey:@"phone"]:@"";
    }
    else{
        cell.locationLabel.text = people.email;
    }
    cell.titleLabel.text = people.fullName;
    cell.absenceIconView.hidden = true;
    [cell.cellBackgroundView setBorderColor:[UIColor clearColor]];
    cell.tintColor = [UIColor chd_blueColor];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    cell.userInteractionEnabled = YES;
    cell.titleLabel.textColor = [UIColor chd_textDarkColor];
    if (tableView.isEditing) {
        if ([self isPeopleSelected:people]) {
            [tableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
        }
        if (_createMessage) {
            if (_sendSMS) {
                if ([people.contact objectForKey:@"phone"] == (id)[NSNull null] || [[people.contact objectForKey:@"phone"] length] == 0 ) {
                    cell.userInteractionEnabled = NO;
                    cell.titleLabel.textColor = [UIColor lightGrayColor];
                }
            }
            else{
                if (people.email == (id)[NSNull null] || people.email.length == 0 ) {
                    cell.userInteractionEnabled = NO;
                    cell.titleLabel.textColor = [UIColor lightGrayColor];
                }
            }
        }
        
    }
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index{
    return [[UILocalizedIndexedCollation currentCollation] sectionForSectionIndexTitleAtIndex:index];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.viewModel.sectionIndices.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [[self.viewModel.peopleArrangedAccordingToIndex objectAtIndex:section] count];
}

- (void) createMessageShow: (id) sender {
    [self buttonOn:NO];
    int emailCount = 0;
    int phoneCount = 0;
    //counting number of people with email and phone number
    for (int numberOfPeople = 0; numberOfPeople < _selectedPeopleArray.count ; numberOfPeople ++) {
        CHDPeople* people = [_selectedPeopleArray objectAtIndex:numberOfPeople];
        if (people.email != (id)[NSNull null] && people.email.length != 0 ) {
            emailCount ++;
        }
        if ([people.contact objectForKey:@"phone"] != (id)[NSNull null] && [[people.contact objectForKey:@"phone"] length] != 0) {
            phoneCount ++;
        }
    }
    // Customising string according to the number of people having an email
    NSString *emailString;
    if (emailCount > 0) {
        emailString = [NSString stringWithFormat:@"%@ (%d)", NSLocalizedString(@"Send an email", @""), emailCount];
    }
    else{
        emailString = NSLocalizedString(@"Send an email", @"");
    }
    // Customising strin according to the number of people have a phone number
    NSString *phoneString;
    if (phoneCount > 0) {
        phoneString = [NSString stringWithFormat:@"%@ (%d)", NSLocalizedString(@"Send an SMS", @""), phoneCount];
    }
    else{
        phoneString = NSLocalizedString(@"Send an SMS", @"");
    }
    NSString *messageTypeString;
    if (_selectedPeopleArray.count > 0) {
        messageTypeString = [NSString stringWithFormat:@"%@\n(%lu %@)", NSLocalizedString(@"Choose message type..", @""), (unsigned long)_selectedPeopleArray.count, NSLocalizedString(@"people selected", @"")];
    }
    else{
        messageTypeString = NSLocalizedString(@"Choose message type..", @"");
    }
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:messageTypeString                                                                           delegate:self
                                                    cancelButtonTitle:NSLocalizedString(@"Cancel", @"")
                                               destructiveButtonTitle:nil
                                                    otherButtonTitles:emailString, phoneString, nil];
    actionSheet.tag = 101;
    [actionSheet showInView:self.view];
    
}

- (void) createPersonShow: (id) sender {
    [self buttonOn:NO];
    CHDCreatePersonViewController *newPersonViewController = [CHDCreatePersonViewController new];
    newPersonViewController.organizationId = self.viewModel.organizationId;
    UINavigationController *navigationVC = [[UINavigationController new] initWithRootViewController:newPersonViewController];
    [self presentViewController:navigationVC animated:YES completion:nil];
}

#pragma mark - Action Sheet delgate methods
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (actionSheet.tag == 101) {
        if (buttonIndex != 2) {
            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
            [defaults setBool:NO forKey:ktoPeopleClicked];
            if (buttonIndex == 0 || buttonIndex == 1) {
                CHDCreateMessageMailViewController* newMessageViewController = [CHDCreateMessageMailViewController new];
                newMessageViewController.selectedPeopleArray = _selectedPeopleArray;
                newMessageViewController.currentUser = self.viewModel.user;
                newMessageViewController.organizationId = self.viewModel.organizationId;
                if (buttonIndex == 0) {
                    newMessageViewController.isSMS = NO;
                    [Heap track:@"People: Create email clicked"];
                }
                else{
                    newMessageViewController.isSMS = YES;
                    [Heap track:@"People: Create SMS clicked"];
                }
                UINavigationController *navigationVC = [[UINavigationController new] initWithRootViewController:newMessageViewController];
                [self presentViewController:navigationVC animated:YES completion:nil];
            }
        }
    }
}

#pragma mark - Empty States

-(void)noPeopleView{
    if(!_noAccessView){
        _noAccessView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 380)] ;
        _noAccessView.center = self.view.center;
        _noAccessView.userInteractionEnabled = TRUE;
        [self.view addSubview:_noAccessView];
        
        UIImageView *lockImageView = [[UIImageView alloc] initWithImage:kImgNoPeoplIcon];
        [_noAccessView addSubview:lockImageView];
        [lockImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(_noAccessView).with.offset(0);
            make.centerX.equalTo(_noAccessView);
        }];
        
        UILabel *noRoleLabel = [[UILabel alloc] init];
        noRoleLabel.font = [UIFont chd_fontWithFontWeight:CHDFontWeightMedium size:25];
        noRoleLabel.text = NSLocalizedString(@"You haven't added any people yet..", @"");
        noRoleLabel.textAlignment = NSTextAlignmentCenter;
        noRoleLabel.textColor = [UIColor chd_textDarkColor];
        noRoleLabel.numberOfLines = 2;
        [_noAccessView addSubview:noRoleLabel];
        [noRoleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(lockImageView.mas_bottom).with.offset(30);
            make.width.equalTo(_noAccessView);
            make.centerX.equalTo(_noAccessView);
        }];
        
        UIButton *addPersonButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [addPersonButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [addPersonButton setBackgroundColor:[UIColor chd_greenColor]];
        addPersonButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
        [addPersonButton addTarget:self action:@selector(createPersonShow:) forControlEvents:UIControlEventTouchUpInside];
        [addPersonButton setTitle:NSLocalizedString(@"Create a person", @"") forState:UIControlStateNormal];
        [[addPersonButton layer] setCornerRadius:10.0f];
        [_noAccessView addSubview:addPersonButton];
        [addPersonButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(_noAccessView.mas_centerX);
            make.top.equalTo(noRoleLabel.mas_bottom).with.offset(50);
            make.width.equalTo(@150);
            make.height.equalTo(@40);
        }];
    }
}
-(void) createNoAccessView{
    if(!_noAccessView){
        _noAccessView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 380)] ;
        _noAccessView.center = self.view.center;
        _noAccessView.userInteractionEnabled = TRUE;
        [self.view addSubview:_noAccessView];
        
        UIImageView *lockImageView = [[UIImageView alloc] initWithImage:kImgLockIcon];
        [_noAccessView addSubview:lockImageView];
        [lockImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(_noAccessView).with.offset(0);
            make.centerX.equalTo(_noAccessView);
        }];
        
        UILabel *noRoleLabel = [[UILabel alloc] init];
        noRoleLabel.font = [UIFont chd_fontWithFontWeight:CHDFontWeightMedium size:25];
        noRoleLabel.text = NSLocalizedString(@"You don't have the necessary role..", @"");
        noRoleLabel.textAlignment = NSTextAlignmentCenter;
        noRoleLabel.textColor = [UIColor chd_textDarkColor];
        noRoleLabel.numberOfLines = 2;
        [_noAccessView addSubview:noRoleLabel];
        [noRoleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(lockImageView.mas_bottom).with.offset(30);
            make.width.equalTo(_noAccessView);
            make.centerX.equalTo(_noAccessView);
        }];
        
        UILabel *askAdminLabel = [[UILabel alloc] init];
        askAdminLabel.font = [UIFont chd_fontWithFontWeight:CHDFontWeightMedium size:15];
        askAdminLabel.text = NSLocalizedString(@"Please ask your administrator to provide you with \"Newsletter\" role.", @"");
        askAdminLabel.textAlignment = NSTextAlignmentCenter;
        askAdminLabel.textColor = [UIColor chd_textLightColor];
        askAdminLabel.numberOfLines = 2;
        [_noAccessView addSubview:askAdminLabel];
        [askAdminLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(noRoleLabel.mas_bottom).with.offset(50);
            make.width.equalTo(_noAccessView);
            make.centerX.equalTo(_noAccessView);
        }];
    }
}

#pragma mark - Lazy Initialization

-(UITableView*)peopletable {
    if(!_peopletable){
        _peopletable = [[UITableView alloc] init];
        _peopletable.separatorStyle = UITableViewCellSeparatorStyleNone;
        _peopletable.backgroundView.backgroundColor = [UIColor chd_lightGreyColor];
        _peopletable.backgroundColor = [UIColor chd_lightGreyColor];
        _peopletable.rowHeight = 65;
        [_peopletable registerClass:[CHDEventTableViewCell class] forCellReuseIdentifier:@"peopleCell"];
        _peopletable.dataSource = self;
        _peopletable.delegate = self;
        _peopletable.allowsSelectionDuringEditing = YES;
        _peopletable.allowsMultipleSelectionDuringEditing = YES;
    }
    return _peopletable;
}

-(UIRefreshControl*) refreshControl {
    if(!_refreshControl){
        _refreshControl = [[UIRefreshControl alloc] init];
        [_refreshControl addTarget:self action:@selector(refresh:) forControlEvents:UIControlEventValueChanged];
    }
    return _refreshControl;
}

-(void) showProgress: (BOOL) show {
    if(show && self.navigationController.view) {
        [MBProgressHUD hideAllHUDsForView:self.navigationController.view animated:YES];
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
        
        // Configure for text only and offset down
        hud.mode = MBProgressHUDModeIndeterminate;
        hud.color = [UIColor colorWithWhite:0.7 alpha:0.7];
        hud.labelColor = [UIColor chd_textDarkColor];
        hud.margin = 10.f;
        hud.removeFromSuperViewOnHide = YES;
        hud.userInteractionEnabled = NO;
    }else{
        [MBProgressHUD hideAllHUDsForView:self.navigationController.view animated:YES];
    }
}

-(UIButton*)messageButton {
    if(!_messageButton){
        _messageButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_messageButton setImage:kImgCreateMessage forState:UIControlStateNormal];
        _messageButton.transform = CGAffineTransformRotate(CGAffineTransformIdentity, k45Degrees);
        [_messageButton addTarget:self
                           action:@selector(createMessageShow:)
                 forControlEvents:UIControlEventTouchUpInside];
    }
    return _messageButton;
}

- (UIView *)buttonContainer {
    if (!_buttonContainer) {
        _buttonContainer = [UIView new];
    }
    return _buttonContainer;
}

- (UIButton *)toggleButton {
    if (!_toggleButton) {
        _toggleButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_toggleButton setImage:kImgCreatePassive forState:UIControlStateNormal];
        [_toggleButton setImage:kImgCreateActive forState:UIControlStateSelected];
        [_toggleButton addTarget:self action:@selector(toggleButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        [_toggleButton shprac_liftSelector:@selector(setSelected:) withSignal:RACObserve(self, isExpanded)];
    }
    return _toggleButton;
}

- (UIButton *)addPersonButton {
    if (!_addPersonButton) {
        _addPersonButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_addPersonButton setImage:kImgCreatePerson forState:UIControlStateNormal];
        _addPersonButton.transform = CGAffineTransformRotate(CGAffineTransformIdentity, k45Degrees);
        [_addPersonButton addTarget:self action:@selector(createPersonShow:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _addPersonButton;
}

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event {
    // UIView will be "transparent" for touch events if we return NO
    return (!self.buttonContainer.hidden || CGRectContainsPoint(self.toggleButton.frame, point));
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
