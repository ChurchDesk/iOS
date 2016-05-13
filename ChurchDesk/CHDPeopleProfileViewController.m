//
//  CHDPeopleProfileViewController.m
//  ChurchDesk
//
//  Created by Chirag Sharma on 25/04/16.
//  Copyright © 2016 Shape A/S. All rights reserved.
//

#import "CHDPeopleProfileViewController.h"
#import "UIImageView+Haneke.h"
#import "CHDEventTextValueTableViewCell.h"
#import "CHDCreateMessageMailViewController.h"

@interface CHDPeopleProfileViewController () <UITableViewDelegate, UITableViewDataSource>
@property (nonatomic, strong) UITableView* profileTable;
@property (nonatomic, strong) UILabel* userNameLabel;
@property (nonatomic, strong) UIImageView* userImageView;
@property (nonatomic, strong) UIButton* callButton;
@property (nonatomic, strong) UIButton* sendMessageButton;
@property (nonatomic, strong) NSDateFormatter *dateFormatter;
@property (nonatomic, strong) NSMutableArray *peopleAttributeValues;
@end

@implementation CHDPeopleProfileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self makeViews];
    [self makeConstraints];
    [self makeBindings];
    // Do any additional setup after loading the view.
}

#pragma mark -setup
-(void) makeViews{
    [self.view setBackgroundColor:[UIColor chd_blueColor]];
    [self.navigationController.navigationBar setBackgroundImage:[UIImage new]
                       forBarPosition:UIBarPositionAny
                           barMetrics:UIBarMetricsDefault];
    [self.navigationController.navigationBar setShadowImage:[UIImage new]];

    [self.view addSubview:self.menuTable];
    [self.view addSubview:self.userNameLabel];
    [self.view addSubview:self.userImageView];
    [self.view addSubview:self.callButton];
    if (([_people.contact objectForKey:@"phone"] == (id)[NSNull null]) || [[_people.contact objectForKey:@"phone"] length] == 0 ) {
        self.callButton.enabled = false;
    }
    [self.view addSubview:self.sendMessageButton];
}

-(void) makeConstraints {
    UIView *containerView = self.view;
    [self.menuTable mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.equalTo(containerView);
        make.top.equalTo(containerView).with.offset(200);
    }];
    
    [self.userNameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(containerView).with.offset(120);
        make.centerX.equalTo(containerView);
    }];
    
    [self.userImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(containerView).with.offset(2);
        make.centerX.equalTo(containerView);
        make.width.height.equalTo(@104);
    }];
    
    [self.callButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(containerView).offset(10);
        make.top.equalTo(containerView).with.offset(160);
    }];
    
    [self.sendMessageButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(containerView).offset(-10);
        make.top.equalTo(containerView).with.offset(160);
    }];
}

-(void) makeBindings {
    self.userNameLabel.text = _people.fullName;
    self.title = NSLocalizedString(@"Profile", @"");
//    RAC(self.userNameLabel, text) = [userSignal map:^id(CHDUser *user) {
//        CHDSite *organization = [user.sites objectAtIndex:0];
//        NSData *encodedUser = [NSKeyedArchiver archivedDataWithRootObject:user];
//        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
//        [defaults setObject:encodedUser forKey:@"currentUser"];
//        [defaults setValue:user.userId forKey:@"userId"];
//        [defaults setValue:organization.siteId forKey:@"organizationId"];
//        return user.name;
//    }];
//    [self rac_liftSelector:@selector(userImageWithUrl:) withSignals:[userSignal map:^id(CHDUser *user) {
//        return user.pictureURL;
//    }], nil];
    if ([_people.picture valueForKey:@"url"] != (id)[NSNull null]) {
        [self userImageWithUrl:[NSURL URLWithString:[_people.picture valueForKey:@"url"]]];
    }
    
}

#pragma mark -lazy initialisation
-(void) userImageWithUrl: (NSURL*) URL{
    if(URL) {
        [self.userImageView layoutIfNeeded];
        [self.userImageView hnk_setImageFromURL:URL placeholder:nil];
    }
}

-(UITableView *)menuTable {
    if (!_profileTable) {
        _profileTable = [[UITableView alloc] init];
        _profileTable.separatorStyle = UITableViewCellSeparatorStyleNone;
        _profileTable.backgroundView.backgroundColor = [UIColor chd_menuLightBlue];
        _profileTable.backgroundColor = [UIColor whiteColor];
        _profileTable.rowHeight = 48;
        
        [_profileTable registerClass:[CHDEventTextValueTableViewCell class] forCellReuseIdentifier:@"profileCell"];
        
        _profileTable.dataSource = self;
        _profileTable.delegate = self;
        _profileTable.allowsSelection = NO;
        _profileTable.allowsMultipleSelection = NO;
    }
    return _profileTable;
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

- (UIButton *)callButton {
    if (!_callButton) {
        _callButton = [UIButton buttonWithType:UIButtonTypeCustom];
//        [_callButton setImage:kImgSearchPassive forState:UIControlStateNormal];
//        [_callButton setImage:kImgSearchActive forState:UIControlStateHighlighted];
//        [_callButton setImage:[kImgSearchPassive imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateHighlighted];
        //_callButton.titleLabel.text = NSLocalizedString(@"Call", @"");
        _callButton.titleLabel.textColor = [UIColor whiteColor];
        [_callButton setTitle:NSLocalizedString(@"Call", @"") forState:UIControlStateNormal];
        [_callButton setTitle:NSLocalizedString(@"Call", @"") forState:UIControlStateHighlighted];
        [_callButton setTitleColor:[UIColor darkGrayColor] forState:UIControlStateDisabled];
        [_callButton.titleLabel setFont:[UIFont chd_fontWithFontWeight:CHDFontWeightRegular size:15]];
        [_callButton addTarget:self action:@selector(callAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _callButton;
}

- (UIButton *)sendMessageButton {
    if (!_sendMessageButton) {
        _sendMessageButton = [UIButton buttonWithType:UIButtonTypeCustom];
        //        [_callButton setImage:kImgSearchPassive forState:UIControlStateNormal];
        //        [_callButton setImage:kImgSearchActive forState:UIControlStateHighlighted];
        //        [_callButton setImage:[kImgSearchPassive imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateHighlighted];
        [_sendMessageButton setTitle:NSLocalizedString(@"Send message", @"") forState:UIControlStateNormal];
        [_sendMessageButton setTitle:NSLocalizedString(@"Send message", @"") forState:UIControlStateHighlighted];
        [_sendMessageButton.titleLabel setFont:[UIFont chd_fontWithFontWeight:CHDFontWeightRegular size:15]];
        [_sendMessageButton addTarget:self action:@selector(sendMessageAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _sendMessageButton;
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self peopleAttributes].count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    //Get the item
    
    static NSString* cellIdentifier = @"profileCell";
    CHDEventTextValueTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    cell.backgroundColor = [UIColor whiteColor];
    cell.titleLabel.text = [[self peopleAttributes] objectAtIndex:indexPath.row];
    cell.valueLabel.text = [_peopleAttributeValues objectAtIndex:indexPath.row];
    return cell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma - Actions

- (void)callAction: (id) sender {
    NSString *phoneNo = [_people.contact objectForKey:@"phone"];
    NSURL *phoneUrl = [NSURL URLWithString:[NSString  stringWithFormat:@"telprompt:%@",phoneNo]];
    
    if ([[UIApplication sharedApplication] canOpenURL:phoneUrl]) {
        [[UIApplication sharedApplication] openURL:phoneUrl];
    } else
    {
        UIAlertView *calert = [[UIAlertView alloc]initWithTitle:@"Alert" message:@"Your device doesn't support voice calls." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
        [calert show];
    }}

-(void)sendMessageAction: (id) sender {
    CHDCreateMessageMailViewController* newMessageViewController = [CHDCreateMessageMailViewController new];
    newMessageViewController.selectedPeopleArray = [[NSArray alloc] initWithObjects:_people, nil];
    newMessageViewController.currentUser = _currentUser;
    newMessageViewController.organizationId = _organizationId;
    UINavigationController *navigationVC = [[UINavigationController new] initWithRootViewController:newMessageViewController];
    [Heap track:@"Create new people message"];
    [self presentViewController:navigationVC animated:YES completion:nil];
}

#pragma - Data to display

-(NSArray *)peopleAttributes {
    NSMutableArray *temporaryArray = [[NSMutableArray alloc] init];
    _peopleAttributeValues = [[NSMutableArray alloc] init];
    if (_people.email != (id)[NSNull null] && _people.email.length != 0 ) {
        [temporaryArray addObject:NSLocalizedString(@"E-mail", @"")];
        [_peopleAttributeValues addObject:_people.email];
    }
    if ([_people.contact objectForKey:@"phone"] != (id)[NSNull null] && [[_people.contact objectForKey:@"phone"] length] != 0 ) {
        [temporaryArray addObject:NSLocalizedString(@"Phone Number", @"")];
        [_peopleAttributeValues addObject:[_people.contact objectForKey:@"phone"]];
    }
    if (_people.birthday != NULL) {
        [temporaryArray addObject:NSLocalizedString(@"Birthday", @"")];
        [_peopleAttributeValues addObject:[self.dateFormatter stringFromDate:_people.birthday]];
    }
    if (_people.registered != NULL) {
        [temporaryArray addObject:NSLocalizedString(@"Registered", @"")];
        [_peopleAttributeValues addObject:[self.dateFormatter stringFromDate:_people.registered]];
    }
    if (_people.gender != (id)[NSNull null] && _people.gender.length != 0) {
        [temporaryArray addObject:NSLocalizedString(@"Gender", @"")];
        [_peopleAttributeValues addObject:_people.gender];
    }
    if ([_people.contact objectForKey:@"street"] != (id)[NSNull null] && [[_people.contact objectForKey:@"street"] length] != 0 ) {
        [temporaryArray addObject:NSLocalizedString(@"Address", @"")];
        [_peopleAttributeValues addObject:[_people.contact objectForKey:@"street"]];
    }
    if ([_people.contact objectForKey:@"zipcode"] != (id)[NSNull null] && [[_people.contact objectForKey:@"zipcode"] length] != 0 ) {
        [temporaryArray addObject:NSLocalizedString(@"Post code", @"")];
        [_peopleAttributeValues addObject:[_people.contact objectForKey:@"zipcode"]];
    }
    if ([_people.contact objectForKey:@"city"] != (id)[NSNull null] && [[_people.contact objectForKey:@"city"] length] != 0 ) {
        [temporaryArray addObject:NSLocalizedString(@"City", @"")];
        [_peopleAttributeValues addObject:[_people.contact objectForKey:@"city"]];
    }
    return temporaryArray;
}

- (NSDateFormatter *)dateFormatter {
    if (!_dateFormatter) {
        _dateFormatter = [NSDateFormatter new];
        _dateFormatter.dateStyle = NSDateFormatterMediumStyle;
        _dateFormatter.timeStyle = NSDateFormatterNoStyle;
    }
    return _dateFormatter;
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
