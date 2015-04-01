//
//  CHDEditEventViewController.m
//  ChurchDesk
//
//  Created by Mikkel Selsøe Sørensen on 06/03/15.
//  Copyright (c) 2015 Shape A/S. All rights reserved.
//

#import <SHPNetworking/SHPAPIManager+ReactiveExtension.h>
#import "CHDEditEventViewController.h"
#import "CHDEditEventViewModel.h"
#import "CHDDividerTableViewCell.h"
#import "CHDEventTextFieldCell.h"
#import "CHDEventValueTableViewCell.h"
#import "CHDEvent.h"
#import "CHDUser.h"
#import "CHDEnvironment.h"
#import "CHDEventTextViewTableViewCell.h"
#import "SHPKeyboardAwareness.h"
#import "CHDListSelectorViewController.h"
#import "CHDGroup.h"
#import "CHDEventCategory.h"
#import "CHDEventSwitchTableViewCell.h"
#import "CHDDatePickerViewController.h"
#import "CHDEventAlertView.h"

@interface CHDEditEventViewController () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) CHDEvent *event;
@property (nonatomic, strong) CHDEditEventViewModel *viewModel;
@property (nonatomic, strong) NSDateFormatter *dateFormatter;

@end

@implementation CHDEditEventViewController

- (instancetype)initWithEvent: (CHDEvent*) event {
    self = [super init];
    if (self) {
        _event = event;
        self.viewModel = [[CHDEditEventViewModel alloc] initWithEvent: event];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    self.title = self.viewModel.newEvent ? NSLocalizedString(@"New Event", @"") : NSLocalizedString(@"Edit Event", @"");
    self.tableView.backgroundColor = [UIColor chd_lightGreyColor];

    [self setupSubviews];
    [self makeConstraints];
    [self setupBindings];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:animated];
}

- (void) setupSubviews {
    [self.view addSubview:self.tableView];

    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Cancel", @"") style:UIBarButtonItemStylePlain target:self action:@selector(cancelAction:)];
    UIBarButtonItem *saveButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Save", @"") style:UIBarButtonItemStylePlain target:self action:@selector(saveAction:)];
    [saveButtonItem setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys: [UIColor whiteColor],  NSForegroundColorAttributeName,nil] forState:UIControlStateNormal];
    [saveButtonItem setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys: [UIColor chd_menuDarkBlue],  NSForegroundColorAttributeName,nil] forState:UIControlStateDisabled];
    self.navigationItem.rightBarButtonItem = saveButtonItem;
}

- (void) makeConstraints {
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
}

- (void) setupBindings {
    [self.tableView shprac_liftSelector:@selector(reloadData) withSignal:[[RACSignal merge:@[RACObserve(self.viewModel, environment), RACObserve(self.viewModel, user), RACObserve(self.viewModel.event, siteId), RACObserve(self.viewModel.event, groupId), RACObserve(self.viewModel.event, eventCategoryIds), RACObserve(self.viewModel.event, userIds), RACObserve(self.viewModel.event, resourceIds), RACObserve(self.viewModel.event, startDate), RACObserve(self.viewModel.event, endDate), RACObserve(self.viewModel, sectionRows)]] ignore:nil]];

    [self rac_liftSelector:@selector(handleKeyboardEvent:) withSignals:[self shp_keyboardAwarenessSignal], nil];

    [self.navigationItem.leftBarButtonItem rac_liftSelector:@selector(setEnabled:) withSignals:[self.viewModel.saveCommand.executing not], nil];

    //Required -> Site, Group, title, startDate, endDate
    RACSignal *canSendSignal = [[RACSignal combineLatest:@[RACObserve(self.viewModel.event, siteId), RACObserve(self.viewModel.event, groupId), RACObserve(self.viewModel.event, title), RACObserve(self.viewModel.event, startDate), RACObserve(self.viewModel.event, endDate), self.viewModel.saveCommand.executing]] map:^id(RACTuple *tuple) {
        RACTupleUnpack(NSString *siteId, NSNumber *groupId, NSString *title, NSDate *startDate, NSDate *endDate, NSNumber *iIsExecuting) = tuple;
        
        return @(![siteId isEqualToString:@""] && groupId != nil && ![title isEqualToString:@""] && startDate != nil && endDate != nil && !iIsExecuting.boolValue);
    }];
    [self.navigationItem.rightBarButtonItem rac_liftSelector:@selector(setEnabled:) withSignals:canSendSignal, nil];
}

#pragma mark - Actions

- (void) cancelAction: (id) sender {
    [self.view endEditing:YES];
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

- (void) saveAction: (id) sender {
    [self.view endEditing:YES];
    CHDEditEventViewModel *viewModel = self.viewModel;

    [self shprac_liftSelector:@selector(setEvent:) withSignal:[[[self.viewModel saveEvent] catch:^RACSignal *(NSError *error) {
        SHPHTTPResponse *response = error.userInfo[SHPAPIManagerReactiveExtensionErrorResponseKey];
        if (response.statusCode == 406) {
            if ([response.body isKindOfClass:[NSDictionary class]]) {
                NSDictionary *result = response.body;
                NSString *htmlString = [result valueForKey:@"error"];

                CHDEventAlertView *alertView = [[CHDEventAlertView alloc] initWithHtml:htmlString];
                alertView.show = YES;

                RACSignal *statusSignal = [RACObserve(alertView, status) filter:^BOOL(NSNumber *iStatus) {
                    return iStatus.unsignedIntegerValue != CHDEventAlertStatusNone;
                }];

                RAC(alertView, show) = [[statusSignal map:^id(id value) {
                    return @(NO);
                }] takeUntil:alertView.rac_willDeallocSignal];

                return [statusSignal flattenMap:^RACStream *(NSNumber *iStatus) {
                    if (iStatus.unsignedIntegerValue == CHDEventAlertStatusCancel) {
                        return [RACSignal empty];
                    }
                    viewModel.event.allowDoubleBooking = YES;

                    return [viewModel saveEvent];
                }];

            }
        }
        return [RACSignal empty];
    }] mapReplace:self.viewModel.event]];
}

- (void) handleKeyboardEvent: (SHPKeyboardEvent*) event {

    if (event.keyboardEventType == SHPKeyboardEventTypeShow) {
        event.originalOffset = self.tableView.contentOffset.y;
    }

    [UIView animateWithDuration:event.keyboardAnimationDuration delay:0 options:event.keyboardAnimationOptionCurve animations:^{
        self.tableView.contentInset = UIEdgeInsetsMake(0, 0, event.keyboardFrame.size.height, 0);
        self.tableView.contentOffset = CGPointMake(0, event.keyboardEventType == SHPKeyboardEventTypeShow ? self.tableView.contentOffset.y - event.requiredViewOffset : event.originalOffset);
        self.tableView.scrollIndicatorInsets = self.tableView.contentInset;
    } completion:nil];
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *row = [self.viewModel rowsForSectionAtIndex:indexPath.section][indexPath.row];
    if ([row isEqualToString:CHDEventEditRowDivider]) {
        return 36;
    }
    return 49;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *row = [self.viewModel rowsForSectionAtIndex:indexPath.section][indexPath.row];
    CHDEvent *event = self.viewModel.event;
    CHDEnvironment *environment = self.viewModel.environment;
    CHDUser *user = self.viewModel.user;

    NSMutableArray *items = [NSMutableArray new];
    NSString *title = nil;
    BOOL selectMultiple = NO;

    if ([row isEqualToString:CHDEventEditRowParish]) {
        title = NSLocalizedString(@"Select Parish", @"");
        for (CHDSite *site in user.sites) {
            [items addObject:[[CHDListSelectorConfigModel alloc] initWithTitle:site.name color:nil selected:[event.siteId isEqualToString:site.siteId] refObject:site.siteId]];
        }
    }
    else if ([row isEqualToString:CHDEventEditRowGroup]) {
        title = NSLocalizedString(@"Select Group", @"");
        NSArray *groups = [environment groupsWithSiteId:event.siteId];
        for (CHDGroup *group in groups) {
            [items addObject:[[CHDListSelectorConfigModel alloc] initWithTitle:group.name color:nil selected:[event.groupId isEqualToNumber:group.groupId] refObject:group.groupId]];
        }
    }
    else if ([row isEqualToString:CHDEventEditRowCategories]) {
        title = NSLocalizedString(@"Select Category", @"");
        selectMultiple = YES;
        NSArray *categories = [environment eventCategoriesWithSiteId:event.siteId];
        for (CHDEventCategory *category in categories) {
            [items addObject:[[CHDListSelectorConfigModel alloc] initWithTitle:category.name color:category.color selected:[event.eventCategoryIds containsObject:category.categoryId] refObject:category.categoryId]];
        }
    }
    else if ([row isEqualToString:CHDEventEditRowUsers]) {
        title = NSLocalizedString(@"Select Users", @"");
        selectMultiple = YES;
        NSArray *users = [environment usersWithSiteId:event.siteId];
        for (CHDPeerUser *user in users) {
            [items addObject:[[CHDListSelectorConfigModel alloc] initWithTitle:user.name color:nil selected:[event.userIds containsObject:user.userId] refObject:user.userId]];
        }
    }
    else if ([row isEqualToString:CHDEventEditRowResources]) {
        title = NSLocalizedString(@"Select Resources", @"");
        selectMultiple = YES;
        NSArray *resources = [environment resourcesWithSiteId:event.siteId];
        for (CHDResource *resource in resources) {
            [items addObject:[[CHDListSelectorConfigModel alloc] initWithTitle:resource.name color:resource.color selected:[event.resourceIds containsObject:resource.resourceId] refObject:resource.resourceId]];
        }
    }
    else if ([row isEqualToString:CHDEventEditRowVisibility]) {
        title = NSLocalizedString(@"Select Visibility", @"");
        NSArray *visibilityTypes = @[@(CHDEventVisibilityPublicOnWebsite), @(CHDEventVisibilityOnlyInGroup)];
        for (NSNumber *nVisibility in visibilityTypes) {
            CHDEventVisibility visibility = nVisibility.unsignedIntegerValue;
            [items addObject:[[CHDListSelectorConfigModel alloc] initWithTitle:[event localizedVisibilityStringForVisibility:visibility] color:nil selected:event.visibility == visibility refObject:nVisibility]];
        }
    }
    else if([row isEqualToString:CHDEventEditRowStartDate]){
        title = NSLocalizedString(@"Choose start date", @"");
    }else if([row isEqualToString:CHDEventEditRowEndDate]){
        title = NSLocalizedString(@"Choose end date", @"");
    }

    if (items.count) {
        CHDListSelectorViewController *vc = [[CHDListSelectorViewController alloc] initWithSelectableItems:items];
        vc.title = title;
        vc.selectMultiple = selectMultiple;

        RACSignal *selectedSignal = [[[RACObserve(vc, selectedItems) map:^id(NSArray *selectedItems) {
            return [selectedItems valueForKey:@"refObject"];
        }] skip:1] takeUntil:vc.rac_willDeallocSignal];

        RACSignal *selectedSingleSignal = [selectedSignal map:^id(NSArray *selectedItems) {
            return selectedItems.firstObject;
        }];

        if ([row isEqualToString:CHDEventEditRowParish]) {
            [self.viewModel.event shprac_liftSelector:@selector(setSiteId:) withSignal:selectedSingleSignal];

            RACSignal *nilWhenSelectedSignal = [[selectedSingleSignal distinctUntilChanged] mapReplace:nil];
            [self.viewModel.event shprac_liftSelector:@selector(setEventCategoryIds:) withSignal:nilWhenSelectedSignal];
            [self.viewModel.event shprac_liftSelector:@selector(setGroupId:) withSignal:nilWhenSelectedSignal];
            [self.viewModel.event shprac_liftSelector:@selector(setResourceIds:) withSignal:nilWhenSelectedSignal];
            [self.viewModel.event shprac_liftSelector:@selector(setUserIds:) withSignal:nilWhenSelectedSignal];
        }
        else if ([row isEqualToString:CHDEventEditRowGroup]) {
            [self.viewModel.event shprac_liftSelector:@selector(setGroupId:) withSignal:selectedSingleSignal];
        }
        else if ([row isEqualToString:CHDEventEditRowCategories]) {
            [self.viewModel.event shprac_liftSelector:@selector(setEventCategoryIds:) withSignal:selectedSignal];
        }
        else if ([row isEqualToString:CHDEventEditRowUsers]) {
            [self.viewModel.event shprac_liftSelector:@selector(setUserIds:) withSignal:selectedSignal];
        }
        else if ([row isEqualToString:CHDEventEditRowResources]) {
            [self.viewModel.event shprac_liftSelector:@selector(setResourceIds:) withSignal:selectedSignal];
        }
        else if ([row isEqualToString:CHDEventEditRowVisibility]) {
            [self.viewModel.event shprac_liftSelector:@selector(setVisibility:) withSignal:[selectedSingleSignal ignore:nil]];
        }

        CGPoint offset = self.tableView.contentOffset;
        [self.tableView rac_liftSelector:@selector(setContentOffset:) withSignals:[[[self rac_signalForSelector:@selector(viewDidLayoutSubviews)] takeUntil:vc.rac_willDeallocSignal] mapReplace:[NSValue valueWithCGPoint:offset]], nil];
        [self.navigationController pushViewController:vc animated:YES];
    }
    else if([row isEqualToString:CHDEventEditRowStartDate]){

        CHDDatePickerViewController *vc = [[CHDDatePickerViewController alloc] initWithDate:self.viewModel.event.startDate allDay:self.viewModel.event.allDayEvent canSelectAllDay:YES];
        vc.title = title;
        [self.navigationController pushViewController:vc animated:YES];

        RACSignal *selectedDateSignal = [[RACObserve(vc, date) takeUntil:vc.rac_willDeallocSignal] skip:1];
        RACSignal *selectedAllDaySignal = [[RACObserve(vc, allDay) takeUntil:vc.rac_willDeallocSignal] skip:1];

        [self.viewModel.event rac_liftSelector:@selector(setStartDate:) withSignals:selectedDateSignal, nil];
        [self.viewModel.event rac_liftSelector:@selector(setAllDayEvent:) withSignals:selectedAllDaySignal, nil];

        [self.viewModel.event rac_liftSelector:@selector(setEndDate:) withSignals:[selectedDateSignal map:^id(NSDate* startDate) {
            return [startDate dateByAddingTimeInterval:60*60];
        }], nil];
    }
    else if([row isEqualToString:CHDEventEditRowEndDate]){
        if(self.viewModel.event.startDate) {
            CHDDatePickerViewController *vc = [[CHDDatePickerViewController alloc] initWithDate:self.viewModel.event.endDate allDay:self.viewModel.event.allDayEvent canSelectAllDay:NO];
            vc.title = title;
            [self.navigationController pushViewController:vc animated:YES];

            RACSignal *selectedDateSignal = [[RACObserve(vc, date) takeUntil:vc.rac_willDeallocSignal] skip:1];
            [self.viewModel.event rac_liftSelector:@selector(setEndDate:) withSignals:selectedDateSignal, nil];
        }
    }
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.viewModel.sections.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.viewModel rowsForSectionAtIndex:section].count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *row = [self.viewModel rowsForSectionAtIndex:indexPath.section][indexPath.row];
    UITableViewCell *returnCell = nil;

    CHDEvent *event = self.viewModel.event;
    CHDEnvironment *environment = self.viewModel.environment;
    CHDUser *user = self.viewModel.user;

    if ([row isEqualToString:CHDEventEditRowDivider]) {
        CHDDividerTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"divider" forIndexPath:indexPath];
        cell.hideTopLine = indexPath.section == 0 && indexPath.row == 0;
        cell.hideBottomLine = indexPath.section == [tableView numberOfSections]-1 && indexPath.row == [tableView numberOfRowsInSection:indexPath.section]-1;
        returnCell = cell;
    }
    else if ([row isEqualToString:CHDEventEditRowTitle]) {
        CHDEventTextFieldCell *cell = [tableView dequeueReusableCellWithIdentifier:@"textfield" forIndexPath:indexPath];
        cell.textField.placeholder = NSLocalizedString(@"Title", @"");
        cell.textField.text = event.title;
        [event shprac_liftSelector:@selector(setTitle:) withSignal:[cell.textField.rac_textSignal takeUntil:cell.rac_prepareForReuseSignal]];

        returnCell = cell;
    }
    else if ([row isEqualToString:CHDEventEditRowStartDate]) {
        CHDEventValueTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"value" forIndexPath:indexPath];
        cell.titleLabel.text = NSLocalizedString(@"Start", @"");
        cell.valueLabel.text = [self.viewModel formatDate:event.startDate allDay:event.allDayEvent];
        returnCell = cell;
    }
    else if ([row isEqualToString:CHDEventEditRowEndDate]) {
        CHDEventValueTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"value" forIndexPath:indexPath];
        cell.titleLabel.text = NSLocalizedString(@"End", @"");
        cell.valueLabel.text = [self.viewModel formatDate:event.endDate allDay:event.allDayEvent];

        [cell rac_liftSelector:@selector(setDisabled:) withSignals:[[RACObserve(self.viewModel.event, startDate) map:^id(NSDate *startDate) {
            return @(startDate == nil);
        }] takeUntil:cell.rac_prepareForReuseSignal], nil];

        returnCell = cell;
    }
    else if ([row isEqualToString:CHDEventEditRowParish]) {
        CHDEventValueTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"value" forIndexPath:indexPath];
        cell.titleLabel.text = NSLocalizedString(@"Parish", @"");
        [cell.valueLabel shprac_liftSelector:@selector(setText:) withSignal: [[RACObserve(event, siteId) map:^id(NSString *siteId) {
            return [user siteWithId:siteId].name;
        }] takeUntil:cell.rac_prepareForReuseSignal]];

        returnCell = cell;
    }
    else if ([row isEqualToString:CHDEventEditRowGroup]) {
        CHDEventValueTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"value" forIndexPath:indexPath];
        cell.titleLabel.text = NSLocalizedString(@"Group", @"");
        [cell.valueLabel shprac_liftSelector:@selector(setText:) withSignal: [[RACObserve(event, groupId) map:^id(NSNumber *groupId) {
            return [environment groupWithId:groupId].name;
        }] takeUntil:cell.rac_prepareForReuseSignal]];

        [cell rac_liftSelector:@selector(setDisabled:) withSignals:[[RACObserve(event, siteId) map:^id(NSString *siteId) {
            return @(siteId == nil);
        }] takeUntil:cell.rac_prepareForReuseSignal], nil];

        returnCell = cell;
    }
    else if ([row isEqualToString:CHDEventEditRowCategories]) {
        CHDEventValueTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"value" forIndexPath:indexPath];
        cell.titleLabel.text = NSLocalizedString(@"Category", @"");
        cell.valueLabel.text = event.eventCategoryIds.count <= 1 ? [environment eventCategoryWithId:event.eventCategoryIds.firstObject siteId:event.siteId].name : [@(event.eventCategoryIds.count) stringValue];

        [cell rac_liftSelector:@selector(setDisabled:) withSignals:[[RACObserve(event, siteId) map:^id(NSString *siteId) {
            return @(siteId == nil);
        }] takeUntil:cell.rac_prepareForReuseSignal], nil];

        returnCell = cell;
    }
    else if ([row isEqualToString:CHDEventEditRowLocation]) {
        CHDEventTextFieldCell *cell = [tableView dequeueReusableCellWithIdentifier:@"textfield" forIndexPath:indexPath];
        cell.textField.placeholder = NSLocalizedString(@"Location", @"");
        cell.textField.text = event.location;
        [event shprac_liftSelector:@selector(setLocation:) withSignal:[cell.textField.rac_textSignal takeUntil:cell.rac_prepareForReuseSignal]];

        returnCell = cell;
    }
    else if ([row isEqualToString:CHDEventEditRowResources]) {
        CHDEventValueTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"value" forIndexPath:indexPath];
        cell.titleLabel.text = NSLocalizedString(@"Resources", @"");
        [cell.valueLabel shprac_liftSelector:@selector(setText:) withSignal: [RACSignal merge: @[[[RACObserve(event, siteId) map:^id(NSString *siteId) {
            if(siteId != nil) {
                return ([environment resourcesWithSiteId:event.siteId].count == 0)? NSLocalizedString(@"None available", @"") : @"";
            }
            return @"";
        }] takeUntil:cell.rac_prepareForReuseSignal],
            [[[RACObserve(event, resourceIds) filter:^BOOL(NSArray *resourceIds) {
                return resourceIds.count > 0;
            }] map:^id(NSArray *resourceIds) {
                return resourceIds.count <= 1 ? [environment resourceWithId:event.resourceIds.firstObject].name : [NSString stringWithFormat:@"%lu", resourceIds.count];
            }] takeUntil:cell.rac_prepareForReuseSignal]
        ]]];

        [cell rac_liftSelector:@selector(setDisclosureArrowHidden:) withSignals:[[RACObserve(event, siteId) map:^id(NSString *siteId) {
            if(siteId != nil) {
                BOOL hideDisclosureArrow = ([environment resourcesWithSiteId:event.siteId].count == 0)? YES : NO;
                return @(hideDisclosureArrow);
            }
            return @(YES);
        }] takeUntil:cell.rac_prepareForReuseSignal], nil];

        [cell rac_liftSelector:@selector(setDisabled:) withSignals:[[RACObserve(event, siteId) map:^id(NSString *siteId) {
            return @(siteId == nil);
        }] takeUntil:cell.rac_prepareForReuseSignal], nil];

        returnCell = cell;
    }
    else if ([row isEqualToString:CHDEventEditRowUsers]) {
        CHDEventValueTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"value" forIndexPath:indexPath];
        cell.titleLabel.text = NSLocalizedString(@"Users", @"");
        cell.valueLabel.text = event.userIds.count <= 1 ? [self.viewModel.environment userWithId:event.userIds.firstObject siteId:event.siteId].name : [@(event.userIds.count) stringValue];

        [cell rac_liftSelector:@selector(setDisabled:) withSignals:[[RACObserve(event, siteId) map:^id(NSString *siteId) {
            return @(siteId == nil);
        }] takeUntil:cell.rac_prepareForReuseSignal], nil];

        returnCell = cell;
    }
    else if ([row isEqualToString:CHDEventEditRowInternalNote]) {
        CHDEventTextViewTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"textview" forIndexPath:indexPath];
        cell.placeholder = NSLocalizedString(@"Internal note", @"");
        cell.textView.text = event.internalNote;
        cell.tableView = tableView;
        [event shprac_liftSelector:@selector(setInternalNote:) withSignal:[cell.textView.rac_textSignal takeUntil:cell.rac_prepareForReuseSignal]];

        returnCell = cell;
    }
    else if ([row isEqualToString:CHDEventEditRowDescription]) {
        CHDEventTextViewTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"textview" forIndexPath:indexPath];
        cell.placeholder = NSLocalizedString(@"Description", @"");
        cell.textView.text = event.eventDescription;
        cell.tableView = tableView;
        [event shprac_liftSelector:@selector(setEventDescription:) withSignal:[cell.textView.rac_textSignal takeUntil:cell.rac_prepareForReuseSignal]];

        returnCell = cell;
    }
    else if ([row isEqualToString:CHDEventEditRowContributor]) {
        CHDEventTextFieldCell *cell = [tableView dequeueReusableCellWithIdentifier:@"textfield" forIndexPath:indexPath];
        cell.textField.placeholder = NSLocalizedString(@"Contributor", @"");
        cell.textField.text = event.contributor;
        [event shprac_liftSelector:@selector(setContributor:) withSignal:[cell.textField.rac_textSignal takeUntil:cell.rac_prepareForReuseSignal]];

        returnCell = cell;
    }
    else if ([row isEqualToString:CHDEventEditRowPrice]) {
        CHDEventTextFieldCell *cell = [tableView dequeueReusableCellWithIdentifier:@"textfield" forIndexPath:indexPath];
        cell.textField.placeholder = NSLocalizedString(@"Price", @"");
        cell.textField.text = event.price;
        [event shprac_liftSelector:@selector(setPrice:) withSignal:[cell.textField.rac_textSignal takeUntil:cell.rac_prepareForReuseSignal]];

        returnCell = cell;
    }
    else if ([row isEqualToString:CHDEventEditRowDoubleBooking]) {
        CHDEventSwitchTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"switch" forIndexPath:indexPath];
        cell.titleLabel.text = NSLocalizedString(@"Allow Double Booking", @"");
        [event shprac_liftSelector:@selector(setAllowDoubleBooking:) withSignal:[[[cell.valueSwitch rac_signalForControlEvents:UIControlEventValueChanged] map:^id(UISwitch *valueSwitch) {
            return @(valueSwitch.on);
        }] takeUntil:cell.rac_prepareForReuseSignal]];

        returnCell = cell;
    }
    else if ([row isEqualToString:CHDEventEditRowVisibility]) {
        CHDEventValueTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"value" forIndexPath:indexPath];
        cell.titleLabel.text = NSLocalizedString(@"Visibility", @"");
        cell.valueLabel.text = [event localizedVisibilityString];
        returnCell = cell;
    }

    if ([returnCell respondsToSelector:@selector(setDividerLineHidden:)]) {
        [(CHDEventInfoTableViewCell*)returnCell setDividerLineHidden: indexPath.row == [tableView numberOfRowsInSection:indexPath.section]-1];
    }

    return returnCell;
}

#pragma mark - Lazy Initialization

- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [UITableView new];
        _tableView.dataSource = self;
        _tableView.delegate = self;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.rowHeight = UITableViewAutomaticDimension;
        _tableView.estimatedRowHeight = 49;

        [_tableView registerClass:[CHDEventTextFieldCell class] forCellReuseIdentifier:@"textfield"];
        [_tableView registerClass:[CHDEventValueTableViewCell class] forCellReuseIdentifier:@"value"];
        [_tableView registerClass:[CHDEventTextViewTableViewCell class] forCellReuseIdentifier:@"textview"];
        [_tableView registerClass:[CHDEventSwitchTableViewCell class] forCellReuseIdentifier:@"switch"];
        [_tableView registerClass:[CHDDividerTableViewCell class] forCellReuseIdentifier:@"divider"];
    }
    return _tableView;
}

- (NSDateFormatter *)dateFormatter {
    if (!_dateFormatter) {
        _dateFormatter = [NSDateFormatter new];
        _dateFormatter.dateStyle = NSDateFormatterLongStyle;
        _dateFormatter.timeStyle = NSDateFormatterShortStyle;
    }
    return _dateFormatter;
}

@end
