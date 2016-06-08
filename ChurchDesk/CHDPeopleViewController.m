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

@interface CHDPeopleViewController () <UITableViewDelegate, UITableViewDataSource, UISearchDisplayDelegate, UIScrollViewDelegate>
@property (nonatomic, strong) UIView *buttonContainer;
@property (nonatomic, strong) UIButton *toggleButton;
@property(nonatomic, strong) UIButton *messageButton;
@property(nonatomic, strong) UIButton *addPersonButton;
@property (nonatomic, retain) UITableView* peopletable;
@property(nonatomic, strong) UILabel *emptyMessageLabel;
@property(nonatomic, strong) CHDPeopleViewModel *viewModel;
@property(nonatomic, strong) UIRefreshControl *refreshControl;

@property (nonatomic, strong) MASConstraint *messageCenterConstraint;
@property (nonatomic, strong) MASConstraint *addPersonCenterConstraint;

@property (nonatomic, assign) BOOL isExpanded;

@end

@implementation CHDPeopleViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.viewModel = [[CHDPeopleViewModel alloc] initWithSegmentIds:_segmentIds];
    [self makeViews];
    [self makeConstraints];
    [self makeBindings];
    // Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
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
    NSString *rightBarButtonTitle;
    if (self.peopletable.isEditing) {
        rightBarButtonTitle = NSLocalizedString(@"Cancel", @"");
    }
    else {
        rightBarButtonTitle = NSLocalizedString(@"Select", @"");
    }
    if (_segmentIds.count > 0) {
        [self.buttonContainer setHidden:YES];
    }
    else {
        self.chd_people_tabbarViewController.navigationItem.rightBarButtonItem.title = rightBarButtonTitle;
    }
    [self.chd_people_tabbarViewController.navigationItem.rightBarButtonItem setTarget:self];
    [self.chd_people_tabbarViewController.navigationItem.rightBarButtonItem setAction:@selector(selectAction:)];
    NSLog(@"timestamp %@ currentTime %@ time difference %f", timestamp, currentTime, timeDifference);
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
    [self rac_liftSelector:@selector(emptyMessageShow:) withSignals:[RACObserve(self.viewModel, people) map:^id(NSArray *people) {
        if(people == nil){
            return @NO;
        }
        return @(people.count == 0);
    }], nil];
    
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
    if ([clickedButton.title isEqualToString:NSLocalizedString(@"Select", @"")]) {
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

-(void) emptyMessageShow: (BOOL) show {
    if(show){
        [self.view addSubview:self.emptyMessageLabel];
        [self.emptyMessageLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self.view).offset(-30);
            make.centerX.equalTo(self.view);
            make.left.greaterThanOrEqualTo(self.view).offset(15);
            make.right.lessThanOrEqualTo(self.view).offset(-15);
        }];
    }else {
        [self.emptyMessageLabel removeFromSuperview];
    }
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
    cell.locationLabel.text = people.email;
    cell.titleLabel.text = people.fullName;
    cell.absenceIconView.hidden = true;
    [cell.cellBackgroundView setBorderColor:[UIColor clearColor]];
    cell.tintColor = [UIColor chd_blueColor];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    cell.userInteractionEnabled = YES;
    cell.titleLabel.textColor = [UIColor chd_textDarkColor];
    if (tableView.isEditing) {
        if (people.email == (id)[NSNull null] || people.email.length == 0 ) {
            cell.userInteractionEnabled = NO;
            cell.titleLabel.textColor = [UIColor lightGrayColor];
        }
        if ([self isPeopleSelected:people]) {
            [tableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
        }
    }
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index
{
    return [[UILocalizedIndexedCollation currentCollation] sectionForSectionIndexTitleAtIndex:index];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.viewModel.sectionIndices.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [[self.viewModel.peopleArrangedAccordingToIndex objectAtIndex:section] count];
}

-(UILabel *) emptyMessageLabel {
    if(!_emptyMessageLabel){
        _emptyMessageLabel = [UILabel new];
        _emptyMessageLabel.font = [UIFont chd_fontWithFontWeight:CHDFontWeightRegular size:17];
        _emptyMessageLabel.textColor = [UIColor shpui_colorWithHexValue:0xa8a8a8];
        _emptyMessageLabel.text = NSLocalizedString(@"No people to show", @"");
        _emptyMessageLabel.textAlignment = NSTextAlignmentCenter;
        _emptyMessageLabel.numberOfLines = 0;
    }
    return _emptyMessageLabel;
}

- (void) createMessageShow: (id) sender {
    CHDCreateMessageMailViewController* newMessageViewController = [CHDCreateMessageMailViewController new];
    newMessageViewController.selectedPeopleArray = _selectedPeopleArray;
    newMessageViewController.currentUser = self.viewModel.user;
    newMessageViewController.organizationId = self.viewModel.organizationId;
    UINavigationController *navigationVC = [[UINavigationController new] initWithRootViewController:newMessageViewController];
    [self toggleButtonAction:nil];
    [Heap track:@"People: Create message clicked"];
    [self presentViewController:navigationVC animated:YES completion:nil];
}

- (void) createPersonShow: (id) sender {
    [self toggleButtonAction:nil];
    CHDCreatePersonViewController *newPersonViewController = [CHDCreatePersonViewController new];
    UINavigationController *navigationVC = [[UINavigationController new] initWithRootViewController:newPersonViewController];
    [self presentViewController:navigationVC animated:YES completion:nil];
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
