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
@property(nonatomic, retain) UIBarButtonItem* mainMenu;
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
    self.navigationItem.leftBarButtonItem = self.mainMenu;
    [self.view addSubview:self.messagesTable];
}

-(void) makeConstraints {
    [self.messagesTable mas_makeConstraints:^(MASConstraintMaker *make){
        make.edges.equalTo(self.view);
    }];
}

-(UIBarButtonItem*) mainMenu {
    if(!_mainMenu){
        _mainMenu = [[UIBarButtonItem new] initWithImage:kImgBurgerMenu style:UIBarButtonItemStylePlain target:self action:@selector(touched)];
    }
    return _mainMenu;
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
    UIColor *color = [UIColor purpleColor];
    self.view.backgroundColor = color;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)touched {
    NSLog(@"Touched bar button");
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
