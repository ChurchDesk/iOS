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

@property (nonatomic, strong) UITableView* eventTable;
@property (nonatomic, strong) CHDExpandableButtonView *actionButtonView;

@end

@implementation CHDDashboardEventsViewController

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.title = NSLocalizedString(@"Dashboard", @"");
        self.edgesForExtendedLayout = UIRectEdgeNone;

        UIBarButtonItem *burgerMenu = [[UIBarButtonItem new] initWithImage:kImgBurgerMenu style:UIBarButtonItemStylePlain target:self action:@selector(touched)];
        self.navigationItem.leftBarButtonItem = burgerMenu;

        self.eventTable = [[UITableView alloc] init];
        self.eventTable.separatorStyle = UITableViewCellSeparatorStyleNone;
        self.eventTable.backgroundView.backgroundColor = [UIColor chd_lightGreyColor];
        self.eventTable.backgroundColor = [UIColor chd_lightGreyColor];
        self.eventTable.rowHeight = 65;
        [self.eventTable registerClass:[CHDEventTableViewCell class] forCellReuseIdentifier:@"dashboardCell"];
        self.eventTable.dataSource = self;
        [self.view addSubview:self.eventTable];

        [self.view addSubview:self.actionButtonView];
        
        UIView* superview = self.view;

        [self.eventTable mas_makeConstraints:^(MASConstraintMaker *make){
            make.edges.equalTo(superview);
        }];
        
        [self.actionButtonView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(self.view);
            make.bottom.equalTo(self.view).offset(-5);
        }];
    }
    return self;
}

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

- (CHDExpandableButtonView *)actionButtonView {
    if (!_actionButtonView) {
        _actionButtonView = [CHDExpandableButtonView new];
    }
    return _actionButtonView;
}

@end
