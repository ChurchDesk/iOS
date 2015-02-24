//
//  CHDDashboardInvitationsViewController.m
//  ChurchDesk
//
//  Created by Jakob Vinther-Larsen on 17/02/15.
//  Copyright (c) 2015 Shape A/S. All rights reserved.
//

#import "CHDDashboardInvitationsViewController.h"
#import "CHDInvitationsTableViewCell.h"
#import "CHDDashboardInvitationsViewModel.h"
#import "CHDInvitation.h"

@interface CHDDashboardInvitationsViewController ()

@property(nonatomic, strong) CHDDashboardInvitationsViewModel *viewModel;
@property(nonatomic, retain) UITableView*inviteTable;

@end

@implementation CHDDashboardInvitationsViewController

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.title = NSLocalizedString(@"Dashboard", @"");
        self.viewModel = [CHDDashboardInvitationsViewModel new];
    }
    return self;
}
#pragma mark - View methods

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self makeViews];
    [self makeConstraints];
    [self setupBindings];
    
    if (self.shp_sideMenuController != nil && self.navigationItem.leftBarButtonItem == nil){
        self.navigationItem.leftBarButtonItem = [UIBarButtonItem chd_burgerWithTarget:self action:@selector(leftBarButtonTouchHandle)];
    }
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

- (void) setupBindings {
    [self.inviteTable shprac_liftSelector:@selector(reloadData) withSignal:RACObserve(self.viewModel, invitations)];
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

- (void)leftBarButtonTouchHandle {
    [self.shp_sideMenuController toggleLeft];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.viewModel.invitations.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    static NSString* cellIdentifier = @"invitationCell";

    CHDInvitationsTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    
    CHDInvitation *invitation = self.viewModel.invitations[indexPath.row];
    
    cell.titleLabel.text = invitation.title;
    cell.locationLabel.text = invitation.location;
    cell.parishLabel.text = @"The Parish";
    cell.invitedByLabel.text = @"Invited by";
    cell.eventTimeLabel.text = [invitation.startDate description];
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
