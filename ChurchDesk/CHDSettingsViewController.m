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
#import <SHPNetworking/SHPAPIManager+ReactiveExtension.h>

typedef NS_ENUM(NSUInteger, notificationSettings) {
    description,
    eventsChanged,
    eventsUpdated,
    eventsCancels,
    messagesNewAndUpdate,
    notificationSettingsCount,
};

@interface CHDSettingsViewController () <UIAlertViewDelegate>
@property (nonatomic, strong) UITableView* settingsTable;
@property (nonatomic, strong) CHDSettingsViewModel *viewModel;
@property (nonatomic) int numberOfSections;
@end
@import LocalAuthentication;
@implementation CHDSettingsViewController

#pragma mark - lazy initializations
- (void) makeViews {
    LAContext *context = [[LAContext alloc] init];
    NSError *error;
    BOOL success;
    success = [context canEvaluatePolicy: LAPolicyDeviceOwnerAuthenticationWithBiometrics error:&error];
    if (success) {
        _numberOfSections = 2;
    }
    else {
        _numberOfSections = 1;
    }
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
        _settingsTable = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, 0, 0) style:UITableViewStyleGrouped];
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
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:[NSLocalizedString(@"Log Out", @"") stringByAppendingString:@"?"] message:nil delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel", @"") otherButtonTitles:@"Ok", nil];
    [alertView show];
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
    //[self.viewModel saveSettings];
    [super viewWillDisappear:animated];
}

#pragma mark -AlertView Delegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if(buttonIndex > 0) {
        [Heap track:@"Logged out"];
        [[CHDAnalyticsManager sharedInstance] trackEventWithCategory:ANALYTICS_CATEGORY_SETTINGS action:ANALYTICS_ACTION_BUTTON label:ANALYTICS_LABEL_SIGNUOUT];
        [[CHDAuthenticationManager sharedInstance] signOut];
    }
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if(section == (_numberOfSections - 1)){
        return notificationSettingsCount;
    }
    else return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString* cellIdentifier = @"settingCell";
    CHDNotificationSettings *settings = self.viewModel.notificationSettings;
    if( indexPath.section == (_numberOfSections - 1)) {
        if (indexPath.row == 0) {
            CHDDescriptionTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"descriptionCell" forIndexPath:indexPath];
            cell.titleLabel.text = NSLocalizedString(@"Notifications", @"");
            cell.descriptionLabel.text = NSLocalizedString(@"Here you can choose when to receive notifications on your phone.", @"");
            return cell;
        } else{
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
        }
    }
    else{
        CHDSettingsTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
        cell.titleLabel.text = NSLocalizedString(@"Log in with fingerprint", @"");
        BOOL loginWithTouchIdEnabled = [[NSUserDefaults standardUserDefaults] boolForKey:kloginwithTouchIdEnabled];
        cell.aSwitch.on = (loginWithTouchIdEnabled)? loginWithTouchIdEnabled : NO;
        [self rac_liftSelector:@selector(setTouchIdEnabled:) withSignals:[[[cell.aSwitch rac_signalForControlEvents:UIControlEventValueChanged] map:^id(UISwitch *aSwitch) {
            return @(aSwitch.isOn);
        }] takeUntil:cell.rac_prepareForReuseSignal], nil];
        return cell;
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return _numberOfSections;
}

-(void)setTouchIdEnabled :(BOOL)enabled{
    if (enabled) {
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"" message:NSLocalizedString(@"Please enter your password to activate login with the fingerprint.", @"")preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *ok = [UIAlertAction actionWithTitle: NSLocalizedString(@"OK", @"") style: UIAlertActionStyleDefault
                                                       handler:^(UIAlertAction *action){
                                                           UITextField *alertTextField = alert.textFields.firstObject;
                                                           NSString *email = [CHDAuthenticationManager sharedInstance].userID;
                                                           NSString *userPassword = alertTextField.text;
                                                           [self loginWithEmail:email password:userPassword];
                                                       }];
            UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel
                                                           handler: ^(UIAlertAction *action){
                                                               [self.settingsTable reloadData];
                                                           }];
            [alert addTextFieldWithConfigurationHandler:^(UITextField *textField) {
                textField.placeholder = @"Password";
                textField.secureTextEntry = YES;
            }];
            [alert addAction:ok];
            [alert addAction:cancel];
            [self presentViewController:alert animated:YES completion:nil];
    }
    else {
            [[NSUserDefaults standardUserDefaults] setBool:enabled forKey:kloginwithTouchIdEnabled];
        }
    }

-(void)loginWithEmail: (NSString *)email password:(NSString *)password{
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:kloginwithTouchIdEnabled];
    [[self.viewModel loginWithUserName:email password:password] subscribeError:^(NSError *error) {
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:kloginwithTouchIdEnabled];
        [self.settingsTable reloadData];
        SHPHTTPResponse *response = error.userInfo[SHPAPIManagerReactiveExtensionErrorResponseKey];
        NSLog(@"code %ld", (long)response.statusCode);
        if (response.statusCode == 401) {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", @"") message:NSLocalizedString(@"Wrong password", @"Message shown on wrong username password") delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", @"") otherButtonTitles:nil];
            [alertView show];
        }
        else if (response.statusCode == 402){
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Payment required", @"") message:NSLocalizedString(@"Please contact our sales team for more details", @"Message shown when payment is required") delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", @"") otherButtonTitles:nil];
            [alertView show];
        }
        else if (response.statusCode == 426){
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Blocked", @"") message:NSLocalizedString(@"Please reset your password", @"Message shown when the user is blocked") delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", @"") otherButtonTitles:nil];
            [alertView show];
        }
    }];
}
@end
