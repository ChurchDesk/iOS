//
//  CHDSelectParishForPeopleViewController.m
//  ChurchDesk
//
//  Created by Chirag Sharma on 18/03/16.
//  Copyright © 2016 Shape A/S. All rights reserved.
//

#import "CHDSelectParishForPeopleViewController.h"
#import "UINavigationController+ChurchDesk.h"
#import "CHDPeopleTabBarController.h"
#import "CHDSelectorTableViewCell.h"
#import "CHDSite.h"

@interface CHDSelectParishForPeopleViewController () <UITableViewDelegate, UITableViewDataSource>
@property (nonatomic, retain) UITableView* parishtable;
@end

@implementation CHDSelectParishForPeopleViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view setBackgroundColor:[UIColor whiteColor]];
    [self makeViews];
    [self makeConstraints];
    self.title = NSLocalizedString(@"Select Parish", @"");
    // Do any additional setup after loading the view.
}

-(void)viewWillAppear:(BOOL)animated{
    
}

-(void) makeViews {
    [self.view addSubview:self.parishtable];
}

-(void) makeConstraints {
    UIView* superview = self.view;
    [self.parishtable mas_makeConstraints:^(MASConstraintMaker *make){
        make.edges.equalTo(superview);
    }];
    [self.parishtable mas_makeConstraints:^(MASConstraintMaker *make){
        make.right.equalTo(superview);
        make.bottom.equalTo(superview);
    }];
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    CHDSite * site = [_organizations objectAtIndex:indexPath.row];
    [[NSUserDefaults standardUserDefaults] setValue:site.siteId forKey:kselectedOrganizationIdforPeople];
    CHDPeopleTabBarController *peopleTabBar = [CHDPeopleTabBarController peopleTabBarViewController];
    [self.navigationController pushViewController:peopleTabBar animated:YES];
    
}


#pragma mark - UITableViewDataSource

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString* cellIdentifier = @"parishCell";
    CHDSite * site = [_organizations objectAtIndex:indexPath.row];
    CHDSelectorTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    cell.titleLabel.text = site.name;
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    return cell;
}



- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [_organizations count];
}

#pragma mark - Lazy Initialization

-(UITableView*)parishtable {
    if(!_parishtable){
        _parishtable = [[UITableView alloc] init];
        _parishtable.separatorStyle = UITableViewCellSeparatorStyleNone;
        _parishtable.backgroundView.backgroundColor = [UIColor chd_lightGreyColor];
        _parishtable.backgroundColor = [UIColor chd_lightGreyColor];
        [_parishtable registerClass:[CHDSelectorTableViewCell class] forCellReuseIdentifier:@"parishCell"];
        _parishtable.dataSource = self;
        _parishtable.delegate = self;
        _parishtable.allowsSelection = YES;
    }
    return _parishtable;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
