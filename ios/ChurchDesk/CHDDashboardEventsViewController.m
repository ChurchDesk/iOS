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
#import "CHDNewMessageViewController.h"

@interface CHDDashboardEventsViewController ()

@property (nonatomic, retain) UITableView* eventTable;
@property (nonatomic, strong) CHDExpandableButtonView *actionButtonView;
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

        //Setup target action
        //[self.actionButtonView.addMessageButton addTarget:self action:@selector(newMessageShow) forControlEvents:UIControlEventTouchUpInside];
        [self.actionButtonView.addMessageButton addTarget:self action:@selector(newMessageShow) forControlEvents:UIControlEventTouchUpInside];
    }
    return self;
}

#pragma mark - setup views

-(void) makeViews {
    [self.view addSubview:self.eventTable];
    [self.view addSubview:self.actionButtonView];
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
}

- (void) newMessageShow {
    CHDNewMessageViewController* newMessageViewController = [CHDNewMessageViewController new];
    UINavigationController *navigationVC = [[UINavigationController new] initWithRootViewController:newMessageViewController];
    [self presentViewController:navigationVC animated:YES completion:nil];
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
