//
//  CHDDashboardMessagesViewController.m
//  ChurchDesk
//
//  Created by Jakob Vinther-Larsen on 17/02/15.
//  Copyright (c) 2015 Shape A/S. All rights reserved.
//

#import "CHDDashboardMessagesViewController.h"
#import "CHDMessagesTableViewCell.h"

@interface CHDDashboardMessagesViewController ()
@property(nonatomic, retain) UITableView* messagesTable;
@end

@implementation CHDDashboardMessagesViewController

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
    [self.view addSubview:self.messagesTable];
}

-(void) makeConstraints {
    [self.messagesTable mas_makeConstraints:^(MASConstraintMaker *make){
        make.edges.equalTo(self.view);
    }];
}

-(UITableView *) messagesTable {
    if (!_messagesTable) {
        _messagesTable = [[UITableView alloc] init];
        _messagesTable.separatorStyle = UITableViewCellSeparatorStyleNone;
        _messagesTable.backgroundView.backgroundColor = [UIColor chd_lightGreyColor];
        _messagesTable.backgroundColor = [UIColor chd_lightGreyColor];

        _messagesTable.rowHeight = 85;

        [_messagesTable registerClass:[CHDMessagesTableViewCell class] forCellReuseIdentifier:@"messagesCell"];

        _messagesTable.dataSource = self;
    }
    return _messagesTable;
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

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)leftBarButtonTouchHandle {
    [self.shp_sideMenuController toggleLeft];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    static NSString* cellIdentifier = @"messagesCell";

    CHDMessagesTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    cell.parishLabel.text = @"The Parish";
    cell.receivedTimeLabel.text = @"21 min ago";
    cell.groupLabel.text = @"Choir";
    cell.authorLabel.text = @"Philip Waters";
    cell.contentLabel.text = @"Re: Summerparty 2015";
    cell.receivedDot.dotColor = [UIColor chd_redColor];

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
