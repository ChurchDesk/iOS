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

@interface CHDPeopleViewController () <UITableViewDelegate, UITableViewDataSource, UISearchDisplayDelegate, UIScrollViewDelegate>
@property (nonatomic, retain) UITableView* peopletable;
@property(nonatomic, strong) UILabel *emptyMessageLabel;
@property (nonatomic, readonly) CHDUser *user;
@property(nonatomic, strong) CHDPeopleViewModel *viewModel;
@property(nonatomic, strong) UIRefreshControl *refreshControl;
//@property(nonatomic, strong) UIBarButtonItem *hamburgerMenuButton;
@property(nonatomic, strong) UIButton *messageButton;


@end

@implementation CHDPeopleViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.viewModel = [CHDPeopleViewModel new];
    [self makeViews];
    [self makeConstraints];
    [self makeBindings];
    _selectedPeopleArray = [[NSMutableArray alloc] init];
    // Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    //[self.peopletable deselectRowAtIndexPath:[self.peopletable indexPathForSelectedRow] animated:YES];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSData *encodedObject = [defaults objectForKey:@"currentUser"];
    _user = [NSKeyedUnarchiver unarchiveObjectWithData:encodedObject];
    NSDate *timestamp = [defaults valueForKey:kpeopleTimestamp];
    NSDate *currentTime = [NSDate date];
    NSTimeInterval timeDifference = [currentTime timeIntervalSinceDate:timestamp];
    [self.viewModel refreshData];
    [self.peopletable reloadData];
    //self.chd_people_tabbarViewController.title = [NSString stringWithFormat:@"(%d) %@",NSLocalizedString(@"People", @""), self.viewModel.people.count];
    
    if (_user.sites.count > 0) {
        CHDSite *selectedSite = [_user.sites objectAtIndex:0];
        _organizationId = selectedSite.siteId;
        self.viewModel.organizationId = _organizationId;
    }
    if (timeDifference/60 > 10) {
        
    }
    if ([defaults boolForKey:ksuccessfulPeopleMessage]) {
        self.peopletable.editing = NO;
        [defaults setBool:NO forKey:ksuccessfulPeopleMessage];
    }
    if (self.peopletable.isEditing) {
        self.chd_people_tabbarViewController.navigationItem.rightBarButtonItem.title = NSLocalizedString(@"Cancel", @"");
    } else{
        self.chd_people_tabbarViewController.navigationItem.rightBarButtonItem.title = NSLocalizedString(@"Select", @"");
    }
    NSLog(@"timestamp %@ currentTime %@ time difference %f", timestamp, currentTime, timeDifference);
    NSLog(@"user %@", _user.name);
}

-(void) makeViews {
    [self.view addSubview:self.peopletable];
    [self.view addSubview:self.messageButton];
    UIBarButtonItem *saveButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Select", @"") style:UIBarButtonItemStylePlain target:self action:@selector(selectAction:)];
    [saveButtonItem setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys: [UIColor whiteColor],  NSForegroundColorAttributeName,nil] forState:UIControlStateNormal];
    [saveButtonItem setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys: [UIColor chd_menuDarkBlue],  NSForegroundColorAttributeName,nil] forState:UIControlStateDisabled];
    self.chd_people_tabbarViewController.navigationItem.rightBarButtonItem = saveButtonItem;
}

-(void) makeConstraints {
    UIView* superview = self.view;
    [self.peopletable mas_makeConstraints:^(MASConstraintMaker *make){
        make.edges.equalTo(superview);
    }];
    [self.messageButton mas_makeConstraints:^(MASConstraintMaker *make){
        make.right.equalTo(superview);
        make.bottom.equalTo(superview).offset(-5);
    }];
}

-(void) makeBindings {
    RACSignal *newPeopleSignal = RACObserve(self.viewModel, people);
    [self.peopletable shprac_liftSelector:@selector(reloadData) withSignal:[RACSignal merge: @[newPeopleSignal]]];
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

- (void)selectAction: (id) sender {
    UIBarButtonItem *clickedButton = (UIBarButtonItem *)sender;
    if ([clickedButton.title isEqualToString:NSLocalizedString(@"Select", @"")]) {
        clickedButton.title = NSLocalizedString(@"Cancel", @"");
        self.peopletable.editing = YES;
    }
    else{// cancel
        [_selectedPeopleArray removeAllObjects];
        self.chd_people_tabbarViewController.navigationItem.rightBarButtonItem.title = NSLocalizedString(@"Select", @"");
        self.peopletable.editing = NO;
    }
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
        if (![_selectedPeopleArray containsObject:selectedPeople]) {
            [_selectedPeopleArray addObject:selectedPeople];
        }
    }
    else{
        [tableView deselectRowAtIndexPath:indexPath animated:NO];
    }
}

-(void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath{
    CHDPeople* selectedPeople = [[self.viewModel.peopleArrangedAccordingToIndex objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    if ([_selectedPeopleArray containsObject:selectedPeople]) {
        [_selectedPeopleArray removeObject:selectedPeople];
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
//    CHDUser* user = self.viewModel.user;
//    CHDSite* site = [user siteWithId:event.siteId];
    
    CHDEventTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    cell.locationLabel.text = people.email;
//    if ([event.type isEqualToString:kAbsence]) {
        cell.titleLabel.text = people.fullName;
//        cell.titleLabel.textColor = [UIColor grayColor];
//        cell.absenceIconView.hidden = false;
//    }
//    else{
//        cell.titleLabel.text = event.title;
//        cell.titleLabel.textColor = [UIColor chd_textDarkColor];
        cell.absenceIconView.hidden = true;
//    }
//    cell.parishLabel.text = user.sites.count > 1? site.name : @"";
//    cell.dateTimeLabel.text = [self.viewModdel formattedTimeForEvent:event];
//    
//    if ([event.type isEqualToString:kAbsence]) {
//        CHDAbsenceCategory *category = [self.viewModel.environment absenceCategoryWithId:event.eventCategoryIds.firstObject siteId: event.siteId];
//        [cell.cellBackgroundView setBorderColor:category.color?: [UIColor clearColor]];
//    }
//    else{
//        CHDEventCategory *category = [self.viewModel.environment eventCategoryWithId:event.eventCategoryIds.firstObject siteId: event.siteId];
//        [cell.cellBackgroundView setBorderColor:category.color?: [UIColor clearColor]];
//    }
    cell.tintColor = [UIColor chd_blueColor];
    if ([tableView isEditing] && [_selectedPeopleArray containsObject:people]) {
        [cell setSelected:YES animated:NO];
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
    newMessageViewController.currentUser = _user;
    newMessageViewController.organizationId = _organizationId;
    UINavigationController *navigationVC = [[UINavigationController new] initWithRootViewController:newMessageViewController];
    [Heap track:@"Create new people message"];
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
        [_messageButton addTarget:self
                   action:@selector(createMessageShow:)
         forControlEvents:UIControlEventTouchUpInside];
        [_messageButton setImage:kImgCreateMessage forState:UIControlStateNormal];
    }
    return _messageButton;
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
