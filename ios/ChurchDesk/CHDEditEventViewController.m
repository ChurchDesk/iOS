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
#import "CHDUser.h"
#import "CHDEnvironment.h"
#import "CHDEventTextViewTableViewCell.h"
#import "SHPKeyboardAwareness.h"

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
    
    self.tableView.backgroundColor = [UIColor chd_lightGreyColor];
    
    [self setupSubviews];
    [self makeConstraints];
    [self setupBindings];
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

- (void) setupBindings {
    [self.tableView shprac_liftSelector:@selector(reloadData) withSignal:[[RACSignal merge:@[RACObserve(self.viewModel, environment), RACObserve(self.viewModel, user)]] ignore:nil]];
    
    [self rac_liftSelector:@selector(handleKeyboardEvent:) withSignals:[self shp_keyboardAwarenessSignal], nil];
}

#pragma mark - Actions

- (void) cancelAction: (id) sender {
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

- (void) saveAction: (id) sender {
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
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
        cell.hideTopLine = indexPath.section == 0 && indexPath.row == 0;
        cell.hideBottomLine = indexPath.section == [tableView numberOfSections]-1 && indexPath.row == [tableView numberOfRowsInSection:indexPath.section]-1;
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
        cell.valueLabel.text = [self.viewModel.user siteWithId:event.siteId].name;
        returnCell = cell;
    }
    else if ([row isEqualToString:CHDEventEditRowGroup]) {
        CHDEventValueTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"value" forIndexPath:indexPath];
        cell.titleLabel.text = NSLocalizedString(@"Group", @"");
        cell.valueLabel.text = [self.viewModel.environment groupWithId:event.groupId].name;
        returnCell = cell;
    }
    else if ([row isEqualToString:CHDEventEditRowCategories]) {
        CHDEventValueTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"value" forIndexPath:indexPath];
        cell.titleLabel.text = NSLocalizedString(@"Category", @"");
        cell.valueLabel.text = event.eventCategoryIds.count <= 1 ? [self.viewModel.environment eventCategoryWithId:event.eventCategoryIds.firstObject].name : [@(event.eventCategoryIds.count) stringValue];
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
        cell.valueLabel.text = event.resourceIds.count <= 1 ? [self.viewModel.environment resourceWithId:event.resourceIds.firstObject].name : [@(event.resourceIds.count) stringValue];
        returnCell = cell;
    }
    else if ([row isEqualToString:CHDEventEditRowUsers]) {
        CHDEventValueTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"value" forIndexPath:indexPath];
        cell.titleLabel.text = NSLocalizedString(@"Users", @"");
        cell.valueLabel.text = event.userIds.count <= 1 ? [self.viewModel.environment userWithId:event.userIds.firstObject].name : [@(event.userIds.count) stringValue];
        returnCell = cell;
    }
    else if ([row isEqualToString:CHDEventEditRowInternalNote] || [row isEqualToString:CHDEventEditRowDescription]) {
        CHDEventTextViewTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"textview" forIndexPath:indexPath];
        cell.placeholder = [row isEqualToString:CHDEventEditRowInternalNote] ? NSLocalizedString(@"Internal note", @"") : NSLocalizedString(@"Description", @"");
        cell.textView.text = [row isEqualToString:CHDEventEditRowInternalNote] ? event.internalNote : event.eventDescription;
        cell.tableView = tableView;
        
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
    else if ([row isEqualToString:CHDEventEditRowVisibility]) {
        CHDEventValueTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"value" forIndexPath:indexPath];
        cell.titleLabel.text = NSLocalizedString(@"Visibility", @"");
        cell.valueLabel.text = event.publicEvent ? NSLocalizedString(@"Public", @"") : NSLocalizedString(@"Internal", @"");
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
        [_tableView registerClass:[CHDEventInfoTableViewCell class] forCellReuseIdentifier:@"cell"];
        [_tableView registerClass:[CHDEventTextFieldCell class] forCellReuseIdentifier:@"textfield"];
        [_tableView registerClass:[CHDEventValueTableViewCell class] forCellReuseIdentifier:@"value"];
        [_tableView registerClass:[CHDEventTextViewTableViewCell class] forCellReuseIdentifier:@"textview"];
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
