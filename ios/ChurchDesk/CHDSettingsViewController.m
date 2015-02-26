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

typedef NS_ENUM(NSUInteger, notificationSettings) {
    eventsChanged,
    eventsUpdated,
    eventsCancels,
    messagesNewAndUpdate,
    notificationSettingsCount,
};

@interface CHDSettingsViewController ()
@property (nonatomic, strong) UITableView* settingsTable;
@end

@implementation CHDSettingsViewController

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.title = NSLocalizedString(@"Settings", @"");
        [self makeViews];
        [self makeConstraints];
    }
    return self;
}

#pragma mark - lazy initializations
- (void) makeViews {
    [self.view addSubview:self.settingsTable];
}

-(void) makeConstraints {
    [self.settingsTable mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
}

- (UITableView*) settingsTable {
    if(!_settingsTable){
        _settingsTable = [UITableView new];
        _settingsTable.separatorStyle = UITableViewCellSeparatorStyleNone;
        _settingsTable.backgroundView.backgroundColor = [UIColor chd_lightGreyColor];
        _settingsTable.backgroundColor = [UIColor chd_lightGreyColor];
        _settingsTable.contentInset = UIEdgeInsetsMake(35, 0, 0, 0);
        [_settingsTable registerClass:[CHDSettingsTableViewCell class] forCellReuseIdentifier:@"settingCell"];
        [_settingsTable registerClass:[CHDDescriptionTableViewCell class] forCellReuseIdentifier:@"descriptionCell"];
        _settingsTable.dataSource = self;
    }
    return _settingsTable;
}

#pragma mark - ViewController methods
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
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

    if( indexPath.section == 1) {
        CHDSettingsTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];

        switch ((notificationSettings) indexPath.row) {
            case eventsChanged:
                cell.titleLabel.text = NSLocalizedString(@"Reserved events changes", @"");
                break;
            case eventsUpdated:
                cell.titleLabel.text = NSLocalizedString(@"Reserved events updates", @"");
                break;
            case eventsCancels:
                cell.titleLabel.text = NSLocalizedString(@"Reserved events cancels ", @"");
                break;
            case messagesNewAndUpdate:
                cell.titleLabel.text = NSLocalizedString(@"New or updates group message", @"");
                [cell borderAsLast:YES];
                break;
            default:
                break;
        }
        return cell;
    }else{
        CHDDescriptionTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"descriptionCell" forIndexPath:indexPath];

        cell.titleLabel.text = @"Notifications";
        cell.descriptionLabel.text = @"Here you can change all settings regarding notifications on your phone.";
        return cell;
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
