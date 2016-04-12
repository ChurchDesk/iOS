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

@interface CHDSegmentsViewController () <UITableViewDelegate, UITableViewDataSource>
@property (nonatomic, retain) UITableView* segmentstable;
@property(nonatomic, strong) UILabel *emptyMessageLabel;
@property (nonatomic, readonly) CHDUser *user;
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
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) makeViews {
    [self.view addSubview:self.segmentstable];
    UIBarButtonItem *selectButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Select", @"") style:UIBarButtonItemStylePlain target:self action:@selector(selectAction:)];
    [selectButtonItem setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys: [UIColor whiteColor],  NSForegroundColorAttributeName,nil] forState:UIControlStateNormal];
    [selectButtonItem setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys: [UIColor chd_menuDarkBlue],  NSForegroundColorAttributeName,nil] forState:UIControlStateDisabled];
    self.chd_people_tabbarViewController.navigationItem.rightBarButtonItem = selectButtonItem;
}

-(void) makeConstraints {
    UIView* superview = self.view;
    [self.segmentstable mas_makeConstraints:^(MASConstraintMaker *make){
        make.edges.equalTo(superview);
    }];
    [self.segmentstable mas_makeConstraints:^(MASConstraintMaker *make){
        make.right.equalTo(superview);
        make.bottom.equalTo(superview).offset(-5);
    }];
}

- (void)selectAction: (id) sender {
    UIBarButtonItem *clickedButton = (UIBarButtonItem *)sender;
    if ([clickedButton.title isEqualToString:NSLocalizedString(@"Select", @"")]) {
        clickedButton.title = NSLocalizedString(@"Cancel", @"");
        self.segmentstable.editing = YES;
    }
    else{// cancel
        self.chd_people_tabbarViewController.navigationItem.rightBarButtonItem.title = NSLocalizedString(@"Select", @"");
        self.segmentstable.editing = NO;
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

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
}

-(void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath{
}

#pragma mark - UITableViewDataSource
- (void)refresh:(UIRefreshControl *)refreshControl {
    //[self.viewModel reload];
}

-(void)endRefresh {
    [self.refreshControl endRefreshing];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString* cellIdentifier = @"peopleCell";
    //CHDPeople* people = [[self.viewModel.peopleArrangedAccordingToIndex objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    //    CHDUser* user = self.viewModel.user;
    //    CHDSite* site = [user siteWithId:event.siteId];
    
    CHDEventTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    //cell.locationLabel.text = people.email;
    //    if ([event.type isEqualToString:kAbsence]) {
    //cell.titleLabel.text = people.fullName;
    //        cell.titleLabel.textColor = [UIColor grayColor];
    //        cell.absenceIconView.hidden = false;
    //    }
    //    else{
    //        cell.titleLabel.text = event.title;
    //        cell.titleLabel.textColor = [UIColor chd_textDarkColor];
    //cell.absenceIconView.hidden = true;
    //    }
    //    cell.parishLabel.text = user.sites.count > 1? site.name : @"";
    //    cell.dateTimeLabel.text = [self.viewModel formattedTimeForEvent:event];
    //
    //    if ([event.type isEqualToString:kAbsence]) {
    //        CHDAbsenceCategory *category = [self.viewModel.environment absenceCategoryWithId:event.eventCategoryIds.firstObject siteId: event.siteId];
    //        [cell.cellBackgroundView setBorderColor:category.color?: [UIColor clearColor]];
    //    }
    //    else{
    //        CHDEventCategory *category = [self.viewModel.environment eventCategoryWithId:event.eventCategoryIds.firstObject siteId: event.siteId];
    //        [cell.cellBackgroundView setBorderColor:category.color?: [UIColor clearColor]];
    //    }
    //cell.tintColor = [UIColor chd_blueColor];
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index
{
    return [[UILocalizedIndexedCollation currentCollation] sectionForSectionIndexTitleAtIndex:index];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
