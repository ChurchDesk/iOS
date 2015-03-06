//
//  CHDEditEventViewController.m
//  ChurchDesk
//
//  Created by Mikkel Selsøe Sørensen on 06/03/15.
//  Copyright (c) 2015 Shape A/S. All rights reserved.
//

#import "CHDEditEventViewController.h"
#import "CHDEventInfoTableViewCell.h"
#import "CHDEditEventViewModel.h"
#import "CHDDividerTableViewCell.h"
#import "CHDEventTextFieldCell.h"
#import "CHDEventValueTableViewCell.h"
#import "CHDEvent.h"

@interface CHDEditEventViewController () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) CHDEditEventViewModel *viewModel;
@property (nonatomic, strong) NSDateFormatter *dateFormatter;

@end

@implementation CHDEditEventViewController

- (instancetype)initWithEvent: (CHDEvent*) event {
    self = [super init];
    if (self) {
        self.viewModel = [[CHDEditEventViewModel alloc] initWithEvent:event];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupSubviews];
    [self makeConstraints];
}

- (void) setupSubviews {
    [self.view addSubview:self.tableView];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Cancel", @"") style:UIBarButtonItemStylePlain target:self action:@selector(cancelAction:)];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Save", @"") style:UIBarButtonItemStylePlain target:self action:@selector(saveAction:)];
}

- (void) makeConstraints {
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
}

#pragma mark - Actions

- (void) cancelAction: (id) sender {
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

- (void) saveAction: (id) sender {
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - UITableViewDelegate

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
    
    if ([row isEqualToString:CHDEventEditRowDivider]) {
        CHDDividerTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"divider" forIndexPath:indexPath];
        returnCell = cell;
    }
    else if ([row isEqualToString:CHDEventEditRowTitle]) {
        CHDEventTextFieldCell *cell = [tableView dequeueReusableCellWithIdentifier:@"textfield" forIndexPath:indexPath];
        cell.textField.placeholder = NSLocalizedString(@"Title", @"");
        cell.textField.text = event.title;
        returnCell = cell;
    }
    else if ([row isEqualToString:CHDEventEditRowStartDate]) {
        CHDEventValueTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"value" forIndexPath:indexPath];
        cell.titleLabel.text = NSLocalizedString(@"Start", @"");
        cell.valueLabel.text = [self.dateFormatter stringFromDate:event.endDate];
        returnCell = cell;
    }
    else if ([row isEqualToString:CHDEventEditRowEndDate]) {
        CHDEventValueTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"value" forIndexPath:indexPath];
        cell.titleLabel.text = NSLocalizedString(@"End", @"");
        cell.valueLabel.text = [self.dateFormatter stringFromDate:event.endDate];
        returnCell = cell;
    }
    else if ([row isEqualToString:CHDEventEditRowParish]) {
        CHDEventValueTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"value" forIndexPath:indexPath];
        cell.titleLabel.text = NSLocalizedString(@"Parish", @"");
        cell.valueLabel.text = event.siteId;
        returnCell = cell;
    }
    else if ([row isEqualToString:CHDEventEditRowGroup]) {
        CHDEventValueTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"value" forIndexPath:indexPath];
        cell.titleLabel.text = NSLocalizedString(@"Group", @"");
        cell.valueLabel.text = [event.groupId stringValue];
        returnCell = cell;
    }
    else if ([row isEqualToString:CHDEventEditRowCategories]) {
        CHDEventValueTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"value" forIndexPath:indexPath];
        cell.titleLabel.text = NSLocalizedString(@"Category", @"");
        cell.valueLabel.text = @"3";//[event.eventCategoryIds];
        returnCell = cell;
    }
    else if ([row isEqualToString:CHDEventEditRowLocation]) {
        CHDEventTextFieldCell *cell = [tableView dequeueReusableCellWithIdentifier:@"textfield" forIndexPath:indexPath];
        cell.textField.placeholder = NSLocalizedString(@"Location", @"");
        cell.textField.text = event.location;
        returnCell = cell;
    }
    else if ([row isEqualToString:CHDEventEditRowResources]) {
        CHDEventValueTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"value" forIndexPath:indexPath];
        cell.titleLabel.text = NSLocalizedString(@"Resources", @"");
        cell.valueLabel.text = [event.groupId stringValue];
        returnCell = cell;
    }
    else if ([row isEqualToString:CHDEventEditRowContributor]) {
        CHDEventTextFieldCell *cell = [tableView dequeueReusableCellWithIdentifier:@"textfield" forIndexPath:indexPath];
        cell.textField.placeholder = NSLocalizedString(@"Contributor", @"");
        cell.textField.text = event.contributor;
        returnCell = cell;
    }
    else if ([row isEqualToString:CHDEventEditRowPrice]) {
        CHDEventTextFieldCell *cell = [tableView dequeueReusableCellWithIdentifier:@"textfield" forIndexPath:indexPath];
        cell.textField.placeholder = NSLocalizedString(@"Price", @"");
        cell.textField.text = event.price;
        returnCell = cell;
    }
    else if ([row isEqualToString:CHDEventEditRowGroup]) {
        CHDEventValueTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"value" forIndexPath:indexPath];
        cell.titleLabel.text = NSLocalizedString(@"Visibility", @"");
        cell.valueLabel.text = @"";
        returnCell = cell;
    }
    else {
        CHDEventInfoTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
        cell.titleLabel.text = row;
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
        [_tableView registerClass:[CHDEventInfoTableViewCell class] forCellReuseIdentifier:@"cell"];
        [_tableView registerClass:[CHDEventTextFieldCell class] forCellReuseIdentifier:@"textfield"];
        [_tableView registerClass:[CHDEventValueTableViewCell class] forCellReuseIdentifier:@"value"];
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
