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

static CGFloat kCalendarHeight = 330.0f;
static CGFloat kDayPickerHeight = 50.0f;

@interface CHDCalendarViewController () <UITableViewDataSource, UITableViewDelegate, SHPCalendarPickerViewDelegate>

@property (nonatomic, strong) UIView *contentView;
@property (nonatomic, strong) CHDMagicNavigationBarView *magicNavigationBar;
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

@end

@implementation CHDCalendarViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.viewModel = [[CHDCalendarViewModel alloc] initWithReferenceDate:[NSDate date]];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self setupSubviews];
    [self makeConstraints];
    [self setupBindings];
}

- (void)setupSubviews {
    [self.view addSubview:self.contentView];
    [self.view addSubview:self.magicNavigationBar];
    [self.contentView addSubview:self.calendarPicker];
    [self.contentView addSubview:self.tableView];
    
    [self addChildViewController:self.dayPickerViewController];
    [self.view addSubview:self.dayPickerViewController.view];
    [self.dayPickerViewController didMoveToParentViewController:self];
    
    self.navigationItem.titleView = self.titleView;
}

- (void)makeConstraints {
    
    [self.contentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.bottom.right.equalTo(self.view);
        self.magicNavigationBar.bottomConstraint = make.top.equalTo(self.view);
    }];
    
    [self.magicNavigationBar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.view);
        make.bottom.equalTo(self.contentView.mas_top);
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

}

- (void) setupBindings {
    NSDateFormatter *monthFormatter = [NSDateFormatter new];
    monthFormatter.dateFormat = @"MMMM";
    
    [self.tableView shprac_liftSelector:@selector(reloadData) withSignal:RACObserve(self.viewModel, sections)];
    
    RACSignal *protocolSignal = [[self rac_signalForSelector:@selector(calendarPickerView:willAnimateToMonth:)] map:^id(RACTuple *tuple) {
        return tuple.second;
    }];
    [self.titleView.titleButton rac_liftSelector:@selector(setTitle:forState:) withSignalOfArguments:[[RACSignal merge:@[RACObserve(self.calendarPicker, currentMonth), protocolSignal, RACObserve(self.dayPickerViewController, centerDate)]] map:^id(NSDate *date) {
        return RACTuplePack([monthFormatter stringFromDate:date], @(UIControlStateNormal));
    }]];
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

#pragma mark - SHPCalendarPickerViewDelegate

- (void)calendarPickerView:(SHPCalendarPickerView *)calendarPickerView didSelectDate:(NSDate *)date {
    
}

- (void)calendarPickerView:(SHPCalendarPickerView *)calendarPickerView willAnimateToMonth:(NSDate *)date {
    // for signaling
}

#pragma mark - UITableViewDelegate

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    CHDCalendarHeaderView *header = [tableView dequeueReusableHeaderFooterViewWithIdentifier:@"header"];
    
    NSDate *date = self.viewModel.sections[section];
    
    header.dayLabel.text = [self.weekdayFormatter stringFromDate:date];
    header.dateLabel.text = [self.dayFormatter stringFromDate:date];
    header.nameLabel.text = @"";
    header.dotColors = @[[UIColor chd_blueColor], [UIColor chd_greenColor], [UIColor magentaColor]];
    
    return header;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    CHDEventInfoViewController *vc = [CHDEventInfoViewController new];
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
    cell.parishLabel.text = event.site;
    cell.dateTimeLabel.text = event.allDayEvent ? NSLocalizedString(@"All Day", @"") : [NSString stringWithFormat:@"%@ - %@", [self.timeFormatter stringFromDate:event.startDate], [self.timeFormatter stringFromDate:event.endDate]];
    
    if(indexPath.item % 2 == 1) {
        [cell.leftBorder setBackgroundColor:[UIColor chd_categoryBlueColor]];
    }else{
        [cell.leftBorder setBackgroundColor:[UIColor chd_categoryRedColor]];
    }
    
    return cell;
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

@end
