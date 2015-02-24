//
//  CHDDashboardInvitationsViewController.m
//  ChurchDesk
//
//  Created by Jakob Vinther-Larsen on 17/02/15.
//  Copyright (c) 2015 Shape A/S. All rights reserved.
//

#import "CHDDashboardInvitationsViewController.h"
#import "CHDInvitationsTableViewCell.h"

@interface CHDDashboardInvitationsViewController ()
@property(nonatomic, retain) UITableView*inviteTable;
@end

@implementation CHDDashboardInvitationsViewController

- (instancetype)init
{
  self = [super init];
  if (self) {
    self.title = NSLocalizedString(@"Dashboard", @"");

      [self makeViews];
      [self makeConstraints];
  }
  return self;
}

#pragma mark - setup views
-(void) makeViews {
    [self.view addSubview:self.inviteTable];
}

-(void) makeConstraints {
    UIView* superview = self.view;
    [self.inviteTable mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(superview);
    }];
}

-(UITableView *)inviteTable {
    if (!_inviteTable) {
        _inviteTable = [[UITableView alloc] init];
        _inviteTable.separatorStyle = UITableViewCellSeparatorStyleNone;
        _inviteTable.backgroundView.backgroundColor = [UIColor chd_lightGreyColor];
        _inviteTable.backgroundColor = [UIColor chd_lightGreyColor];

        _inviteTable.rowHeight = 106;

        [_inviteTable registerClass:[CHDInvitationsTableViewCell class] forCellReuseIdentifier:@"invitationCell"];

        _inviteTable.dataSource = self;
    }
    return _inviteTable;
}

#pragma mark - View methods

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    //Create the burgerbar menu item, if there's a reference to the sidemenu, and we havn't done it before
    if(self.shp_sideMenuController != nil && self.navigationItem.leftBarButtonItem == nil){
        self.navigationItem.leftBarButtonItem = [UIBarButtonItem chd_burgerWithTarget:self action:@selector(leftBarButtonTouchHandle)];
    }
}

- (void)leftBarButtonTouchHandle {
    [self.shp_sideMenuController toggleLeft];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    static NSString* cellIdentifier = @"invitationCell";

    CHDInvitationsTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    cell.titleLabel.text = @"Title";
    cell.locationLabel.text = @"Vesterbro kirke";
    cell.parishLabel.text = @"The Parish";
    cell.invitedByLabel.text = @"Invited by";
    cell.eventTimeLabel.text = @"Saturday 30 sep, 12:00 - 13:00";
    cell.receivedTimeLabel.text = @"21 min ago";

    //Setup events for the buttons
    [cell.acceptButton addTarget:self action:@selector(accepted) forControlEvents:UIControlEventTouchUpInside];

    if(indexPath.item % 2 == 1) {
        [cell.leftBorder setBackgroundColor:[UIColor chd_categoryOrangeColor]];
    }else{
        [cell.leftBorder setBackgroundColor:[UIColor chd_categoryPurpleColor]];
    }

    return cell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

-(void) accepted {
    NSLog(@"Accepted");
}

@end
