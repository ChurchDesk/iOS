//
//  CHDDashboardEventsViewController.m
//  ChurchDesk
//
//  Created by Jakob Vinther-Larsen on 17/02/15.
//  Copyright (c) 2015 Shape A/S. All rights reserved.
//

#import "CHDDashboardEventsViewController.h"
#import "CHDTableViewCell.h"
#import "CHDEventTableViewCell.h"
#import "CHDExpandableButtonView.h"

@interface CHDDashboardEventsViewController ()

@property (nonatomic, retain) UITableView* eventTable;
@property (nonatomic, strong) CHDExpandableButtonView *actionButtonView;
@property(nonatomic, retain) UIBarButtonItem* mainMenu;

@end

@implementation CHDDashboardEventsViewController

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.title = NSLocalizedString(@"Dashboard", @"");
        self.edgesForExtendedLayout = UIRectEdgeNone;

        [self makeViews];
        [self makeConstraints];
    }
    return self;
}

#pragma mark - setup views

-(void) makeViews {
    [self.view addSubview:self.eventTable];
    [self.view addSubview:self.actionButtonView];
    self.navigationItem.leftBarButtonItem = self.mainMenu;
}

-(void) makeConstraints {
    UIView* superview = self.view;
    [self.eventTable mas_makeConstraints:^(MASConstraintMaker *make){
        make.edges.equalTo(superview);
    }];
    
    [self.actionButtonView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(superview);
        make.bottom.equalTo(superview).offset(-5);
    }];
}

#pragma mark - View methods
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    UIColor *color = [UIColor blueColor];
    self.view.backgroundColor = color;
}

- (void)touched {
    NSLog(@"Touched bar button");
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    static NSString* cellIdentifier = @"dashboardCell";

    CHDEventTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    //cell.textLabel.text = cellTitle;
    cell.titleLabel.text = @"Title";
    cell.locationLabel.text = @"Location";
    cell.parishLabel.text = @"The Parish";
    cell.dateTimeLabel.text = @"Today";
    //cell.

    if(indexPath.item % 2 == 1) {
        [cell.leftBorder setBackgroundColor:[UIColor chd_categoryBlueColor]];
    }else{
        [cell.leftBorder setBackgroundColor:[UIColor chd_categoryRedColor]];
    }

    return cell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

#pragma mark - Lazy Initialization

-(UIBarButtonItem*) mainMenu {
    if(!_mainMenu){
        _mainMenu = [[UIBarButtonItem new] initWithImage:kImgBurgerMenu style:UIBarButtonItemStylePlain target:self action:@selector(touched)];
    }
    return _mainMenu;
}

-(UITableView*)eventTable {
    if(!_eventTable){
        _eventTable = [[UITableView alloc] init];
        _eventTable.separatorStyle = UITableViewCellSeparatorStyleNone;
        _eventTable.backgroundView.backgroundColor = [UIColor chd_lightGreyColor];
        _eventTable.backgroundColor = [UIColor chd_lightGreyColor];
        _eventTable.rowHeight = 65;
        [_eventTable registerClass:[CHDEventTableViewCell class] forCellReuseIdentifier:@"dashboardCell"];
        _eventTable.dataSource = self;
    }
    return _eventTable;
}


- (CHDExpandableButtonView *)actionButtonView {
    if (!_actionButtonView) {
        _actionButtonView = [CHDExpandableButtonView new];
    }
    return _actionButtonView;
}

@end
