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
#import "CHDAnalyticsManager.h"
#import "CHDStatusView.h"
#import "CHDSitePermission.h"

@interface CHDEditEventViewController () <UITableViewDataSource, UITableViewDelegate, UIAlertViewDelegate>

@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) CHDEvent *event;
@property (nonatomic, strong) CHDEditEventViewModel *viewModel;
@property (nonatomic, strong) NSDateFormatter *dateFormatter;
@property (nonatomic, strong) CHDStatusView *statusView;

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
    [[CHDAnalyticsManager sharedInstance] trackVisitToScreen: self.viewModel.newEvent? @"new event" :@"edit event"];
    [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:YES];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self didChangeSendingStatus:CHDStatusViewHidden];

}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void) setupSubviews {
    [self.view addSubview:self.tableView];

    self.statusView = [[CHDStatusView alloc] init];
    self.statusView.successText = NSLocalizedString(@"The event was saved", @"");
    self.statusView.processingText = NSLocalizedString(@"Saving event..", @"");
    self.statusView.autoHideOnSuccessAfterTime = 0;
    self.statusView.autoHideOnErrorAfterTime = 0;

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
    [self shprac_liftSelector:@selector(titleAsFirstResponder) withSignal:[[self rac_signalForSelector:@selector(viewDidAppear:)] take:1]];

    [self.tableView shprac_liftSelector:@selector(reloadData) withSignal:[[RACSignal merge:@[RACObserve(self.viewModel, environment), RACObserve(self.viewModel, user), RACObserve(self.viewModel.event, siteId), RACObserve(self.viewModel.event, groupIds), RACObserve(self.viewModel.event, eventCategoryIds), RACObserve(self.viewModel.event, userIds), RACObserve(self.viewModel.event, resourceIds), RACObserve(self.viewModel.event, startDate), RACObserve(self.viewModel.event, endDate), RACObserve(self.viewModel, sectionRows)]] ignore:nil]];

    [self rac_liftSelector:@selector(handleKeyboardEvent:) withSignals:[self shp_keyboardAwarenessSignal], nil];

    [self.navigationItem.leftBarButtonItem rac_liftSelector:@selector(setEnabled:) withSignals:[self.viewModel.saveCommand.executing not], nil];

    //Required -> Site, title, startDate, endDate
    RACSignal *canSendSignal = [[RACSignal combineLatest:@[RACObserve(self.viewModel.event, siteId), RACObserve(self.viewModel.event, eventCategoryIds), RACObserve(self.viewModel.event, groupIds), RACObserve(self.viewModel.event, visibility) , RACObserve(self.viewModel.event, title), RACObserve(self.viewModel.event, startDate), RACObserve(self.viewModel.event, endDate), self.viewModel.saveCommand.executing]] map:^id(RACTuple *tuple) {
        RACTupleUnpack(NSString *siteId, NSArray *categoryIds, NSArray *groupIds, NSNumber *visibility, NSString *title, NSDate *startDate, NSDate *endDate, NSNumber *iIsExecuting) = tuple;
        
        BOOL checkforGroups = YES;
        if (visibility.integerValue == 3 && groupIds.count == 0)
            checkforGroups = NO;
        
            return @(![siteId isEqualToString:@""] && categoryIds.count > 0 && ![title isEqualToString:@""] && startDate != nil && endDate != nil && !iIsExecuting.boolValue && checkforGroups);
    }];
    [self.navigationItem.rightBarButtonItem rac_liftSelector:@selector(setEnabled:) withSignals:canSendSignal, nil];
}

#pragma mark - Actions

- (void) cancelAction: (id) sender {
    [Heap track:@"Cancel clicked from edit event view"];
    [self.view endEditing:YES];
    [[CHDAnalyticsManager sharedInstance] trackEventWithCategory:self.viewModel.newEvent ? ANALYTICS_CATEGORY_NEW_EVENT : ANALYTICS_CATEGORY_EDIT_EVENT action:ANALYTICS_ACTION_BUTTON label:ANALYTICS_LABEL_CANCEL];
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

- (void) saveAction: (id) sender {
    [self.view endEditing:YES];
    
    [[CHDAnalyticsManager sharedInstance] trackEventWithCategory:self.viewModel.newEvent ? ANALYTICS_CATEGORY_NEW_EVENT : ANALYTICS_CATEGORY_EDIT_EVENT action:ANALYTICS_ACTION_BUTTON label:ANALYTICS_LABEL_CREATE];
    if (self.viewModel.event.userIds.count > 0) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Send Notifications?", @"") message:NSLocalizedString(@"Would you like to send notifications to the booked users?", @"") delegate:nil cancelButtonTitle:NSLocalizedString(@"No, just save", @"") otherButtonTitles:NSLocalizedString(@"Yes, save and send", @""), nil];
        alertView.tag = 111;
        alertView.delegate = self;
        [alertView show];
    } else{
        self.viewModel.event.sendNotifications = false;
        [self saveEvent];
    }
}

-(void) saveEvent{
    CHDEditEventViewModel *viewModel = self.viewModel;
    [self didChangeSendingStatus:CHDStatusViewProcessing];
    [Heap track:@"Save event submit"];
    @weakify(self)
    [[[self.viewModel saveEvent] catch:^RACSignal *(NSError *error) {
        //Handle double booking responses from the server
        @strongify(self)
        SHPHTTPResponse *response = error.userInfo[SHPAPIManagerReactiveExtensionErrorResponseKey];
        if (response.statusCode == 409) {
            [Heap track:@"Double booking conflict"];
            if ([response.body isKindOfClass:[NSDictionary class]]) {
                NSDictionary *result = response.body;
                NSString *htmlString = [result valueForKey:@"conflictHtml"];
                NSLog(@"html string %@", htmlString);
                BOOL permissionToDoubleBook = [viewModel.user siteWithId:viewModel.event.siteId].permissions.canDoubleBook;
                
                if(htmlString && permissionToDoubleBook) {
                    CHDEventAlertView *alertView = [[CHDEventAlertView alloc] initWithHtml:htmlString];
                    alertView.tag = 1020;
                    alertView.show = YES;
                    RACSignal *statusSignal = [RACObserve(alertView, status) filter:^BOOL(NSNumber *iStatus) {
                        return iStatus.unsignedIntegerValue != CHDEventAlertStatusNone;
                    }];
                    
                    RAC(alertView, show) = [[statusSignal map:^id(id value) {
                        return @(NO);
                    }] takeUntil:alertView.rac_willDeallocSignal];
                    
                    return [statusSignal flattenMap:^RACStream *(NSNumber *iStatus) {
                        if (iStatus.unsignedIntegerValue == CHDEventAlertStatusCancel) {
                            [self didChangeSendingStatus:CHDStatusViewHidden];
                            return [RACSignal empty];
                        }
                        viewModel.event.allowDoubleBooking = YES;
                        return [viewModel saveEvent];
                    }];
                }
                else if(htmlString && !permissionToDoubleBook){
                    [self didChangeSendingStatus:CHDStatusViewHidden];
                    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", @"") message:NSLocalizedString(@"Doublebooking not allowed", @"") delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                    [alertView show];
                    return [RACSignal empty];
                }
                else {
                    [self didChangeSendingStatus:CHDStatusViewHidden];
                    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", @"") message:htmlString delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                    [alertView show];
                    return [RACSignal empty];
                }
            }
        }
        else{
            [self didChangeSendingStatus:CHDStatusViewHidden];
            NSDictionary *result = response.body;
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", @"") message:[result objectForKey:@"message"] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alertView show];
        }
//        [[CHDAnalyticsManager sharedInstance] trackEventWithCategory:self.viewModel.newEvent ? ANALYTICS_CATEGORY_NEW_EVENT : ANALYTICS_CATEGORY_EDIT_EVENT action:ANALYTICS_ACTION_SENDING label:ANALYTICS_LABEL_ERROR];
//        [self didChangeSendingStatus:CHDStatusViewHidden];
        return [RACSignal empty];
    }] subscribeNext:^(id x) {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:kSavedEventBool];
        [self didChangeSendingStatus:CHDStatusViewSuccess];
    } error:^(NSError *error) {
        //Handle error after the initial error handling is done (Them it's something we don't know how to handle)
        [self didChangeSendingStatus:CHDStatusViewHidden];
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", @"") message:@"Please contact system administrator" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alertView show];
    } completed:^{
        NSLog(@"Event done");
    }];
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

-(void) didChangeSendingStatus: (CHDStatusViewStatus) status {
    self.statusView.currentStatus = status;

    if(status == CHDStatusViewProcessing){
        self.statusView.show = YES;
        return;
    }
    if(status == CHDStatusViewSuccess){
        self.statusView.show = YES;
        double delayInSeconds = 2.f;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            self.statusView.show = NO;
            //View will be dissmissed when the event is set
            [self setEvent:self.viewModel.event];
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

-(void) titleAsFirstResponder {
    NSUInteger section = [self.viewModel.sections indexOfObject:CHDEventEditSectionTitle];
    NSUInteger row = [self.viewModel.sectionRows[CHDEventEditSectionTitle] indexOfObject:CHDEventEditRowTitle];

    if(section != NSNotFound && row != NSNotFound) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:section];
        CHDEventTextFieldCell *cell = (CHDEventTextFieldCell*)[self tableView:self.tableView cellForRowAtIndexPath:indexPath];
        [cell.textField becomeFirstResponder];
    }
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
    CHDSite *site = [user siteWithId:self.viewModel.event.siteId];
    NSMutableArray *items = [NSMutableArray new];
    NSString *title = nil;
    BOOL selectMultiple = NO;

    if ([row isEqualToString:CHDEventEditRowParish]) {
        title = NSLocalizedString(@"Select Parish", @"");
        for (CHDSite *site in user.sites) {
            [items addObject:[[CHDListSelectorConfigModel alloc] initWithTitle:site.name color:nil selected:(event.siteId.integerValue == site.siteId.integerValue) refObject:site.siteId]];
        }
    }
    else if ([row isEqualToString:CHDEventEditRowGroup]) {
        title = NSLocalizedString(@"Select Group", @"");
        selectMultiple = YES;
        NSArray *groups;
        if (site.permissions.canSetVisibilityToInternalGroup && !site.permissions.canSetVisibilityToInternalAll) {
           groups = [environment groupsWithSiteId:event.siteId groupIds:[user siteWithId:event.siteId].groupIds];
        }
        else{
            groups = [environment groupsWithSiteId:event.siteId];
        }
        for (CHDGroup *group in groups) {
            BOOL selected = false;
            for (NSNumber *groupId in event.groupIds) {
                if (groupId.intValue == group.groupId.intValue) {
                    selected = true;
                }
            }
            [items addObject:[[CHDListSelectorConfigModel alloc] initWithTitle:group.name color:nil selected:selected refObject:group.groupId]];
        }
    }
    else if ([row isEqualToString:CHDEventEditRowCategories]) {
        title = NSLocalizedString(@"Select Categories", @"");
        selectMultiple = YES;
        NSArray *categories = [environment eventCategoriesWithSiteId:event.siteId];
        for (CHDEventCategory *category in categories) {
            BOOL selected = false;
            for (NSNumber *categoryId in event.eventCategoryIds) {
                if (categoryId.intValue == category.categoryId.intValue) {
                    selected = true;
                }
            }
            [items addObject:[[CHDListSelectorConfigModel alloc] initWithTitle:category.name color:category.color selected:selected refObject:category.categoryId]];
        }
    }
    else if ([row isEqualToString:CHDEventEditRowUsers]) {
        title = NSLocalizedString(@"Select Users", @"");
        selectMultiple = YES;
        NSArray *users = [environment usersWithSiteId:event.siteId];
        for (CHDPeerUser *user in users) {
            BOOL selected = false;
            for (NSNumber *userId in event.userIds) {
                if (userId.intValue == user.userId.intValue) {
                    selected = true;
                }
            }
            NSString *title = user.name;
            if ([title stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]].length == 0) {
                title = user.email;
            }
            [items addObject:[[CHDListSelectorConfigModel alloc] initWithTitle:title imageURL:user.pictureURL color:nil  selected:selected refObject:user.userId]];
        }
    }
    else if ([row isEqualToString:CHDEventEditRowResources]) {
        title = NSLocalizedString(@"Select Resources", @"");
        selectMultiple = YES;
        NSArray *resources = [environment resourcesWithSiteId:event.siteId];
        for (CHDResource *resource in resources) {
            BOOL selected = false;
            for (NSNumber *resourceId in event.resourceIds) {
                if (resourceId.intValue == resource.resourceId.intValue) {
                    selected = true;
                }
            }
            [items addObject:[[CHDListSelectorConfigModel alloc] initWithTitle:resource.name color:resource.color selected:selected refObject:resource.resourceId]];
        }
    }
    else if ([row isEqualToString:CHDEventEditRowVisibility]) {
        title = NSLocalizedString(@"Select Visibility", @"");
        NSMutableArray *visibilityTypes = [[NSMutableArray alloc] init];
        if (self.viewModel.newEvent) {
            if (site.permissions.canSetVisibilityToInternalAll) {
                [visibilityTypes addObject:@(CHDEventVisibilityAllUsers)];
            }
            if (site.permissions.canSetVisibilityToInternalGroup) {
                [visibilityTypes addObject:@(CHDEventVisibilityOnlyInGroup)];
            }
            if (site.permissions.canSetVisibilityToPublic) {
                [visibilityTypes addObject:@(CHDEventVisibilityPublicOnWebsite)];
            }
            [visibilityTypes addObject:@(CHDEventVisibilityDraft)];
        }
        else{
            NSDictionary *visibilityPermissions = [event.fields objectForKey:@"visibility"];
            NSArray *allowedValues = [visibilityPermissions objectForKey:@"allowedValues"] ;
            if ([allowedValues containsObject:@"internal-all"]) {
                [visibilityTypes addObject:@(CHDEventVisibilityAllUsers)];
            }
            if ([allowedValues containsObject:@"internal-group"]) {
                [visibilityTypes addObject:@(CHDEventVisibilityOnlyInGroup)];
            }
            if ([allowedValues containsObject:@"public"]) {
                [visibilityTypes addObject:@(CHDEventVisibilityPublicOnWebsite)];
            }
            if ([allowedValues containsObject:@"private"]) {
                [visibilityTypes addObject:@(CHDEventVisibilityDraft)];
            }
        }
        
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
            [self.viewModel.event shprac_liftSelector:@selector(setGroupIds:) withSignal:nilWhenSelectedSignal];
            [self.viewModel.event shprac_liftSelector:@selector(setResourceIds:) withSignal:nilWhenSelectedSignal];
            [self.viewModel.event shprac_liftSelector:@selector(setUserIds:) withSignal:nilWhenSelectedSignal];
            [self.viewModel.event shprac_liftSelector:@selector(setVisibility:) withSignal:nilWhenSelectedSignal];
        }
        else if ([row isEqualToString:CHDEventEditRowGroup]) {
            [self.viewModel.event shprac_liftSelector:@selector(setGroupIds:) withSignal:selectedSignal];
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

        CHDDatePickerViewController *vc = [[CHDDatePickerViewController alloc] initWithDate:self.viewModel.event.startDate allDay:self.viewModel.event.allDayEvent canSelectAllDay:NO];
        vc.title = title;
        [self.navigationController pushViewController:vc animated:YES];

        RACSignal *selectedDateSignal = [[RACObserve(vc, date) takeUntil:vc.rac_willDeallocSignal] skip:1];
        RACSignal *selectedAllDaySignal = [[RACObserve(vc, allDay) takeUntil:vc.rac_willDeallocSignal] skip:1];

        [self.viewModel.event rac_liftSelector:@selector(setStartDate:) withSignals:selectedDateSignal, nil];
        [self.viewModel.event rac_liftSelector:@selector(setAllDayEvent:) withSignals:selectedAllDaySignal, nil];

        CHDEvent *event = self.viewModel.event;
        [self.viewModel.event rac_liftSelector:@selector(setEndDate:) withSignals:[[selectedDateSignal takeWhileBlock:^BOOL(NSDate *startDate) {
            return event.endDate == nil || [[startDate earlierDate:event.endDate] isEqualToDate: event.endDate];
        }] map:^id(NSDate* startDate) {
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

            [self.viewModel.event shprac_liftSelector:@selector(setStartDate:) withSignal:[[selectedDateSignal filter:^BOOL(NSDate *endDate) {
                return endDate.timeIntervalSince1970 < event.startDate.timeIntervalSince1970;
            }] map:^id(NSDate *endDate) {
                return [endDate dateByAddingTimeInterval:-60*60];
            }]];
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
    CHDSite *site = [user siteWithId:self.viewModel.event.siteId];
    BOOL newEvent = self.viewModel.newEvent;

    CHDEditEventViewModel *viewModel = self.viewModel;

    if ([row isEqualToString:CHDEventEditRowDivider]) {
        CHDDividerTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"divider" forIndexPath:indexPath];
        cell.hideTopLine = indexPath.section == 0 && indexPath.row == 0;
        cell.hideBottomLine = indexPath.section == [tableView numberOfSections]-1 && indexPath.row == [tableView numberOfRowsInSection:indexPath.section]-1;
        returnCell = cell;
    }
    else if ([row isEqualToString:CHDEventEditRowTitle]) {
        
        CHDEventTextFieldCell *cell = [tableView cellForRowAtIndexPath:indexPath]?: [tableView dequeueReusableCellWithIdentifier:@"textfield" forIndexPath:indexPath];
        cell.textField.placeholder = NSLocalizedString(@"Title", @"");
        cell.textField.text = event.title;
        cell.textFieldMaxLength = 255;
        [event shprac_liftSelector:@selector(setTitle:) withSignal:[cell.textField.rac_textSignal takeUntil:cell.rac_prepareForReuseSignal]];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.userInteractionEnabled = YES;
        cell.contentView.alpha=1;
        if (!newEvent) {
            NSDictionary *titlePermissions = [event.fields objectForKey:@"title"];
            BOOL canEditTitle = [[titlePermissions objectForKey:@"canEdit"] boolValue];
            if (!canEditTitle) {
                cell.userInteractionEnabled = NO;
                cell.contentView.alpha=0.2;
            }
        }
        returnCell = cell;
    }
    else if([row isEqualToString:CHDEventEditRowAllDay]){
        CHDEventSwitchTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"switch" forIndexPath:indexPath];
        cell.titleLabel.text = NSLocalizedString(@"All day", @"");
        cell.valueSwitch.on = event.allDayEvent;
        [event shprac_liftSelector:@selector(setAllDayEvent:) withSignal:[[[cell.valueSwitch rac_signalForControlEvents:UIControlEventValueChanged] map:^id(UISwitch *valueSwitch) {
            return @(valueSwitch.on);
        }] takeUntil:cell.rac_prepareForReuseSignal]];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.userInteractionEnabled = YES;
        cell.contentView.alpha=1;
        if (!newEvent) {
            NSDictionary *allDayPermissions = [event.fields objectForKey:@"allDay"];
            BOOL canEditAllday = [[allDayPermissions objectForKey:@"canEdit"] boolValue];
            if (!canEditAllday) {
                cell.userInteractionEnabled = NO;
                cell.contentView.alpha=0.2;
            }
        }
        return cell;
    }
    else if ([row isEqualToString:CHDEventEditRowStartDate]) {
        CHDEventValueTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"value" forIndexPath:indexPath];
        cell.titleLabel.text = NSLocalizedString(@"Start", @"");
        [cell.valueLabel rac_liftSelector:@selector(setText:) withSignals:[[RACObserve(event, allDayEvent) map:^id(NSNumber *allDay) {
            return [viewModel formatDate:event.startDate allDay:event.allDayEvent];
        }] takeUntil:cell.rac_prepareForReuseSignal], nil];
        cell.userInteractionEnabled = YES;
        cell.contentView.alpha=1;
        if (!newEvent) {
            NSDictionary *startDatePermissions = [event.fields objectForKey:@"startDate"];
            BOOL canEditstartDate = [[startDatePermissions objectForKey:@"canEdit"] boolValue];
            if (!canEditstartDate) {
                cell.userInteractionEnabled = NO;
                cell.contentView.alpha=0.2;
            }
        }
        returnCell = cell;
    }
    else if ([row isEqualToString:CHDEventEditRowEndDate]) {
        CHDEventValueTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"value" forIndexPath:indexPath];
        cell.titleLabel.text = NSLocalizedString(@"End", @"");
        [cell.valueLabel rac_liftSelector:@selector(setText:) withSignals:[[RACObserve(event, allDayEvent) map:^id(NSNumber *allDay) {
            return [viewModel formatDate:event.endDate allDay:event.allDayEvent];
        }] takeUntil:cell.rac_prepareForReuseSignal], nil];
        cell.userInteractionEnabled = YES;
        cell.contentView.alpha=1;
        if (!newEvent) {
            NSDictionary *endDatePermissions = [event.fields objectForKey:@"endDate"];
            BOOL canEditEndDate = [[endDatePermissions objectForKey:@"canEdit"] boolValue];
            if (!canEditEndDate) {
                cell.contentView.alpha=0.2;
                cell.userInteractionEnabled = NO;
            }
        }
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
        if (event.groupIds.count == 0) {
            cell.valueLabel.text = @"";
        }
        else{
            cell.valueLabel.text = event.groupIds.count <= 1 ? [environment groupWithId:event.groupIds.firstObject siteId:event.siteId].name : [@(event.groupIds.count) stringValue];
        }
        cell.userInteractionEnabled = YES;
        cell.contentView.alpha=1;
        if (!newEvent) {
            NSDictionary *groupPermissions = [event.fields objectForKey:@"groupIds"];
            BOOL canEditGroups = [[groupPermissions objectForKey:@"canEdit"] boolValue];
            if (!canEditGroups) {
                cell.contentView.alpha=0.2;
                cell.userInteractionEnabled = NO;
            }
        }
        returnCell = cell;
    }
    else if ([row isEqualToString:CHDEventEditRowCategories]) {
        CHDEventValueTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"value" forIndexPath:indexPath];
        cell.titleLabel.text = NSLocalizedString(@"Category", @"");
        cell.valueLabel.text = event.eventCategoryIds.count <= 1 ? [environment eventCategoryWithId:event.eventCategoryIds.firstObject siteId:event.siteId].name : [@(event.eventCategoryIds.count) stringValue];
        cell.userInteractionEnabled = YES;
        cell.contentView.alpha=1;
        if (!newEvent) {
            NSDictionary *categoriesPermissions = [event.fields objectForKey:@"taxonomies"];
            BOOL canEditCategories = [[categoriesPermissions objectForKey:@"canEdit"] boolValue];
            if (!canEditCategories) {
                cell.contentView.alpha=0.2;
                cell.userInteractionEnabled = NO;
            }
        }
        returnCell = cell;
    }
    else if ([row isEqualToString:CHDEventEditRowLocation]) {
        CHDEventTextFieldCell *cell = [tableView dequeueReusableCellWithIdentifier:@"textfield" forIndexPath:indexPath];
        cell.textField.placeholder = NSLocalizedString(@"Location", @"");
        cell.textField.text = event.location;
        cell.textFieldMaxLength = 255;
        [event shprac_liftSelector:@selector(setLocation:) withSignal:[cell.textField.rac_textSignal takeUntil:cell.rac_prepareForReuseSignal]];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.userInteractionEnabled = YES;
        cell.contentView.alpha=1;
        if (!newEvent) {
            NSDictionary *locationPermissions = [event.fields objectForKey:@"location"];
            BOOL canEditLocation = [[locationPermissions objectForKey:@"canEdit"] boolValue];
            if (!canEditLocation) {
                cell.contentView.alpha=0.2;
                cell.userInteractionEnabled = NO;
            }
        }
        returnCell = cell;
    }
    else if ([row isEqualToString:CHDEventEditRowResources]) {
        CHDEventValueTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"value" forIndexPath:indexPath];
        cell.titleLabel.text = NSLocalizedString(@"Resources", @"");

        RACSignal *resourcesCountSignal = [[RACObserve(event, siteId) map:^id(NSString *siteId) {
                if(siteId != nil) {
                    return @([environment resourcesWithSiteId:event.siteId].count);
                }
                return @(0);
            }] takeUntil:cell.rac_prepareForReuseSignal];
        
        [cell.valueLabel shprac_liftSelector:@selector(setText:) withSignal: [RACSignal merge: @[[[resourcesCountSignal map:^id(NSNumber *resourcesCount) {
            if(resourcesCount != nil) {
                return (resourcesCount.integerValue == 0)? NSLocalizedString(@"None available", @"") : @"";
            }
            return @"";
        }] takeUntil:cell.rac_prepareForReuseSignal],
            [[[RACObserve(event, resourceIds) filter:^BOOL(NSArray *resourceIds) {
                return resourceIds.count > 0;
            }] map:^id(NSArray *resourceIds) {
                return resourceIds.count <= 1 ? [environment resourceWithId:event.resourceIds.firstObject siteId:event.siteId].name : [NSString stringWithFormat:@"%lu", (long)resourceIds.count];
            }] takeUntil:cell.rac_prepareForReuseSignal]
        ]]];

        [cell shprac_liftSelector:@selector(setSelectionStyle:) withSignal:[[resourcesCountSignal map:^id(NSNumber *resourcesCount) {
            if(resourcesCount != nil) {
                return (resourcesCount.integerValue == 0)? @(UITableViewCellSelectionStyleNone) : @(UITableViewCellSelectionStyleDefault);
            }
            return @(UITableViewCellSelectionStyleNone);
        }] takeUntil:cell.rac_prepareForReuseSignal]];

        [cell rac_liftSelector:@selector(setDisclosureArrowHidden:) withSignals:[[RACObserve(event, siteId) map:^id(NSString *siteId) {
            if(siteId != nil) {
                BOOL hideDisclosureArrow = ([environment resourcesWithSiteId:event.siteId].count == 0)? YES : NO;
                return @(hideDisclosureArrow);
            }
            return @(YES);
        }] takeUntil:cell.rac_prepareForReuseSignal], nil];
        cell.userInteractionEnabled = YES;
        cell.contentView.alpha=1;
        if (!newEvent) {
            NSDictionary *resourcesPermissions = [event.fields objectForKey:@"resources"];
            BOOL canEditResources = [[resourcesPermissions objectForKey:@"canEdit"] boolValue];
            if (!canEditResources) {
                cell.contentView.alpha=0.2;
                cell.userInteractionEnabled = NO;
            }
        }
        returnCell = cell;
    }
    else if ([row isEqualToString:CHDEventEditRowUsers]) {
        CHDEventValueTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"value" forIndexPath:indexPath];
        cell.titleLabel.text = NSLocalizedString(@"Users", @"");
        cell.valueLabel.text = event.userIds.count <= 1 ? [self.viewModel.environment userWithId:event.userIds.firstObject siteId:event.siteId].name : [@(event.userIds.count) stringValue];
        cell.userInteractionEnabled = YES;
        cell.contentView.alpha=1;
        if (!newEvent) {
            NSDictionary *usersPermissions = [event.fields objectForKey:@"users"];
            BOOL canEditUsers = [[usersPermissions objectForKey:@"canEdit"] boolValue];
            if (!canEditUsers) {
                cell.contentView.alpha=0.2;
                cell.userInteractionEnabled = NO;
            }
        }
        returnCell = cell;
    }
    else if ([row isEqualToString:CHDEventEditRowInternalNote]) {
        CHDEventTextViewTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"textview" forIndexPath:indexPath];
        cell.placeholder = NSLocalizedString(@"Internal note", @"");
        cell.textView.text = event.internalNote;
        cell.tableView = tableView;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        [event shprac_liftSelector:@selector(setInternalNote:) withSignal:[cell.textView.rac_textSignal takeUntil:cell.rac_prepareForReuseSignal]];
        cell.userInteractionEnabled = YES;
        cell.contentView.alpha=1;
        if (!newEvent) {
            NSDictionary *internalNotePermissions = [event.fields objectForKey:@"internalNote"];
            BOOL canEditInternalNote = [[internalNotePermissions objectForKey:@"canEdit"] boolValue];
            if (!canEditInternalNote) {
                cell.contentView.alpha=0.2;
                cell.userInteractionEnabled = NO;
            }
        }
        returnCell = cell;
    }
    else if ([row isEqualToString:CHDEventEditRowSecureInformation]) {
        CHDEventTextViewTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"textview" forIndexPath:indexPath];
        cell.placeholder = NSLocalizedString(@"Secure Information", @"");
        cell.textView.text = event.secureInformation;
        cell.tableView = tableView;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        [event shprac_liftSelector:@selector(setSecureInformation:) withSignal:[cell.textView.rac_textSignal takeUntil:cell.rac_prepareForReuseSignal]];
        cell.userInteractionEnabled = YES;
        cell.contentView.alpha=1;
        if (!newEvent) {
            NSDictionary *SecureInformationPermissions = [event.fields objectForKey:@"secureInformation"];
            BOOL canEditSecureInformation = [[SecureInformationPermissions objectForKey:@"canEdit"] boolValue];
            if (!canEditSecureInformation) {
                cell.contentView.alpha=0.2;
                cell.userInteractionEnabled = NO;
            }
        }
        returnCell = cell;
    }
    else if ([row isEqualToString:CHDEventEditRowDescription]) {
        CHDEventTextViewTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"textview" forIndexPath:indexPath];
        cell.placeholder = NSLocalizedString(@"Description", @"");
        NSAttributedString *attributedString = [[NSAttributedString alloc] initWithData:[event.eventDescription dataUsingEncoding:NSUnicodeStringEncoding] options:@{ NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType } documentAttributes:nil error:nil];
        cell.textView.text = attributedString.string;
        cell.tableView = tableView;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        [event shprac_liftSelector:@selector(setEventDescription:) withSignal:[cell.textView.rac_textSignal takeUntil:cell.rac_prepareForReuseSignal]];
        cell.userInteractionEnabled = YES;
        cell.contentView.alpha=1;
        if (!newEvent) {
            NSDictionary *descriptionPermissions = [event.fields objectForKey:@"description"];
            BOOL canEditDescription = [[descriptionPermissions objectForKey:@"canEdit"] boolValue];
            if (!canEditDescription) {
                cell.contentView.alpha=0.2;
                cell.userInteractionEnabled = NO;
            }
        }
        returnCell = cell;
    }
    else if ([row isEqualToString:CHDEventEditRowContributor]) {
        CHDEventTextFieldCell *cell = [tableView dequeueReusableCellWithIdentifier:@"textfield" forIndexPath:indexPath];
        cell.textField.placeholder = NSLocalizedString(@"Contributor", @"");
        cell.textField.text = event.contributor;
        cell.textFieldMaxLength = 255;
        [event shprac_liftSelector:@selector(setContributor:) withSignal:[cell.textField.rac_textSignal takeUntil:cell.rac_prepareForReuseSignal]];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.userInteractionEnabled = YES;
        cell.contentView.alpha=1;
        if (!newEvent) {
            NSDictionary *contributorPermissions = [event.fields objectForKey:@"contributor"];
            BOOL canEditContributor = [[contributorPermissions objectForKey:@"canEdit"] boolValue];
            if (!canEditContributor) {
                cell.contentView.alpha=0.2;
                cell.userInteractionEnabled = NO;
            }
        }
        returnCell = cell;
    }
    else if ([row isEqualToString:CHDEventEditRowPrice]) {
        CHDEventTextFieldCell *cell = [tableView dequeueReusableCellWithIdentifier:@"textfield" forIndexPath:indexPath];
        cell.textField.placeholder = NSLocalizedString(@"Price", @"");
        cell.textField.text = event.price;
        cell.textFieldMaxLength = 255;
        [cell.textField setKeyboardType:UIKeyboardTypeNumbersAndPunctuation];
        [event shprac_liftSelector:@selector(setPrice:) withSignal:[cell.textField.rac_textSignal takeUntil:cell.rac_prepareForReuseSignal]];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.userInteractionEnabled = YES;
        cell.contentView.alpha=1;
        if (!newEvent) {
            NSDictionary *pricePermissions = [event.fields objectForKey:@"price"];
            BOOL canEditPrice = [[pricePermissions objectForKey:@"canEdit"] boolValue];
            if (!canEditPrice) {
                cell.contentView.alpha=0.2;
                cell.userInteractionEnabled = NO;
            }
        }
        returnCell = cell;
    }
    else if ([row isEqualToString:CHDEventEditRowDoubleBooking]) {
        CHDEventSwitchTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"switch" forIndexPath:indexPath];
        cell.titleLabel.text = NSLocalizedString(@"Allow Double Booking", @"");
        cell.valueSwitch.on = event.allowDoubleBooking;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        [event shprac_liftSelector:@selector(setAllowDoubleBooking:) withSignal:[[[cell.valueSwitch rac_signalForControlEvents:UIControlEventValueChanged] map:^id(UISwitch *valueSwitch) {
            return @(valueSwitch.on);
        }] takeUntil:cell.rac_prepareForReuseSignal]];
        cell.userInteractionEnabled = YES;
        cell.contentView.alpha=1;
        if (!newEvent) {
            NSDictionary *doubleBookingPermissions = [event.fields objectForKey:@"allowDoubleBooking"];
            BOOL canEditDoubleBooking = [[doubleBookingPermissions objectForKey:@"canEdit"] boolValue];
            if (!canEditDoubleBooking) {
                cell.contentView.alpha=0.2;
                cell.userInteractionEnabled = NO;
            }
        }
        returnCell = cell;
    }
    else if ([row isEqualToString:CHDEventEditRowVisibility]) {
        CHDEventValueTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"value" forIndexPath:indexPath];
        cell.titleLabel.text = NSLocalizedString(@"Visibility", @"");
        cell.valueLabel.text = [event localizedVisibilityString];
        if (newEvent && (event.visibility == CHDEventVisibilityOnlyInGroup) && !site.permissions.canSetVisibilityToInternalGroup) {
            event.visibility = CHDEventVisibilityOnlyInGroup;
            self.viewModel.event.visibility = CHDEventVisibilityOnlyInGroup;
        }
        [cell.valueLabel shprac_liftSelector:@selector(setText:) withSignal:[[RACObserve(event, visibility) map:^id(id value) {
            return [event localizedVisibilityString];
        }] takeUntil:cell.rac_prepareForReuseSignal]];
        cell.userInteractionEnabled = YES;
        cell.contentView.alpha=1;
        if (!newEvent) {
            NSDictionary *visibilityPermissions = [event.fields objectForKey:@"visibility"];
            BOOL canEditVisibility = [[visibilityPermissions objectForKey:@"canEdit"] boolValue];
            if (!canEditVisibility) {
                cell.contentView.alpha=0.2;
                cell.userInteractionEnabled = NO;
            }
        }
        returnCell = cell;
    }

    if ([returnCell respondsToSelector:@selector(setDividerLineHidden:)]) {
        [(CHDEventInfoTableViewCell*)returnCell setDividerLineHidden: indexPath.row == [tableView numberOfRowsInSection:indexPath.section]-1];
    }

    return returnCell;
}

#pragma mark - AlertView delegate

-(void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex{
    if (alertView.tag == 111) {
        if (buttonIndex == 0)
        {
            self.viewModel.event.sendNotifications = false;
            [self saveEvent];
        }
        else
        {
            self.viewModel.event.sendNotifications = true;
            [self saveEvent];
        }
    }
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
