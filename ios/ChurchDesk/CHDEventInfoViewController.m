//
//  CHDEventInfoViewController.m
//  ChurchDesk
//
//  Created by Mikkel Selsøe Sørensen on 26/02/15.
//  Copyright (c) 2015 Shape A/S. All rights reserved.
//

#import <MBProgressHUD/MBProgressHUD.h>
#import "CHDEventInfoViewController.h"
#import "CHDEventInfoViewModel.h"
#import "CHDEventInfoTableViewCell.h"
#import "CHDEventGroupTableViewCell.h"
#import "CHDEventLocationTableViewCell.h"
#import "CHDDividerTableViewCell.h"
#import "CHDCommonTableViewCell.h"
#import "CHDEventAttendanceTableViewCell.h"
#import "CHDEvent.h"
#import "CHDEventTitleImageTableViewCell.h"
#import "Haneke.h"
#import "CHDEventCategoriesTableViewCell.h"
#import "CHDEventUsersTableViewCell.h"
#import "CHDEventInternalNoteTableViewCell.h"
#import "CHDEventTextValueTableViewCell.h"
#import "CHDEventDescriptionTableViewCell.h"
#import "CHDEnvironment.h"
#import "CHDEditEventViewController.h"
#import "CHDDescriptionViewController.h"
#import "CHDEventUserDetailsViewController.h"
#import "CHDUser.h"
#import "CHDListViewController.h"
#import "CHDAnalyticsManager.h"

@interface CHDEventInfoViewController () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) CHDEventInfoViewModel *viewModel;
@property (nonatomic, strong) NSDateFormatter *creationDateFormatter;
@property (nonatomic, strong) NSDateFormatter *eventDateFormatter;

@property (nonatomic, strong) UIBarButtonItem *editItem;

@end

@implementation CHDEventInfoViewController

- (instancetype)initWithEventId: (NSNumber*) eventId siteId: (NSString*) siteId {
    if (self = [super init]) {
        self.viewModel = [[CHDEventInfoViewModel alloc] initWithEventId:eventId siteId:siteId];
    }
    return self;
}

- (instancetype)initWithEvent: (CHDEvent*) event {
    if (self = [super init]) {
        self.viewModel = [[CHDEventInfoViewModel alloc] initWithEvent:event];
    }
    return self;
}

#pragma mark -Life cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = NSLocalizedString(@"Event Information", @"");
    
    [self setupSubviews];
    [self makeConstraints];
    [self setupBindings];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self showProgress:NO];
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[CHDAnalyticsManager sharedInstance] trackVisitToScreen:@"event information"];
    [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:YES];
}

#pragma mark -setup
- (void) setupSubviews {
    [self.view addSubview:self.tableView];
}

- (void) makeConstraints {
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
}

- (void) setupBindings {
    [self.tableView shprac_liftSelector:@selector(reloadData) withSignal:[[RACSignal merge:@[RACObserve(self.viewModel, event), RACObserve(self.viewModel, environment), RACObserve(self.viewModel, user), RACObserve(self.viewModel, event.eventResponse)]] ignore:nil]];
    
    UIBarButtonItem *editItem = self.editItem;
    RAC(self.navigationItem, rightBarButtonItem) = [RACObserve(self.viewModel, event) map:^id(CHDEvent *event) {
        return event.canEdit ? editItem : nil;
    }];

    [self rac_liftSelector:@selector(showProgress:) withSignals:[self.viewModel.loadCommand executing], nil];
}

#pragma mark - Actions

- (void)editEventAction: (id) sender {
    CHDEditEventViewController *vc = [[CHDEditEventViewController alloc] initWithEvent:self.viewModel.event];
    vc.title = NSLocalizedString(@"Edit Event", @"");
    
    RACSignal *saveSignal = [RACObserve(vc, event) skip:1];
    [self.viewModel rac_liftSelector:@selector(setEvent:) withSignals:saveSignal, nil];
    [self rac_liftSelector:@selector(dismissViewControllerAnimated:completion:) withSignals:[saveSignal mapReplace:@YES], [RACSignal return:nil], nil];
    
    [self presentViewController:[[UINavigationController alloc] initWithRootViewController:vc] animated:YES completion:nil];
}

- (void)directionsAction: (id) sender {
    NSString *location = self.viewModel.event.location;
    NSString *message = [NSString stringWithFormat:NSLocalizedString(@"Do you want to open Maps to get directions to \'%@\'?", @""), location];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Maps", @"") message:message delegate:nil cancelButtonTitle:NSLocalizedString(@"Cancel", @"") otherButtonTitles:NSLocalizedString(@"Open Maps", @""), nil];
    
    [self.viewModel rac_liftSelector:@selector(openMapsWithLocationString:) withSignals:[[[alert rac_buttonClickedSignal] ignore:@(alert.cancelButtonIndex)] mapReplace:location], nil];
    
    [alert show];
}

- (void)reportAttendanceAction: (id) sender {
    NSString *title = [NSString stringWithFormat:NSLocalizedString(@"Are you going to the event '%@'?", @""), self.viewModel.event.title];
    UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:title delegate:nil cancelButtonTitle:NSLocalizedString(@"Cancel", @"") destructiveButtonTitle:nil otherButtonTitles:NSLocalizedString(@"Going", @""), NSLocalizedString(@"Maybe", @""), NSLocalizedString(@"Not going", @""), nil];
    NSInteger firstOtherButtonIndex = sheet.firstOtherButtonIndex;
    
    @weakify(self)
    [[self.viewModel rac_liftSelector:@selector(respondToEventWithResponse:) withSignals:[[sheet.rac_buttonClickedSignal ignore:@(sheet.cancelButtonIndex)] map:^id(NSNumber *nButtonIndex) {
        if (nButtonIndex.integerValue == firstOtherButtonIndex) {
            return @(CHDEventResponseGoing);
        }
        else if (nButtonIndex.integerValue == firstOtherButtonIndex+1) {
            return @(CHDEventResponseMaybe);
        }
        else if (nButtonIndex.integerValue == firstOtherButtonIndex+2) {
            return @(CHDEventResponseNotGoing);
        }
        else {
            NSAssert(NO, @"Unknown button index");
            return nil;
        }
    }], nil] subscribeError:^(NSError *error) {
        [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", @"") message:NSLocalizedString(@"An error occured while sending your response to the server. Please try again.", @"") delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", @"") otherButtonTitles: nil] show];
        @strongify(self)
        [self reportAttendanceAction:nil];
    }];
    
    [sheet showInView:self.view];
}

-(void) showProgress: (BOOL) show {
    if(show) {
        [MBProgressHUD hideAllHUDsForView:self.navigationController.view animated:YES];
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];

        // Configure for text only and offset down
        hud.mode = MBProgressHUDModeIndeterminate;
        hud.color = [UIColor colorWithWhite:1 alpha:0.7];
        hud.labelColor = [UIColor chd_textDarkColor];
        hud.activityIndicatorColor = [UIColor blackColor];
        hud.margin = 10.f;
        hud.removeFromSuperViewOnHide = YES;
        hud.userInteractionEnabled = NO;
    }else{
        [MBProgressHUD hideAllHUDsForView:self.navigationController.view animated:YES];
    }
}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSArray *sections = self.viewModel.sections;
    NSString *section = sections[indexPath.section];
    NSArray *rows = [self.viewModel rowsForSection:section];
    NSString *row = rows[indexPath.row];

    if ([row isEqualToString:CHDEventInfoRowImage]) {
        return 227;
    }
    return 45;
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.viewModel.sections.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.viewModel rowsForSection:self.viewModel.sections[section]].count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *returnCell = nil;
    CHDEvent *event = self.viewModel.event;
    CHDEnvironment *environment = self.viewModel.environment;
    
    NSArray *sections = self.viewModel.sections;
    NSString *section = sections[indexPath.section];
    NSArray *rows = [self.viewModel rowsForSection:section];
    NSString *row = rows[indexPath.row];
    
    // Base information
    if ([row isEqualToString:CHDEventInfoRowImage]) {
        CHDEventTitleImageTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"image" forIndexPath:indexPath];
        cell.titleLabel.text = event.title;
        [cell layoutIfNeeded];
        [cell.titleImageView hnk_setImageFromURL:event.pictureURL];
        returnCell = cell;
    }
    else if ([row isEqualToString:CHDEventInfoRowGroup]) {
        CHDEventGroupTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"group" forIndexPath:indexPath];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.titleLabel.text = [environment groupWithId:event.groupId].name;
        cell.groupLabel.text = [self.viewModel parishName];
        returnCell = cell;
    }
    else if ([row isEqualToString:CHDEventInfoRowDate]) {
        CHDEventInfoTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.iconImageView.image = kImgEventTime;
        cell.titleLabel.text = [self.viewModel eventDateString];
        cell.titleLabel.font = [UIFont chd_fontWithFontWeight:CHDFontWeightRegular size:cell.titleLabel.font.pointSize];
        cell.disclosureArrowHidden = YES;
        returnCell = cell;
    }
    else if ([row isEqualToString:CHDEventInfoRowLocation]) {
        CHDEventLocationTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"location" forIndexPath:indexPath];
        cell.titleLabel.text = event.location;
        [self rac_liftSelector:@selector(directionsAction:) withSignals:[[cell.directionsButton rac_signalForControlEvents:UIControlEventTouchUpInside] takeUntil:cell.rac_prepareForReuseSignal], nil];
        returnCell = cell;
    }
    else if ([row isEqualToString:CHDEventInfoRowCategories]) {
        CHDEventCategoriesTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"categories" forIndexPath:indexPath];
        cell.titleLabel.text = NSLocalizedString(@"Categories", @"");
        [cell setCategoryTitles:[self.viewModel categoryTitles] colors:[self.viewModel categoryColors]];
        returnCell = cell;
    }
    else if ([row isEqualToString:CHDEventInfoRowAttendance]) {
        CHDEventAttendanceTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"attendance" forIndexPath:indexPath];
        [cell.attendanceButton setTitle:[self.viewModel textForEventResponse:event.eventResponse] forState:UIControlStateNormal];
        [cell.attendanceButton setTitleColor:[self.viewModel textColorForEventResponse:event.eventResponse] forState:UIControlStateNormal];
        [self rac_liftSelector:@selector(reportAttendanceAction:) withSignals:[[cell.attendanceButton rac_signalForControlEvents:UIControlEventTouchUpInside] takeUntil:cell.rac_prepareForReuseSignal], nil];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        returnCell = cell;
    }
    
    // Resources
    else if ([row isEqualToString:CHDEventInfoRowResources]) {
        CHDEventCategoriesTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"categories" forIndexPath:indexPath];
        cell.titleLabel.text = NSLocalizedString(@"Resources", @"");
        [cell setCategoryTitles:[self.viewModel resourceTitles] colors:[self.viewModel resourceColors]];
        returnCell = cell;
    }
    else if ([row isEqualToString:CHDEventInfoRowUsers]) {
        CHDEventUsersTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"users" forIndexPath:indexPath];
        [cell setUserNames:[self.viewModel userNames]];
        returnCell = cell;
    }
    else if ([row isEqualToString:CHDEventInfoRowInternalNote]) {
        CHDEventInternalNoteTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"internalNote" forIndexPath:indexPath];
        cell.noteLabel.text = event.internalNote;
        returnCell = cell;
    }
    
    // Contributor
    else if ([row isEqualToString:CHDEventInfoRowContributor]) {
        CHDEventTextValueTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"textValue" forIndexPath:indexPath];
        cell.titleLabel.text = NSLocalizedString(@"Contributor", @"");
        cell.valueLabel.text = event.contributor;
        returnCell = cell;
    }
    else if ([row isEqualToString:CHDEventInfoRowPrice]) {
        CHDEventTextValueTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"textValue" forIndexPath:indexPath];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.titleLabel.text = NSLocalizedString(@"Price", @"");
        cell.valueLabel.text = event.price;
        returnCell = cell;
    }
    else if ([row isEqualToString:CHDEventInfoRowDescription]) {
        CHDEventDescriptionTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"description" forIndexPath:indexPath];
        cell.descriptionLabel.text = event.eventDescription;
        returnCell = cell;
    }
    
    // Visibility
    else if ([row isEqualToString:CHDEventInfoRowVisibility]) {
        CHDEventTextValueTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"textValue" forIndexPath:indexPath];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.titleLabel.text = NSLocalizedString(@"Visibility", @"");
        cell.valueLabel.text = [event localizedVisibilityString];
        returnCell = cell;
    }
    else if ([row isEqualToString:CHDEventInfoRowCreated]) {
        CHDEventTextValueTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"textValue" forIndexPath:indexPath];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.titleLabel.text = NSLocalizedString(@"Created On", @"");
        cell.valueLabel.text = [self.creationDateFormatter stringFromDate:event.creationDate];
        returnCell = cell;
    }
    
    // Dividers
    else if ([section isEqualToString:CHDEventInfoSectionDivider]) {
        CHDDividerTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"divider" forIndexPath:indexPath];
        cell.hideBottomLine = indexPath.section == tableView.numberOfSections-1 && indexPath.row == [tableView numberOfRowsInSection:indexPath.section]-1;
        returnCell = cell;
    }
    
    if ([returnCell respondsToSelector:@selector(setDividerLineHidden:)]) {
        [(CHDEventInfoTableViewCell*)returnCell setDividerLineHidden: indexPath.row == [tableView numberOfRowsInSection:indexPath.section]-1];
    }
    return returnCell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    CHDEvent *event = self.viewModel.event;

    NSArray *sections = self.viewModel.sections;
    NSString *section = sections[indexPath.section];
    NSArray *rows = [self.viewModel rowsForSection:section];
    NSString *row = rows[indexPath.row];
    if([row isEqualToString:CHDEventInfoRowInternalNote]){
        CHDDescriptionViewController *detailedViewController = [[CHDDescriptionViewController alloc] initWithDescription:event.internalNote];
        detailedViewController.title = NSLocalizedString(@"Internal Note", @"");
        [self.navigationController pushViewController:detailedViewController animated:YES];
    }
    else if ([row isEqualToString:CHDEventInfoRowDescription]) {
        CHDDescriptionViewController *detailedViewController = [[CHDDescriptionViewController alloc] initWithDescription:event.eventDescription];
        detailedViewController.title = NSLocalizedString(@"Description", @"");
        [self.navigationController pushViewController:detailedViewController animated:YES];
    }
    else if ([row isEqualToString:CHDEventInfoRowUsers]) {
        CHDEventUserDetailsViewController *vc = [[CHDEventUserDetailsViewController alloc] initWithEvent:event];
        [self.navigationController pushViewController:vc animated:YES];
    }
    else if ([row isEqualToString:CHDEventInfoRowCategories]){

        NSMutableArray *items = [[NSMutableArray alloc] init];
        for(NSNumber *categoryId in event.eventCategoryIds){
            CHDEventCategory *category = [self.viewModel.environment eventCategoryWithId:categoryId siteId:event.siteId];
            CHDListConfigModel *configItem = [[CHDListConfigModel alloc] initWithTitle:category.name color:category.color];
            [items addObject:configItem];
        }

        CHDListViewController *vc = [[CHDListViewController alloc] initWithItems:items];
        vc.title = NSLocalizedString(@"Categories", @"");
        [self.navigationController pushViewController:vc animated:YES];
    }
    else if ([row isEqualToString:CHDEventInfoRowResources]){
        NSMutableArray *items = [[NSMutableArray alloc] init];
        for(NSNumber *resourceId in event.resourceIds){
            CHDResource *resource = [self.viewModel.environment resourceWithId:resourceId siteId:event.siteId];
            CHDListConfigModel *configItem = [[CHDListConfigModel alloc] initWithTitle:resource.name color:resource.color];
            [items addObject:configItem];
        }

        CHDListViewController *vc = [[CHDListViewController alloc] initWithItems:items];
        vc.title = NSLocalizedString(@"Resources", @"");
        [self.navigationController pushViewController:vc animated:YES];
    }
    else if ([row isEqualToString:CHDEventInfoRowAttendance]) {
        [self.view endEditing:YES];
        [self reportAttendanceAction:nil];
    }
}


#pragma mark - Lazy Initialization

- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [UITableView new];
        _tableView.dataSource = self;
        _tableView.delegate = self;
        _tableView.estimatedRowHeight = 45;
        _tableView.rowHeight = UITableViewAutomaticDimension;
        _tableView.backgroundColor = [UIColor chd_lightGreyColor];
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;

        [_tableView registerClass:[CHDEventTitleImageTableViewCell class] forCellReuseIdentifier:@"image"];
        [_tableView registerClass:[CHDEventInfoTableViewCell class] forCellReuseIdentifier:@"cell"];
        [_tableView registerClass:[CHDEventGroupTableViewCell class] forCellReuseIdentifier:@"group"];
        [_tableView registerClass:[CHDEventLocationTableViewCell class] forCellReuseIdentifier:@"location"];
        [_tableView registerClass:[CHDEventAttendanceTableViewCell class] forCellReuseIdentifier:@"attendance"];
        [_tableView registerClass:[CHDEventCategoriesTableViewCell class] forCellReuseIdentifier:@"categories"];
        [_tableView registerClass:[CHDEventUsersTableViewCell class] forCellReuseIdentifier:@"users"];
        [_tableView registerClass:[CHDEventInternalNoteTableViewCell class] forCellReuseIdentifier:@"internalNote"];
        [_tableView registerClass:[CHDEventTextValueTableViewCell class] forCellReuseIdentifier:@"textValue"];
        [_tableView registerClass:[CHDEventDescriptionTableViewCell class] forCellReuseIdentifier:@"description"];
        
        [_tableView registerClass:[CHDDividerTableViewCell class] forCellReuseIdentifier:@"divider"];
    }
    return _tableView;
}

- (NSDateFormatter *)creationDateFormatter {
    if (!_creationDateFormatter) {
        _creationDateFormatter = [NSDateFormatter new];
        _creationDateFormatter.dateStyle = NSDateFormatterMediumStyle;
        _creationDateFormatter.timeStyle = NSDateFormatterNoStyle;
    }
    return _creationDateFormatter;
}

- (UIBarButtonItem *)editItem {
    if (!_editItem) {
        _editItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Edit", @"") style:UIBarButtonItemStylePlain target:self action:@selector(editEventAction:)];
    }
    return _editItem;
}

@end
