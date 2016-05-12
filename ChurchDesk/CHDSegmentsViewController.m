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
#import "CHDSelectorTableViewCell.h"
#import "CHDUser.h"
#import "CHDSegment.h"
#import "MBProgressHUD.h"
#import "CHDPeopleViewController.h"

@interface CHDSegmentsViewController () <UITableViewDelegate, UITableViewDataSource>
@property (nonatomic, retain) UITableView* segmentstable;
@property(nonatomic, strong) UILabel *emptyMessageLabel;
@property(nonatomic, strong) CHDSegmentViewModel *viewModel;
@property(nonatomic, strong) UIRefreshControl *refreshControl;
//@property(nonatomic, strong) UIBarButtonItem *hamburgerMenuButton;
@property(nonatomic, strong) NSMutableArray *selectedSegmentsArray;
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
    self.chd_people_tabbarViewController.navigationItem.rightBarButtonItem.title = @"";
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) makeViews {
    [self.view addSubview:self.segmentstable];
}

-(void) makeConstraints {
    UIView* superview = self.view;
    [self.segmentstable mas_makeConstraints:^(MASConstraintMaker *make){
        make.edges.equalTo(superview);
    }];
    [self.segmentstable mas_makeConstraints:^(MASConstraintMaker *make){
        make.right.equalTo(superview);
        make.bottom.equalTo(superview);
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

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    CHDSegment* segment = [self.viewModel.segments objectAtIndex:indexPath.row];
    CHDPeopleViewController *pvc = [[CHDPeopleViewController alloc] init];
    pvc.segmentIds = [NSArray arrayWithObjects:segment.segmentId, nil];
    pvc.title = segment.name;
    [self.navigationController pushViewController:pvc animated:YES];
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
    CHDSelectorTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    cell.titleLabel.text = segment.name;
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
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
        [_segmentstable registerClass:[CHDSelectorTableViewCell class] forCellReuseIdentifier:@"segmentCell"];
        _segmentstable.dataSource = self;
        _segmentstable.delegate = self;
        _segmentstable.allowsSelection = YES;
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
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
