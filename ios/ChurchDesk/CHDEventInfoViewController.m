//
//  CHDEventInfoViewController.m
//  ChurchDesk
//
//  Created by Mikkel Selsøe Sørensen on 26/02/15.
//  Copyright (c) 2015 Shape A/S. All rights reserved.
//

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

@interface CHDEventInfoViewController () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) CHDEventInfoViewModel *viewModel;
@property (nonatomic, strong) NSDateFormatter *creationDateFormatter;
@property (nonatomic, strong) NSDateFormatter *eventDateFormatter;

@end

@implementation CHDEventInfoViewController

- (instancetype)initWithEvent: (CHDEvent*) event {
    if (self = [super init]) {
        self.viewModel = [[CHDEventInfoViewModel alloc] initWithEvent:event];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = NSLocalizedString(@"Event Information", @"");
    
    [self setupSubviews];
    [self makeConstraints];
    [self setupBindings];
}

- (void) setupSubviews {
    [self.view addSubview:self.tableView];
}

- (void) makeConstraints {
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
}

- (void) setupBindings {
    [self.tableView shprac_liftSelector:@selector(reloadData) withSignal:RACObserve(self.viewModel, event)];
}

#pragma mark - UITableViewDelegate

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
        cell.titleLabel.text = @"Group name";
        cell.groupLabel.text = @"Parish";
        returnCell = cell;
    }
    else if ([row isEqualToString:CHDEventInfoRowDate]) {
        CHDEventInfoTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
        cell.iconImageView.image = kImgEventTime;
        cell.titleLabel.text = @"Date and time";
        cell.disclosureArrowHidden = YES;
        returnCell = cell;
    }
    else if ([row isEqualToString:CHDEventInfoRowLocation]) {
        CHDEventLocationTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"location" forIndexPath:indexPath];
        cell.titleLabel.text = @"Vor Frue Kirke";
        returnCell = cell;
    }
    else if ([row isEqualToString:CHDEventInfoRowCategories]) {
        CHDEventCategoriesTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"categories" forIndexPath:indexPath];
        cell.titleLabel.text = NSLocalizedString(@"Categories", @"");
        [cell setCategoryTitles:@[@"Kategori 1 med et helt vildt langt navn", @"KAtegori 2", @"Kategori 3"] colors:@[[UIColor greenColor], [UIColor redColor], [UIColor blueColor]]];
        returnCell = cell;
    }
    else if ([row isEqualToString:CHDEventInfoRowAttendance]) {
        CHDEventAttendanceTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"attendance" forIndexPath:indexPath];
        cell.attendanceLabel.text = [self.viewModel textForEventResponse:event.eventResponse];
        cell.attendanceLabel.textColor = [self.viewModel textColorForEventResponse:event.eventResponse];
        returnCell = cell;
    }
    
    // Resources
    else if ([row isEqualToString:CHDEventInfoRowResources]) {
        CHDEventCategoriesTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"categories" forIndexPath:indexPath];
        cell.titleLabel.text = NSLocalizedString(@"Resources", @"");
        [cell setCategoryTitles:@[@"Resource 1", @"Resource 2", @"Resource 3"] colors:@[[UIColor greenColor], [UIColor redColor], [UIColor blueColor]]];
        returnCell = cell;
    }
    else if ([row isEqualToString:CHDEventInfoRowUsers]) {
        CHDEventUsersTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"users" forIndexPath:indexPath];
        [cell setUserNames:@[@"John Appleseed", @"John Appleseed", @"John Appleseed", @"John Appleseed", @"John Appleseed"]];
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
        cell.valueLabel.text = @"John Appleseed";
        returnCell = cell;
    }
    else if ([row isEqualToString:CHDEventInfoRowPrice]) {
        CHDEventTextValueTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"textValue" forIndexPath:indexPath];
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
        cell.titleLabel.text = NSLocalizedString(@"Visibility", @"");
        cell.valueLabel.text = event.publicEvent ? NSLocalizedString(@"Public on website", @"") : NSLocalizedString(@"Private event", @"");
        returnCell = cell;
    }
    else if ([row isEqualToString:CHDEventInfoRowCreated]) {
        CHDEventTextValueTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"textValue" forIndexPath:indexPath];
        cell.titleLabel.text = NSLocalizedString(@"Created On", @"");
        cell.valueLabel.text = [self.creationDateFormatter stringFromDate:event.creationDate];
        returnCell = cell;
    }
    
    // Dividers
    else if ([section isEqualToString:CHDEventInfoSectionDivider]) {
        returnCell = [tableView dequeueReusableCellWithIdentifier:@"divider" forIndexPath:indexPath];
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

@end
