//
//  CHDCalendarViewController.m
//  ChurchDesk
//
//  Created by Mikkel Selsøe Sørensen on 23/02/15.
//  Copyright (c) 2015 Shape A/S. All rights reserved.
//

#import "CHDCalendarViewController.h"
#import "SHPCalendarPicker.h"
#import "SHPCalendarPickerView+ChurchDesk.h"
#import "CHDEventTableViewCell.h"
#import "CHDCalendarHeaderView.h"
#import "CHDCalendarTitleView.h"
#import "CHDMagicNavigationBarView.h"
#import "CHDDayPickerViewController.h"
#import "CHDEventInfoViewController.h"
#import "CHDCalendarViewModel.h"
#import "CHDEvent.h"
#import "CHDHoliday.h"
#import "UITableView+ChurchDesk.h"
#import "CHDUser.h"
#import "CHDSite.h"
#import "UIViewController+UIViewController_ChurchDesk.h"
#import "CHDExpandableButtonView.h"
#import "CHDFilterView.h"
#import "CHDPassthroughTouchView.h"
#import "CHDEnvironment.h"
#import "CHDAnalyticsManager.h"
#import "CHDOverlayView.h"
#import <MBProgressHUD.h>

static CGFloat kCalendarHeight = 330.0f;
static CGFloat kDayPickerHeight = 50.0f;

typedef NS_ENUM(NSUInteger, CHDCalendarFilters) {
    CHDCalendarFilterAllEvents,
    CHDCalendarFilterMyEvents,
};

@interface CHDCalendarViewController () <UITableViewDataSource, UITableViewDelegate, SHPCalendarPickerViewDelegate>

@property (nonatomic, strong) UIView *contentView;
@property (nonatomic, strong) CHDMagicNavigationBarView *magicNavigationBar;
@property (nonatomic, strong) CHDPassthroughTouchView *drawerBlockOutView;
@property (nonatomic, strong) CHDFilterView *calendarFilterView;
@property (nonatomic, strong) SHPCalendarPickerView *calendarPicker;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) CHDCalendarTitleView *titleView;
@property (nonatomic, strong) CHDDayPickerViewController *dayPickerViewController;
@property (nonatomic, strong) MBProgressHUD *spinnerHUD;
@property (nonatomic, strong) CHDOverlayView *weekOverlay;

@property (nonatomic, strong) MASConstraint *calendarTopConstraint;
@property (nonatomic, strong) MASConstraint *dayPickerBottomConstraint;

@property (nonatomic, strong) CHDCalendarViewModel *viewModel;
@property (nonatomic, strong) NSDateFormatter *timeFormatter;
@property (nonatomic, strong) NSDateFormatter *weekdayFormatter;
@property (nonatomic, strong) NSDateFormatter *dayFormatter;

@property (nonatomic, strong) CHDExpandableButtonView *addButton;
@property (nonatomic, strong) UIButton *todayButton;

@end

@implementation CHDCalendarViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.viewModel = [[CHDCalendarViewModel alloc] init];

    self.view.backgroundColor = [UIColor whiteColor];

    [self setupSubviews];
    [self makeConstraints];
    [self.calendarFilterView setupFiltersWithTitels:@[NSLocalizedString(@"All events", @"Calendar filter"), NSLocalizedString(@"My events", @"Calendar filter")] filters:@[@(CHDCalendarFilterAllEvents),@(CHDCalendarFilterMyEvents)]];
    self.calendarFilterView.selectedFilter = CHDCalendarFilterAllEvents;

    [self setupBindings];

    self.viewModel.referenceDate = [NSDate date];

    //Use viewModel as delegate for the dayPicker (for showing event dots on daypicker)
    self.dayPickerViewController.delegate = self.viewModel;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self showCalendar:NO animated:NO];
    [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:YES];
    [[CHDAnalyticsManager sharedInstance] trackVisitToScreen:@"calendar"];
}

- (void)setupSubviews {
    [self.view addSubview:self.contentView];
    [self.view addSubview:self.magicNavigationBar];
    [self.magicNavigationBar.drawerView addSubview:self.calendarFilterView];
    [self.contentView addSubview:self.calendarPicker];
    [self.contentView addSubview:self.tableView];

    [self addChildViewController:self.dayPickerViewController];
    [self.view addSubview:self.dayPickerViewController.view];
    [self.dayPickerViewController didMoveToParentViewController:self];

    self.navigationItem.titleView = self.titleView;
    self.addButton = [self setupAddButtonWithView:self.view withConstraints:NO];
    [self.contentView addSubview:self.todayButton];
    [self.view addSubview:self.drawerBlockOutView];

    [self.view addSubview:self.weekOverlay];
}

- (void)makeConstraints {

    [self.drawerBlockOutView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.contentView);
    }];

    [self.contentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.bottom.right.equalTo(self.view);
        self.magicNavigationBar.bottomConstraint = make.top.equalTo(self.view);
    }];

    [self.magicNavigationBar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.view);
        make.bottom.equalTo(self.contentView.mas_top);
    }];

    [self.calendarFilterView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.magicNavigationBar.drawerView);
    }];

    [self.calendarPicker mas_makeConstraints:^(MASConstraintMaker *make) {
        self.calendarTopConstraint = make.top.equalTo(self.contentView).offset(-kCalendarHeight);
        make.left.right.equalTo(self.contentView);
        make.height.equalTo(@(kCalendarHeight));
    }];

    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.contentView);
        make.top.equalTo(self.calendarPicker.mas_bottom);
        make.bottom.equalTo(self.dayPickerViewController.view.mas_top);
    }];

    [self.weekOverlay mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.contentView);
        make.top.equalTo(self.calendarPicker.mas_bottom);
        make.bottom.equalTo(self.dayPickerViewController.view.mas_top);
    }];

    [self.dayPickerViewController.view mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.view);
        self.dayPickerBottomConstraint = make.bottom.equalTo(self.view);
        make.height.equalTo(@(kDayPickerHeight));
    }];

    [self.todayButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.dayPickerViewController.view.mas_top).offset(-15);
        make.left.equalTo(self.contentView).offset(15);
    }];

    [self.addButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.view);
        make.bottom.equalTo(self.dayPickerViewController.view.mas_top).offset(-5);
    }];
}

- (void) setupBindings {
    NSDateFormatter *monthFormatter = [NSDateFormatter new];
    monthFormatter.dateFormat = @"MMMM";

    [self.tableView shprac_liftSelector:@selector(reloadData) withSignal:RACObserve(self.viewModel, user)];

    [self rac_liftSelector:@selector(reloadDataWithPreviousSections:newSections:) withSignalOfArguments:[RACObserve(self.viewModel, sections) combinePreviousWithStart:nil reduce:^id(id previous, id current) {
        return RACTuplePack(previous, current);
    }]];

    RACSignal *protocolSignal = [[self rac_signalForSelector:@selector(calendarPickerView:willChangeToMonth:)] map:^id(RACTuple *tuple) {
        return tuple.second;
    }];

    [self.titleView.titleButton rac_liftSelector:@selector(setTitle:forState:) withSignalOfArguments:[[RACSignal merge:@[RACObserve(self.calendarPicker, currentMonth), protocolSignal]] map:^id(NSDate *date) {
        return RACTuplePack([monthFormatter stringFromDate:date], @(UIControlStateNormal));
    }]];

    [RACChannelTo(self.calendarPicker, selectedDates) shprac_connectWithMap:^id(NSArray *selectedDates) {
        return selectedDates.firstObject;
    } to:RACChannelTo(self.dayPickerViewController, selectedDate) withMap:^id(NSDate *selectedDate) {
        return @[selectedDate];
    }];

    [self.calendarPicker rac_liftSelector:@selector(setCurrentMonth:) withSignals:[RACObserve(self.dayPickerViewController, selectedDate) ignore:nil], nil];

    [self rac_liftSelector:@selector(dayPickerDidSelectDate:) withSignals:[RACObserve(self.dayPickerViewController, selectedDate) ignore:nil], nil];
    [self rac_liftSelector:@selector(changeCalendarFilter:) withSignals:[RACObserve(self.calendarFilterView, selectedFilter) skip:1], nil];

    //Handle when the drawer is shown/hidden
    RACSignal *drawerIsShownSignal = RACObserve(self.magicNavigationBar, drawerIsHidden);

    [self shprac_liftSelector:@selector(drawerDidHide) withSignal:[drawerIsShownSignal filter:^BOOL(NSNumber *iIsHidden) {
        return iIsHidden.boolValue;
    }]];

    [self shprac_liftSelector:@selector(drawerWillShow) withSignal:[drawerIsShownSignal filter:^BOOL(NSNumber *iIsHidden) {
        return !iIsHidden.boolValue;
    }]];

    RACSignal *touchedDrawerBlockOutViewSignal = [self.drawerBlockOutView rac_signalForSelector:@selector(touchesBegan:withEvent:)];
    [self shprac_liftSelector:@selector(blockOutViewTouched) withSignal:touchedDrawerBlockOutViewSignal];

    [self rac_liftSelector:@selector(todayButtonTouch:) withSignals:[self.todayButton rac_signalForControlEvents:UIControlEventTouchUpInside], nil];

    [self rac_liftSelector:@selector(dayPickerWeekNumberDidChange:) withSignals:[RACObserve(self.dayPickerViewController, currentWeekNumber) skip:1], nil];

    //Reload the daypicker - primarily to show dots in the view
    [self.dayPickerViewController shprac_liftSelector:@selector(reloadShownDates) withSignal:RACObserve(self.viewModel, sections)];
    
    [self rac_liftSelector:@selector(showSpinner:) withSignals:[RACObserve(self.viewModel, events) map:^id(NSArray *events) {
        return @(events == nil);
    }], nil];
}

- (void) reloadDataWithPreviousSections: (NSArray*) previousSections newSections: (NSArray*) newSections {
    // Before reloading, determine exact offset relative to section (date) so when reload is done,
    // we can reset the offset to make the reload operation invisible to the user.
    NSIndexPath *indexPath = [self.tableView chd_indexPathForRowOrHeaderAtPoint:self.tableView.contentOffset];
    CGFloat sectionOffset = 0;
    NSDate *topSection = self.viewModel.referenceDate;
    if (indexPath) {
        topSection = previousSections[indexPath.section];
        CGRect rect = [self.tableView rectForSection:indexPath.section];
        sectionOffset = -(rect.origin.y - self.tableView.contentOffset.y);
    }

    [self.tableView reloadData];
    [self.view layoutIfNeeded];
    if (topSection) {
        [self scrollToDate:topSection animated:NO offset:sectionOffset];
    }
    [self dotColorsForFirstVisibleSection];
}

-(void) showSpinner: (BOOL) show {
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
        NSArray *allHUDs = [MBProgressHUD allHUDsForView:self.navigationController.view];
        for (MBProgressHUD *hud in allHUDs) {
            if (hud.mode == MBProgressHUDModeIndeterminate) {
                [hud hide:YES];
            }
        }
    }
}

#pragma mark - DayPicker actions
-(void)dayPickerWeekNumberDidChange: (NSNumber*) weekNumber {
    NSDate *date = self.dayPickerViewController.referenceDate;
    if(date) {
        NSDateComponents *todayComponents = [[NSCalendar currentCalendar] components:NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay fromDate:date];
        NSDate *roundedDate = [[NSCalendar currentCalendar] dateFromComponents:todayComponents];

        [self.dayPickerViewController scrollToDate:roundedDate animated:NO];
        [self.calendarPicker setCurrentMonth:roundedDate];
        [self.calendarPicker setSelectedDates:@[roundedDate]];
    }

    self.weekOverlay.titleLabel.text = [NSString stringWithFormat:NSLocalizedString(@"Week\n%@", nil), weekNumber];
    [UIView animateWithDuration:0.5 animations:^{
        self.weekOverlay.alpha = 1;
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.5 delay:0.5 options:0 animations:^{
            self.weekOverlay.alpha = 0;
        } completion:nil];
    }];
}

#pragma mark - SHPCalendarPickerViewDelegate

- (void)calendarPickerView:(SHPCalendarPickerView *)calendarPickerView didSelectDate:(NSDate *)date {
    self.viewModel.referenceDate = date;
    [self scrollToDate:date animated:NO];
    [self showCalendar:NO animated:YES];
}

- (void)calendarPickerView:(SHPCalendarPickerView *)calendarPickerView willChangeToMonth:(NSDate *)date {
    self.viewModel.referenceDate = date;
    [self scrollToDate:date animated:NO];
    [self.dayPickerViewController scrollToDate:date animated:NO];
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidEndDecelerating:(UITableView *)tableView {
    if(self.viewModel.sections.count > 0) {
        NSIndexPath *indexPath = [tableView chd_indexPathForRowOrHeaderAtPoint:tableView.contentOffset];
        self.viewModel.referenceDate = self.viewModel.sections[indexPath.section];
    }
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [self dotColorsForFirstVisibleSection];

    if(self.viewModel.sections.count > 0) {
        NSDateComponents *todayComponents = [[NSCalendar currentCalendar] components:NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay fromDate:[NSDate date]];

        NSDate *today = [[NSCalendar currentCalendar] dateFromComponents:todayComponents];

        CGPoint contentOffset = self.tableView.contentOffset;
        NSIndexPath *topIndexPath = [self.tableView chd_indexPathForRowOrHeaderAtPoint:contentOffset];

        CGPoint bottomOffset = CGPointMake(contentOffset.x, contentOffset.y + self.tableView.frame.size.height);
        NSIndexPath *bottomIndexPath = [self.tableView chd_indexPathForRowOrHeaderAtPoint:bottomOffset];

        NSDate *firstDate = self.viewModel.sections[topIndexPath.section];
        NSDate *lastDate = self.viewModel.sections[bottomIndexPath.section];

        [self.dayPickerViewController scrollToDate:firstDate animated:NO];

        if(firstDate.timeIntervalSince1970 <= today.timeIntervalSince1970 && lastDate.timeIntervalSince1970 >= today.timeIntervalSince1970){
            if(!self.todayButton.isHidden) {
                [UIView animateWithDuration:0.3 animations:^{
                    self.todayButton.alpha = 0;
                } completion:^(BOOL finished) {
                    if(finished) {
                        self.todayButton.hidden = YES;
                    }
                }];
            }
        }else{
            if(self.todayButton.isHidden) {
                self.todayButton.hidden = NO;
                [UIView animateWithDuration:0.3 animations:^{
                    self.todayButton.alpha = 1;
                } completion:^(BOOL finished) {

                }];
            }
        }
    }
}

#pragma mark - UITableViewDelegate

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if(self.viewModel.sections.count == 0){
        return nil;
    }
    CHDCalendarHeaderView *header = [tableView headerViewForSection:section]?: [tableView dequeueReusableHeaderFooterViewWithIdentifier:@"header"];

    NSDate *date = self.viewModel.sections[section];
    CHDHoliday *holiday = [self.viewModel holidayForDate:date];

    header.dayLabel.text = [self.weekdayFormatter stringFromDate:date];
    header.dateLabel.text = [self.dayFormatter stringFromDate:date];
    header.nameLabel.text = holiday.name;

    NSIndexPath *indexPath = [self.tableView chd_indexPathForRowOrHeaderAtPoint:self.tableView.contentOffset];
    if(indexPath.section == section) {
        CGRect sectionRect = [self.tableView rectForSection:section];
        header.dotColors = [self.viewModel rowColorsForSectionBeforeIndexPath:indexPath sectionRect:sectionRect contentOffset:self.tableView.contentOffset];
    }else {
        header.dotColors = @[];
    }

    return header;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    CHDEvent *event = [self.viewModel eventsForSectionAtIndex:indexPath.section][indexPath.row];

    CHDEventInfoViewController *vc = [[CHDEventInfoViewController alloc] initWithEvent:event];
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.viewModel.sections.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.viewModel eventsForSectionAtIndex:section].count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    CHDEvent *event = [self.viewModel eventsForSectionAtIndex:indexPath.section][indexPath.row];

    NSDate *sectionDate = self.viewModel.sections[indexPath.section];

    CHDEventTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    cell.titleLabel.text = event.title;
    cell.locationLabel.text = event.location;
    cell.parishLabel.text = self.viewModel.user.sites.count > 1 ? [self.viewModel.user siteWithId:event.siteId].name : @"";
    cell.dateTimeLabel.text = [self.viewModel formattedTimeForEvent:event referenceDate:sectionDate];


    CHDEventCategory *category = [self.viewModel.environment eventCategoryWithId:event.eventCategoryIds.firstObject siteId: event.siteId];
    [cell.cellBackgroundView setBorderColor:category.color?: [UIColor clearColor]];

    return cell;
}

#pragma mark - Actions

-(void) dotColorsForFirstVisibleSection {
    if(self.viewModel.sections.count > 0) {
        NSIndexPath *indexPath = [self.tableView chd_indexPathForRowOrHeaderAtPoint:self.tableView.contentOffset];

        CHDCalendarHeaderView *header = (CHDCalendarHeaderView *) [self tableView:self.tableView viewForHeaderInSection:indexPath.section];
        CGRect sectionRect = [self.tableView rectForSection:indexPath.section];
        NSArray *colors = [self.viewModel rowColorsForSectionBeforeIndexPath:indexPath sectionRect:sectionRect contentOffset:self.tableView.contentOffset];

        header.dotColors = colors;
    }
}

- (void) titleButtonAction: (id) sender {
    BOOL showCalendar = self.calendarPicker.frame.origin.y < 0;
    [self showCalendar:showCalendar animated:YES];
}

-(void) showCalendar: (BOOL) show animated: (BOOL) animated {
    [self.calendarTopConstraint setOffset:show ? 0 : -kCalendarHeight];
    [self.dayPickerBottomConstraint setOffset:show ? kDayPickerHeight : 0];

    [UIView animateWithDuration:animated? 0.4 : 0 delay:0 usingSpringWithDamping: show ? 0.8f : 1.0f initialSpringVelocity:1.0 options:0 animations:^{
        self.titleView.pointArrowDown = !show;
        [self.view layoutIfNeeded];
    } completion:nil];
}

- (void) scrollToDate: (NSDate*) date animated: (BOOL) animated {
    [self scrollToDate:date animated:animated offset:0];
}

- (void) scrollToDate: (NSDate*) date animated: (BOOL) animated offset: (CGFloat) offset {
    NSIndexPath *indexPath = [self.viewModel indexPathForDate:date];
    if (indexPath) {
        [self.tableView setContentOffset:CGPointMake(0, [self.tableView rectForSection:indexPath.section].origin.y + offset) animated:animated];
    }
}


- (void) dayPickerDidSelectDate: (NSDate*) date {
    [self scrollToDate:date animated:NO];
}

- (void) todayButtonTouch: (id) sender {
    NSDateComponents *todayComponents = [[NSCalendar currentCalendar] components:NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay fromDate:[NSDate date]];

    NSDate *today = [[NSCalendar currentCalendar] dateFromComponents:todayComponents];
    self.viewModel.referenceDate = today;
    [self.dayPickerViewController scrollToDate:today animated:NO];
    [self.calendarPicker setCurrentMonth:today];
    [self scrollToDate:today animated:NO];
    [self.calendarPicker setSelectedDates:@[today]];
}

- (void) blockOutViewTouched {
    [self.magicNavigationBar setShowDrawer:NO animated:YES];
}

- (void) drawerWillShow {
    self.drawerBlockOutView.touchesPassThrough = NO;
}

-(void) drawerDidHide {
    self.drawerBlockOutView.touchesPassThrough = YES;
}

- (void) changeCalendarFilter: (CHDCalendarFilters) filter {
    [[CHDAnalyticsManager sharedInstance] trackEventWithCategory:ANALYTICS_CATEGORY_CALENDAR action:ANALYTICS_ACTION_FILTER label:filter == CHDCalendarFilterMyEvents? ANALYTICS_LABEL_MYEVENTS : ANALYTICS_LABEL_ALL];

    [UIView animateWithDuration:.3 delay:0 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
        self.drawerBlockOutView.backgroundColor = [UIColor colorWithWhite:1 alpha:1];
    } completion:^(BOOL finished) {
        self.viewModel.myEventsOnly = filter == CHDCalendarFilterMyEvents;
        [UIView animateWithDuration:.3 delay:0.2 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
            self.drawerBlockOutView.backgroundColor = [UIColor colorWithWhite:1 alpha:0];
        } completion:nil];
    }];
}

#pragma mark - Lazy Initialization

- (UIView *)contentView {
    if (!_contentView) {
        _contentView = [UIView new];
    }
    return _contentView;
}

- (CHDMagicNavigationBarView *)magicNavigationBar {
    if (!_magicNavigationBar) {
        _magicNavigationBar = [[CHDMagicNavigationBarView alloc] initWithNavigationController:self.navigationController navigationItem:self.navigationItem];
    }
    return _magicNavigationBar;
}

- (SHPCalendarPickerView *)calendarPicker {
    if (!_calendarPicker) {
        _calendarPicker = [SHPCalendarPickerView chd_calendarPickerView];
        _calendarPicker.delegate = self;
    }
    return _calendarPicker;
}

- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [UITableView new];
        _tableView.dataSource = self;
        _tableView.delegate = self;
        _tableView.rowHeight = 65;
        _tableView.sectionHeaderHeight = 37;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        [_tableView registerClass:[CHDEventTableViewCell class] forCellReuseIdentifier:@"cell"];
        [_tableView registerClass:[CHDCalendarHeaderView class] forHeaderFooterViewReuseIdentifier:@"header"];
    }
    return _tableView;
}

- (CHDCalendarTitleView *)titleView {
    if (!_titleView) {
        _titleView = [CHDCalendarTitleView new];
        [_titleView.titleButton addTarget:self action:@selector(titleButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        _titleView.pointArrowDown = YES;
    }
    return _titleView;
}

- (CHDDayPickerViewController *)dayPickerViewController {
    if (!_dayPickerViewController) {
        _dayPickerViewController = [CHDDayPickerViewController new];
    }
    return _dayPickerViewController;
}

- (NSDateFormatter *)timeFormatter {
    if (!_timeFormatter) {
        _timeFormatter = [NSDateFormatter new];
        _timeFormatter.timeStyle = NSDateFormatterShortStyle;
    }
    return _timeFormatter;
}

- (NSDateFormatter *)weekdayFormatter {
    if (!_weekdayFormatter) {
        _weekdayFormatter = [NSDateFormatter new];
        _weekdayFormatter.dateFormat = @"EEE";
    }
    return _weekdayFormatter;
}

- (NSDateFormatter *)dayFormatter {
    if (!_dayFormatter) {
        _dayFormatter = [NSDateFormatter new];
        _dayFormatter.dateFormat = [NSDateFormatter dateFormatFromTemplate:@"dd MMMM" options:0 locale:[NSLocale currentLocale]];
    }
    return _dayFormatter;
}

- (CHDFilterView *)calendarFilterView{
    if(!_calendarFilterView){
        _calendarFilterView = [CHDFilterView new];
    }
    return _calendarFilterView;
}

-(CHDPassthroughTouchView*) drawerBlockOutView {
    if(!_drawerBlockOutView){
        _drawerBlockOutView = [CHDPassthroughTouchView new];
        _drawerBlockOutView.backgroundColor = [UIColor colorWithWhite:1 alpha:0];
    }
    return _drawerBlockOutView;
}

- (UIButton*) todayButton {
    if(!_todayButton){
        _todayButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_todayButton setBackgroundImage:kImgCalendarTodayIndicator forState:UIControlStateNormal];
        [_todayButton setBackgroundImage:kImgCalendarTodayIndicatorPressed forState:UIControlStateHighlighted];
        [_todayButton setTitle:NSLocalizedString(@"Now", @"") forState:UIControlStateNormal];
        [_todayButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _todayButton.titleLabel.font = [UIFont chd_fontWithFontWeight:CHDFontWeightRegular size:13];
        _todayButton.titleEdgeInsets = UIEdgeInsetsMake(-4, 0, 4, 0);
    }
    return _todayButton;
}
-(CHDOverlayView*)weekOverlay{
    if(!_weekOverlay){
        _weekOverlay = [CHDOverlayView new];
        _weekOverlay.titleLabel.font = [UIFont chd_fontWithFontWeight:CHDFontWeightRegular size:40];
        _weekOverlay.alpha = 0;
    }
    return _weekOverlay;
}

@end
