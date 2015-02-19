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
@property(nonatomic, retain) UIBarButtonItem* mainMenu;
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
    self.navigationItem.leftBarButtonItem = self.mainMenu;
}

-(void) makeConstraints {
    UIView* superview = self.view;
    [self.inviteTable mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(superview);
    }];
}

-(UIBarButtonItem*) mainMenu {
    if(!_mainMenu){
        _mainMenu = [[UIBarButtonItem new] initWithImage:kImgBurgerMenu style:UIBarButtonItemStylePlain target:self action:@selector(touched)];
    }
    return _mainMenu;
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

    UIColor *color = [UIColor greenColor];
    self.view.backgroundColor = color;
}

- (void) viewWillAppear:(BOOL)animated{
  [super viewWillAppear:animated];
}

- (void)touched {
  NSLog(@"Touched bar button");
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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
