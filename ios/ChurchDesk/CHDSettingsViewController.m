//
//  CHDSettingsViewController.m
//  ChurchDesk
//
//  Created by Jakob Vinther-Larsen on 20/02/15.
//  Copyright (c) 2015 Shape A/S. All rights reserved.
//

#import "CHDSettingsViewController.h"
#import "CHDSettingsTableViewCell.h"
#import "CHDDescriptionTableViewCell.h"
#import "CHDAuthenticationManager.h"
#import "CHDSettingsViewModel.h"
#import "CHDNotificationSettings.h"
#import "CHDAnalyticsManager.h"

typedef NS_ENUM(NSUInteger, notificationSettings) {
    eventsChanged,
    eventsUpdated,
    eventsCancels,
    messagesNewAndUpdate,
    notificationSettingsCount,
};

@interface CHDSettingsViewController ()
@property (nonatomic, strong) UITableView* settingsTable;
@property (nonatomic, strong) CHDSettingsViewModel *viewModel;
@end

@implementation CHDSettingsViewController

#pragma mark - lazy initializations
- (void) makeViews {
    [self.view addSubview:self.settingsTable];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Log Out", @"") style:UIBarButtonItemStylePlain target:self action:@selector(signOutAction:)];
}

-(void) makeConstraints {
    [self.settingsTable mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
}

-(void) makeBindings {
    [self.settingsTable shprac_liftSelector:@selector(reloadData) withSignal:RACObserve(self.viewModel, notificationSettings)];
}

- (UITableView*) settingsTable {
    if(!_settingsTable){
        _settingsTable = [UITableView new];
        _settingsTable.separatorStyle = UITableViewCellSeparatorStyleNone;
        _settingsTable.rowHeight = UITableViewAutomaticDimension;
        _settingsTable.estimatedRowHeight = 44;
        _settingsTable.backgroundView.backgroundColor = [UIColor chd_lightGreyColor];
        _settingsTable.backgroundColor = [UIColor chd_lightGreyColor];
        _settingsTable.contentInset = UIEdgeInsetsMake(35, 0, 0, 0);
        [_settingsTable registerClass:[CHDSettingsTableViewCell class] forCellReuseIdentifier:@"settingCell"];
        [_settingsTable registerClass:[CHDDescriptionTableViewCell class] forCellReuseIdentifier:@"descriptionCell"];
        _settingsTable.dataSource = self;
    }
    return _settingsTable;
}

#pragma mark - Actions

- (void) signOutAction: (id) sender {
    [[CHDAnalyticsManager sharedInstance] trackEventWithCategory:ANALYTICS_CATEGORY_SETTINGS action:ANALYTICS_ACTION_BUTTON label:ANALYTICS_LABEL_SIGNUOUT];
    [[CHDAuthenticationManager sharedInstance] signOut];
}

#pragma mark - ViewController methods
- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = NSLocalizedString(@"Settings", @"");
    self.viewModel = [CHDSettingsViewModel new];
    [self makeViews];
    [self makeConstraints];
    [self makeBindings];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[CHDAnalyticsManager sharedInstance] trackVisitToScreen:@"settings"];
}

- (void)viewWillDisappear:(BOOL)animated {
    [self.viewModel saveSettings];
    [super viewWillDisappear:animated];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if(section == 0){
        return 1;
    }
    return notificationSettingsCount;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString* cellIdentifier = @"settingCell";
    CHDNotificationSettings *settings = self.viewModel.notificationSettings;
    if( indexPath.section == 1) {
        CHDSettingsTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];

        switch ((notificationSettings) indexPath.row) {
            case eventsChanged:
                cell.titleLabel.text = NSLocalizedString(@"An invitation is received", @"");
                cell.aSwitch.on = (settings)? settings.bookingCreated : NO;
                [settings rac_liftSelector:@selector(setBookingCreated:) withSignals:[[[cell.aSwitch rac_signalForControlEvents:UIControlEventValueChanged] map:^id(UISwitch *aSwitch) {
                    return @(aSwitch.isOn);
                }] takeUntil:cell.rac_prepareForReuseSignal], nil];
                break;
            case eventsUpdated:
                cell.titleLabel.text = NSLocalizedString(@"An invitation is updated", @"");
                cell.aSwitch.on = (settings)? settings.bookingUpdated : NO;
                [settings rac_liftSelector:@selector(setBookingUpdated:) withSignals:[[[cell.aSwitch rac_signalForControlEvents:UIControlEventValueChanged] map:^id(UISwitch *aSwitch) {
                    return @(aSwitch.isOn);
                }] takeUntil:cell.rac_prepareForReuseSignal], nil];
                break;
            case eventsCancels:
                cell.titleLabel.text = NSLocalizedString(@"An invitation is cancelled", @"");
                cell.aSwitch.on = (settings)? settings.bookingCanceled : NO;
                [settings rac_liftSelector:@selector(setBookingCanceled:) withSignals:[[[cell.aSwitch rac_signalForControlEvents:UIControlEventValueChanged] map:^id(UISwitch *aSwitch) {
                    return @(aSwitch.isOn);
                }] takeUntil:cell.rac_prepareForReuseSignal], nil];
                break;
            case messagesNewAndUpdate:
                cell.titleLabel.text = NSLocalizedString(@"New messages and comments", @"");
                cell.aSwitch.on = (settings)? settings.message : NO;
                [settings rac_liftSelector:@selector(setMessage:) withSignals:[[[cell.aSwitch rac_signalForControlEvents:UIControlEventValueChanged] map:^id(UISwitch *aSwitch) {
                    return @(aSwitch.isOn);
                }] takeUntil:cell.rac_prepareForReuseSignal], nil];
                [cell borderAsLast:YES];
                break;
            default:
                break;
        }
        return cell;
    }else{
        CHDDescriptionTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"descriptionCell" forIndexPath:indexPath];

        cell.titleLabel.text = NSLocalizedString(@"Notifications", @"");
        cell.descriptionLabel.text = NSLocalizedString(@"Here you can choose when to receive notifications on your phone.", @"");
        return cell;
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

@end
