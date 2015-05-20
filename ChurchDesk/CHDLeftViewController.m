//
//  CHDLeftViewController.m
//  ChurchDesk
//
//  Created by Jakob Vinther-Larsen on 17/02/15.
//  Copyright (c) 2015 Shape A/S. All rights reserved.
//

#import "CHDLeftViewController.h"
#import "CHDLeftMenuTableViewCell.h"
#import "CHDMenuItem.h"
#import "SHPSideMenu.h"
#import "CHDLeftMenuViewModel.h"
#import "CHDUser.h"
#import "UIImageView+Haneke.h"
#import "intercom.h"

@interface CHDLeftViewController ()
@property (nonatomic, strong) UITableView* menuTable;
@property (nonatomic, strong) UILabel* userNameLabel;
@property (nonatomic, strong) UIImageView* userImageView;

@property (nonatomic, strong) CHDLeftMenuViewModel *viewModel;
@end

@implementation CHDLeftViewController

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self makeViews];
        [self makeConstraints];
    }
    return self;
}

- (instancetype)initWithMenuItems:(NSArray *)items {
    self.menuItems = items;
    self = [super init];
    if (self) {
        [self makeViews];
        [self makeConstraints];
        [self makeBindings];
    }
    return self;
}


- (void)viewDidLoad {
    [super viewDidLoad];

    self.viewModel = [CHDLeftMenuViewModel new];

    // Do any additional setup after loading the view.
    UIColor *color = [UIColor chd_menuDarkBlue];
    self.view.backgroundColor = color;
    if(self.menuItems.count > 0) {
        [self.menuTable selectRowAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:0] animated:NO scrollPosition:UITableViewScrollPositionNone];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -Actions

- (void)setSelectedViewController:(UIViewController *)viewController {
    for(CHDMenuItem *item in self.menuItems){
        if([item.viewController isEqual:viewController]){
            NSUInteger index = [self.menuItems indexOfObject:item];
            if([self.menuTable indexPathForSelectedRow] != nil) {
                [self tableView:self.menuTable cellForRowAtIndexPath:[self.menuTable indexPathForSelectedRow]].selected = NO;
            }
            [self tableView:self.menuTable cellForRowAtIndexPath:[NSIndexPath indexPathForItem:index inSection:0]].selected = YES;
            return;
        }
    }
}


#pragma mark -setup
-(void) makeViews{
    [self.view addSubview:self.menuTable];
    [self.view addSubview:self.userNameLabel];
    [self.view addSubview:self.userImageView];
}

-(void) makeConstraints {
    UIView *containerView = self.view;
    [self.menuTable mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.equalTo(containerView);
        make.top.equalTo(containerView).with.offset(215);
    }];

    [self.userNameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(containerView).with.offset(160);
        make.centerX.equalTo(containerView);
    }];

    [self.userImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(containerView).with.offset(40);
        make.centerX.equalTo(containerView);
        make.width.height.equalTo(@104);
    }];
}

-(void) makeBindings {
    RACSignal *userSignal = RACObserve(self.viewModel, user);

    RAC(self.userNameLabel, text) = [userSignal map:^id(CHDUser *user) {
            if (user.name) {
                [Intercom updateUserWithAttributes:@{ @"name" : user.name}];
            }
            return user.name;
    }];
    
    [self rac_liftSelector:@selector(userImageWithUrl:) withSignals:[userSignal map:^id(CHDUser *user) {
        return user.pictureURL;
    }], nil];
}

#pragma mark -lazy initialisation
-(void) userImageWithUrl: (NSURL*) URL{
    if(URL) {
        [self.userImageView layoutIfNeeded];
        [self.userImageView hnk_setImageFromURL:URL placeholder:nil];
    }
}

-(UITableView *)menuTable {
    if (!_menuTable) {
        _menuTable = [[UITableView alloc] init];
        _menuTable.separatorStyle = UITableViewCellSeparatorStyleNone;
        _menuTable.backgroundView.backgroundColor = [UIColor chd_menuLightBlue];
        _menuTable.backgroundColor = [UIColor chd_menuLightBlue];

        _menuTable.rowHeight = 48;

        [_menuTable registerClass:[CHDLeftMenuTableViewCell class] forCellReuseIdentifier:@"menuCell"];

        _menuTable.dataSource = self;
        _menuTable.delegate = self;
        _menuTable.allowsSelection = YES;
        _menuTable.allowsMultipleSelection = NO;
    }
    return _menuTable;
}

-(UILabel *)userNameLabel{
    if(!_userNameLabel){
        _userNameLabel = [UILabel new];
        _userNameLabel.font = [UIFont chd_fontWithFontWeight:CHDFontWeightRegular size:15];
        _userNameLabel.textColor = [UIColor whiteColor];
    }
    return _userNameLabel;
}

-(UIImageView*)userImageView{
    if(!_userImageView){
        _userImageView = [UIImageView new];
        _userImageView.layer.cornerRadius = 52;
        _userImageView.layer.backgroundColor = [UIColor chd_lightGreyColor].CGColor;
        _userImageView.layer.masksToBounds = YES;
        _userImageView.contentMode = UIViewContentModeScaleAspectFill;
    }
    return _userImageView;
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.menuItems.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    //Get the item
    CHDMenuItem* item = self.menuItems[indexPath.row];

    static NSString* cellIdentifier = @"menuCell";

    CHDLeftMenuTableViewCell *cell = (CHDLeftMenuTableViewCell*)[tableView cellForRowAtIndexPath:indexPath]?: [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    cell.titleLabel.text = item.title;
    cell.thumbnailLeft.image = [item.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];

    return cell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

#pragma mark - UITableViewDelegate
- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if([self.menuTable indexPathForSelectedRow] != nil) {
        [self tableView:self.menuTable cellForRowAtIndexPath:[self.menuTable indexPathForSelectedRow]].selected = NO;
    }
    return indexPath;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self tableView:self.menuTable cellForRowAtIndexPath:indexPath].selected = YES;
    //Get the menu item
    CHDMenuItem* item = self.menuItems[indexPath.row];

    //Set the selected viewController
    if ([item.title isEqualToString:NSLocalizedString(@"Help and Support", @"")]) {
        [Intercom presentConversationList];
    }
    else{
    [self.shp_sideMenuController setSelectedViewController:item.viewController];
    }
    [self.shp_sideMenuController close];
        
}

@end
