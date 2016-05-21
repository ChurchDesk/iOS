//
//  CHDSegmentsViewController.m
//  ChurchDesk
//
//  Created by Chirag Sharma on 17/03/16.
//  Copyright © 2016 Shape A/S. All rights reserved.
//

#import "CHDSegmentsViewController.h"
#import "CHDSegmentViewModel.h"
#import "CHDPeopleTabBarController.h"
#import "CHDEventTableViewCell.h"
#import "CHDUser.h"
#import "CHDSegment.h"
#import "MBProgressHUD.h"
#import "CHDPeopleViewController.h"
#import "CHDCreateMessageMailViewController.h"

@interface CHDSegmentsViewController () <UITableViewDelegate, UITableViewDataSource>
@property (nonatomic, retain) UITableView* segmentstable;
@property(nonatomic, strong) UILabel *emptyMessageLabel;
@property(nonatomic, strong) CHDSegmentViewModel *viewModel;
@property(nonatomic, strong) UIRefreshControl *refreshControl;
//@property(nonatomic, strong) UIBarButtonItem *hamburgerMenuButton;
@property(nonatomic, strong) UIButton *messageButton;

@end

@implementation CHDSegmentsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.viewModel = [CHDSegmentViewModel new];
    [self makeViews];
    [self makeConstraints];
    [self makeBindings];
    // Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.segmentstable deselectRowAtIndexPath:[self.segmentstable indexPathForSelectedRow] animated:YES];
    //[self.segmentstable reloadData];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSDate *timestamp = [defaults valueForKey:kpeopleTimestamp];
    NSDate *currentTime = [NSDate date];
    NSTimeInterval timeDifference = [currentTime timeIntervalSinceDate:timestamp];
    if (timeDifference/60 > 10) {
        
    }
    [self.chd_people_tabbarViewController.navigationItem.rightBarButtonItem setTarget:self];
    [self.chd_people_tabbarViewController.navigationItem.rightBarButtonItem setAction:@selector(selectSegmentAction:)];
    if ([defaults boolForKey:ksuccessfulPeopleMessage]) {
        self.segmentstable.editing = NO;
        [[NSNotificationCenter defaultCenter] postNotificationName:khideTabButtons object:nil];
        [defaults setBool:NO forKey:ksuccessfulPeopleMessage];
        self.segmentstable.frame = CGRectMake(self.segmentstable.frame.origin.x, self.segmentstable.frame.origin.y, self.segmentstable.frame.size.width, self.segmentstable.frame.size.height - 50);
    }
    else if ([defaults boolForKey:ktoPeopleClicked]){
        self.segmentstable.editing = YES;
        [defaults setBool:NO forKey:ktoPeopleClicked];
    }
    NSString *rightBarButtonTitle;
    if (self.segmentstable.isEditing) {
        rightBarButtonTitle = NSLocalizedString(@"Cancel", @"");
    }
    else {
        rightBarButtonTitle = NSLocalizedString(@"Select", @"");
    }
    self.chd_people_tabbarViewController.navigationItem.rightBarButtonItem.title = rightBarButtonTitle;
    if (_selectedSegmentsArray.count == 0) {
        _selectedSegmentsArray = [[NSMutableArray alloc] init];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) makeViews {
    [self.view addSubview:self.segmentstable];
    [self.view addSubview:self.messageButton];
    if (_createMessage) {
        UIBarButtonItem *saveButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Done", @"") style:UIBarButtonItemStylePlain target:self action:@selector(selectSegmentAction:)];
        [saveButtonItem setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys: [UIColor whiteColor],  NSForegroundColorAttributeName,nil] forState:UIControlStateNormal];
        [saveButtonItem setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys: [UIColor chd_menuDarkBlue],  NSForegroundColorAttributeName,nil] forState:UIControlStateDisabled];
        self.navigationItem.rightBarButtonItem = saveButtonItem;
        [self.messageButton setHidden:YES];
    }
}

-(void) makeConstraints {
    UIView* superview = self.view;
    [self.segmentstable mas_makeConstraints:^(MASConstraintMaker *make){
        make.edges.equalTo(superview);
    }];
    [self.messageButton mas_makeConstraints:^(MASConstraintMaker *make){
        make.right.equalTo(superview);
        make.bottom.equalTo(superview).offset(-5);
    }];
}

-(void) makeBindings {
    RACSignal *newSegmentSignal = RACObserve(self.viewModel, segments);
    [self.segmentstable shprac_liftSelector:@selector(reloadData) withSignal:[RACSignal merge: @[newSegmentSignal]]];
    [self rac_liftSelector:@selector(emptyMessageShow:) withSignals:[RACObserve(self.viewModel, segments) map:^id(NSArray *segments) {
        if(segments == nil){
            return @NO;
        }
        return @(segments.count == 0);
    }], nil];
    
    [self shprac_liftSelector:@selector(endRefresh) withSignal:newSegmentSignal];
    
    [self shprac_liftSelector:@selector(showProgress:) withSignal:[[self rac_signalForSelector:@selector(viewWillDisappear:)] map:^id(id value) {
        return @NO;
    }]];
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

- (void)selectSegmentAction: (id) sender {
    UIBarButtonItem *clickedButton = (UIBarButtonItem *)sender;
    if ([clickedButton.title isEqualToString:NSLocalizedString(@"Select", @"")]) {
        [Heap track:@"Segments: Select clicked"];
        clickedButton.title = NSLocalizedString(@"Cancel", @"");
        self.segmentstable.editing = YES;
        [[NSNotificationCenter defaultCenter] postNotificationName:khideTabButtons object:nil];
        self.segmentstable.frame = CGRectMake(self.segmentstable.frame.origin.x, self.segmentstable.frame.origin.y, self.segmentstable.frame.size.width, self.segmentstable.frame.size.height + 50);
    }
    else if ([clickedButton.title isEqualToString:NSLocalizedString(@"Done", @"")]){
        [Heap track:@"Segments: Done clicked"];
        [_segmentDelegate sendSelectedPeopleArray:_selectedSegmentsArray];
        [self.navigationController popViewControllerAnimated:YES];
    }
    else{// cancel
        [Heap track:@"Segments: Cancel clicked"];
        [_selectedSegmentsArray removeAllObjects];
        //[self saveSelectedPeopleArray];
        clickedButton.title = NSLocalizedString(@"Select", @"");
        self.segmentstable.editing = NO;
        [[NSNotificationCenter defaultCenter] postNotificationName:khideTabButtons object:nil];
        self.segmentstable.frame = CGRectMake(self.segmentstable.frame.origin.x, self.segmentstable.frame.origin.y, self.segmentstable.frame.size.width, self.segmentstable.frame.size.height - 50);
    }
}

-(BOOL) isSegmentSelected :(CHDSegment *) segment{
    for (CHDSegment *selectedSegment in _selectedSegmentsArray) {
        if ([selectedSegment.segmentId isEqualToString:segment.segmentId]) {
            return YES;
            break;
        }
    }
    return NO;
}

- (void) createMessageShow: (id) sender {
    [Heap track:@"Segments: Create message clicked"];
    CHDCreateMessageMailViewController* newMessageViewController = [CHDCreateMessageMailViewController new];
    newMessageViewController.selectedPeopleArray = _selectedSegmentsArray;
    newMessageViewController.currentUser = self.viewModel.user;
    newMessageViewController.organizationId = self.viewModel.organizationId;
    newMessageViewController.isSegment = YES;
    UINavigationController *navigationVC = [[UINavigationController new] initWithRootViewController:newMessageViewController];
    [self presentViewController:navigationVC animated:YES completion:nil];
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    CHDSegment* segment = [self.viewModel.segments objectAtIndex:indexPath.row];
    if (self.segmentstable.isEditing) {
        if (![self isSegmentSelected:segment]) {
            [_selectedSegmentsArray addObject:segment];
        }
    }
    else{
        [Heap track:@"Segment detail clicked"];
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        CHDPeopleViewController *pvc = [[CHDPeopleViewController alloc] init];
        pvc.segmentIds = [NSArray arrayWithObjects:segment.segmentId, nil];
        pvc.title = segment.name;
        [self.navigationController pushViewController:pvc animated:YES];
    }
}

-(void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath{
    CHDSegment* selectedSegment = [self.viewModel.segments objectAtIndex:indexPath.row];
    for (CHDSegment *selectedSegmentFromArray in _selectedSegmentsArray) {
        if ([selectedSegmentFromArray.segmentId isEqualToString:selectedSegment.segmentId]) {
            [_selectedSegmentsArray removeObject:selectedSegmentFromArray];
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

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString* cellIdentifier = @"segmentCell";
    CHDSegment* segment = [self.viewModel.segments objectAtIndex:indexPath.row];
    CHDEventTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    cell.titleLabel.text = segment.name;
    cell.absenceIconView.hidden = true;
    cell.tintColor = [UIColor chd_blueColor];
    [cell.cellBackgroundView setBorderColor:[UIColor clearColor]];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    if (tableView.isEditing) {
        if ([self isSegmentSelected:segment]) {
            [tableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
        }
    }
    return cell;
}



- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.viewModel.segments count];
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

#pragma mark - Lazy Initialization

-(UITableView*)segmentstable {
    if(!_segmentstable){
        _segmentstable = [[UITableView alloc] init];
        _segmentstable.separatorStyle = UITableViewCellSeparatorStyleNone;
        _segmentstable.backgroundView.backgroundColor = [UIColor chd_lightGreyColor];
        _segmentstable.backgroundColor = [UIColor chd_lightGreyColor];
        [_segmentstable registerClass:[CHDEventTableViewCell class] forCellReuseIdentifier:@"segmentCell"];
        _segmentstable.dataSource = self;
        _segmentstable.delegate = self;
        _segmentstable.allowsSelection = YES;
        _segmentstable.allowsSelectionDuringEditing = YES;
        _segmentstable.allowsMultipleSelectionDuringEditing = YES;
    }
    return _segmentstable;
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
