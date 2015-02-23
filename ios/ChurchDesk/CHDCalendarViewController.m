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

static CGFloat kCalendarHeight = 330.0f;

@interface CHDCalendarViewController () <UITableViewDataSource, UITableViewDelegate, SHPCalendarPickerViewDelegate>

@property (nonatomic, strong) SHPCalendarPickerView *calendarPicker;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) CHDCalendarTitleView *titleView;

@property (nonatomic, strong) MASConstraint *calendarTopConstraint;

@end

@implementation CHDCalendarViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self setupSubviews];
    [self makeConstraints];
}

- (void)setupSubviews {
    [self.view addSubview:self.calendarPicker];
    [self.view addSubview:self.tableView];
        
    self.navigationItem.titleView = self.titleView;
}

- (void)makeConstraints {
    
    [self.calendarPicker mas_makeConstraints:^(MASConstraintMaker *make) {
        self.calendarTopConstraint = make.top.equalTo(self.view).offset(-kCalendarHeight);
        make.left.right.equalTo(self.view);
        make.height.equalTo(@(kCalendarHeight));
    }];
    
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.bottom.right.equalTo(self.view);
        make.top.equalTo(self.calendarPicker.mas_bottom);
    }];
}

- (void) setupBindings {
    
}

#pragma mark - Actions

- (void) titleButtonAction: (id) sender {
    BOOL show = self.calendarPicker.frame.origin.y < 0;
    [self.calendarTopConstraint setOffset:show ? 0 : -kCalendarHeight];
    
    [UIView animateWithDuration:0.4 delay:0 usingSpringWithDamping:0.8 initialSpringVelocity:1.0 options:0 animations:^{
        self.titleView.pointArrowDown = !show;
        [self.view layoutIfNeeded];
    } completion:nil];
}

#pragma mark - SHPCalendarPickerViewDelegate

- (void)calendarPickerView:(SHPCalendarPickerView *)calendarPickerView didSelectDate:(NSDate *)date {
    
}

#pragma mark - UITableViewDelegate

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    CHDCalendarHeaderView *header = [tableView dequeueReusableHeaderFooterViewWithIdentifier:@"header"];
    
    header.dayLabel.text = @"Friday";
    header.dateLabel.text = @"1 May";
    header.nameLabel.text = @"Store bededag";
    header.dotColors = @[[UIColor chd_blueColor], [UIColor chd_greenColor], [UIColor magentaColor]];
    
    return header;
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    CHDEventTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    //cell.textLabel.text = cellTitle;
    cell.titleLabel.text = @"Title";
    cell.locationLabel.text = @"Location";
    cell.parishLabel.text = @"The Parish";
    cell.dateTimeLabel.text = @"Today";
    //cell.
    
    if(indexPath.item % 2 == 1) {
        [cell.leftBorder setBackgroundColor:[UIColor chd_categoryBlueColor]];
    }else{
        [cell.leftBorder setBackgroundColor:[UIColor chd_categoryRedColor]];
    }
    
    return cell;
}

#pragma mark - Lazy Initialization

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

@end
