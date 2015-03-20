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
#import "CHDCalendarFilterView.h"
#import "CHDPassthroughTouchView.h"

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
@property (nonatomic, strong) CHDCalendarFilterView *calendarFilterView;
@property (nonatomic, strong) SHPCalendarPickerView *calendarPicker;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) CHDCalendarTitleView *titleView;
@property (nonatomic, strong) CHDDayPickerViewController *dayPickerViewController;

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
    [self.calendarFilterView setupFiltersWithTitels:@[@"All events", @"My events"] filters:@[@(CHDCalendarFilterAllEvents),@(CHDCalendarFilterMyEvents)]];
    self.calendarFilterView.selectedFilter = CHDCalendarFilterAllEvents;

    [self setupBindings];

    self.viewModel.referenceDate = [NSDate date];
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
}

#pragma mark - SHPCalendarPickerViewDelegate

- (void)calendarPickerView:(SHPCalendarPickerView *)calendarPickerView didSelectDate:(NSDate *)date {
    self.viewModel.referenceDate = date;
    [self scrollToDate:date animated:NO];
}

- (void)calendarPickerView:(SHPCalendarPickerView *)calendarPickerView willChangeToMonth:(NSDate *)date {
    self.viewModel.referenceDate = date;
    [self scrollToDate:date animated:NO];
    [self.dayPickerViewController scrollToDate:date animated:NO];
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidEndDecelerating:(UITableView *)tableView {
    NSIndexPath *indexPath = [tableView chd_indexPathForRowOrHeaderAtPoint:tableView.contentOffset];
    self.viewModel.referenceDate = self.viewModel.sections[indexPath.section];
}

#pragma mark - UITableViewDelegate

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    CHDCalendarHeaderView *header = [tableView dequeueReusableHeaderFooterViewWithIdentifier:@"header"];

    NSDate *date = self.viewModel.sections[section];
    CHDHoliday *holiday = [self.viewModel holidayForDate:date];

    header.dayLabel.text = [self.weekdayFormatter stringFromDate:date];
    header.dateLabel.text = [self.dayFormatter stringFromDate:date];
    header.nameLabel.text = holiday.name;
    header.dotColors = @[[UIColor chd_blueColor], [UIColor chd_greenColor], [UIColor magentaColor]];

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

    CHDEventTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    cell.titleLabel.text = event.title;
    cell.locationLabel.text = event.location;
    cell.parishLabel.text = self.viewModel.user.sites.count > 1 ? [self.viewModel.user siteWithId:event.siteId].name : @"";
    cell.dateTimeLabel.text = event.allDayEvent ? NSLocalizedString(@"All Day", @"") : [NSString stringWithFormat:@"%@ - %@", [self.timeFormatter stringFromDate:event.startDate], [self.timeFormatter stringFromDate:event.endDate]];

    if(indexPath.item % 2 == 1) {
        [cell.leftBorder setBackgroundColor:[UIColor chd_categoryBlueColor]];
    }else{
        [cell.leftBorder setBackgroundColor:[UIColor chd_categoryRedColor]];
    }

    return cell;
}

#pragma mark - Actions

- (void) titleButtonAction: (id) sender {
    BOOL showCalendar = self.calendarPicker.frame.origin.y < 0;
    [self.calendarTopConstraint setOffset:showCalendar ? 0 : -kCalendarHeight];
    [self.dayPickerBottomConstraint setOffset:showCalendar ? kDayPickerHeight : 0];

    [UIView animateWithDuration:0.4 delay:0 usingSpringWithDamping: showCalendar ? 0.8 : 1.0 initialSpringVelocity:1.0 options:0 animations:^{
        self.titleView.pointArrowDown = !showCalendar;
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

- (void) todayButtonTouch: (id) sender {
    NSDate *today = [NSDate date];
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

- (CHDCalendarFilterView *)calendarFilterView{
    if(!_calendarFilterView){
        _calendarFilterView = [CHDCalendarFilterView new];
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
        [_todayButton setImage:kImgCalendarTodayIndicator forState:UIControlStateNormal];
    }
    return _todayButton;
}

@end
