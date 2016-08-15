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
#import "CHDCreatePersonViewController.h"
#import "CHDListConfigModel.h"
#import "CHDListViewController.h"

@interface CHDPeopleProfileViewController () <UITableViewDelegate, UITableViewDataSource, UIActionSheetDelegate>
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
    // Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.profileTable reloadData];
    [self makeBindings];
}

-(void) viewWillDisappear:(BOOL)animated{
    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:ksuccessfulPeopleMessage];
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
    [self.view addSubview:self.sendMessageButton];
    UIBarButtonItem *editButton = [[UIBarButtonItem new] initWithTitle:NSLocalizedString(@"Edit", @"") style:UIBarButtonItemStylePlain target:self action:@selector(editPersonAction:)];
    [editButton setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys: [UIColor whiteColor],  NSForegroundColorAttributeName,nil] forState:UIControlStateNormal];
    self.navigationItem.rightBarButtonItem = editButton;
    
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
        make.left.equalTo(containerView).offset(20);
        make.top.equalTo(containerView).with.offset(160);
    }];
    
    [self.sendMessageButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(containerView).offset(-20);
        make.top.equalTo(containerView).with.offset(160);
    }];
}

-(void) makeBindings {
    self.userNameLabel.text = _people.fullName;
    self.title = NSLocalizedString(@"Profile", @"");
    if ([_people.picture valueForKey:@"url"] != (id)[NSNull null]) {
        [self userImageWithUrl:[NSURL URLWithString:[_people.picture valueForKey:@"url"]]];
    }
    self.callButton.enabled = true;
    if ((([_people.contact objectForKey:@"phone"] == (id)[NSNull null]) || [[_people.contact objectForKey:@"phone"] length] == 0) ) {
        self.callButton.enabled = false;
    }
    if ((([_people.contact objectForKey:@"phone"] == (id)[NSNull null]) || [[_people.contact objectForKey:@"phone"] length] == 0) && (_people.email == (id)[NSNull null] || _people.email.length == 0 )){
        self.sendMessageButton.enabled = false;
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
        _profileTable.allowsSelection = YES;
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
        [_callButton setImage:kImgCallIcon forState:UIControlStateNormal];
        [_callButton addTarget:self action:@selector(callAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _callButton;
}

- (UIButton *)sendMessageButton {
    if (!_sendMessageButton) {
        _sendMessageButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_sendMessageButton setImage:kImgTabMailActive forState:UIControlStateNormal];
        [_sendMessageButton addTarget:self action:@selector(sendMessageAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _sendMessageButton;
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self peopleAttributes].count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString* cellIdentifier = @"profileCell";
    CHDEventTextValueTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    cell.backgroundColor = [UIColor whiteColor];
    cell.titleLabel.text = [[self peopleAttributes] objectAtIndex:indexPath.row];
    if ([cell.titleLabel.text isEqualToString:NSLocalizedString(@"Tags", @"")]) {
        NSArray *tagsArray = [_peopleAttributeValues objectAtIndex:indexPath.row];
        cell.valueLabel.text = [NSString stringWithFormat:@"%lu", (unsigned long)tagsArray.count];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    else{
    cell.valueLabel.text = [_peopleAttributeValues objectAtIndex:indexPath.row];
    if ([cell.titleLabel.text isEqualToString:NSLocalizedString(@"Gender", @"")]) {
        if ([cell.valueLabel.text caseInsensitiveCompare:@"male"] == NSOrderedSame) {
            cell.valueLabel.text = NSLocalizedString(@"Male", @"");
        }
        else{
            cell.valueLabel.text = NSLocalizedString(@"Female", @"");
        }
    }
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    return cell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([[[self peopleAttributes] objectAtIndex:indexPath.row] isEqualToString:NSLocalizedString(@"E-mail", @"")]) {
        [self sendMessageAction:nil];
        [Heap track:@"People profile: Clicked on email"];
    }
    else if ([[[self peopleAttributes] objectAtIndex:indexPath.row] isEqualToString:NSLocalizedString(@"Mobile phone", @"")] || [[[self peopleAttributes] objectAtIndex:indexPath.row] isEqualToString:NSLocalizedString(@"Work phone", @"")] || [[[self peopleAttributes] objectAtIndex:indexPath.row] isEqualToString:NSLocalizedString(@"Home phone", @"")]){
        [self callAction:[[self peopleAttributeValues] objectAtIndex:indexPath.row]];
        [Heap track:@"People profile: Clicked on phone"];
    }
    else if ([[[self peopleAttributes] objectAtIndex:indexPath.row] isEqualToString:NSLocalizedString(@"Tags", @"")]){
    NSMutableArray *items = [[NSMutableArray alloc] init];
    for(NSString *tag in [_peopleAttributeValues objectAtIndex:indexPath.row]){
            CHDListConfigModel *configItem = [[CHDListConfigModel alloc] initWithTitle:tag color:nil];
            [items addObject:configItem];
    }
    CHDListViewController *vc = [[CHDListViewController alloc] initWithItems:items];
    vc.title = NSLocalizedString(@"Tags", @"");
    [self.navigationController pushViewController:vc animated:YES];
    }
}

#pragma mark - Actions

- (void)callAction: (NSString *) phoneNumber {
    [Heap track:@"People profile: Call clicked"];
    NSString *phoneNo;
    if ([phoneNumber isKindOfClass:[NSString class]]) {
        phoneNo = phoneNumber;
    }
    else{
        phoneNo = [_people.contact objectForKey:@"phone"];
    }
    NSURL *phoneUrl = [NSURL URLWithString:[NSString  stringWithFormat:@"telprompt:%@",phoneNo]];
    
    if ([[UIApplication sharedApplication] canOpenURL:phoneUrl]) {
        [[UIApplication sharedApplication] openURL:phoneUrl];
    } else
    {
        UIAlertView *calert = [[UIAlertView alloc]initWithTitle:@"Alert" message:@"Your device doesn't support voice calls." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
        [calert show];
    }
}

-(void)sendMessageAction: (id) sender {
    [Heap track:@"People profile: Message clicked"];
    BOOL emailExists = NO;
    BOOL phoneExists = NO;
    if ((_people.email != (id)[NSNull null] && _people.email.length != 0)) {
        emailExists = YES;
    }
    if ([_people.contact objectForKey:@"phone"] != (id)[NSNull null] && [[_people.contact objectForKey:@"phone"] length] != 0 ) {
        phoneExists = YES;
    }
    if (emailExists && !phoneExists) {
        [self createMessageShow:NO];
    }
    else if (phoneExists && !emailExists){
        [self createMessageShow:YES];
    }
    else{
        UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:NSLocalizedString(@"Choose message type..", @"")                                                                           delegate:self
                                                    cancelButtonTitle:NSLocalizedString(@"Cancel", @"")
                                               destructiveButtonTitle:nil
                                                    otherButtonTitles:NSLocalizedString(@"Send an email", @""), NSLocalizedString(@"Send an SMS", @""), nil];
        actionSheet.tag = 101;
        [actionSheet showInView:self.view];
    }
}

- (void)editPersonAction: (id) sender {
    
        CHDCreatePersonViewController *vc = [CHDCreatePersonViewController new];
        vc.title = NSLocalizedString(@"Edit Person", @"");
        [Heap track:@"Edit Person"];
        vc.personToEdit = self.people;
        vc.organizationId = self.organizationId;
        RACSignal *saveSignal = [RACObserve(vc, personToEdit) skip:1];
        [self rac_liftSelector:@selector(dismissViewControllerAnimated:completion:) withSignals:[saveSignal mapReplace:@YES], [RACSignal return:nil], nil];
        [self presentViewController:[[UINavigationController alloc] initWithRootViewController:vc] animated:YES completion:nil];
}

#pragma mark - Action Sheet delgate methods
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (actionSheet.tag == 101) {
        if (buttonIndex != 2) {
            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
            [defaults setBool:NO forKey:ktoPeopleClicked];
            if (buttonIndex == 0) {
                [self createMessageShow:NO];
            }
            else{
                [self createMessageShow:YES];
            }
        }
    }
}

-(void)createMessageShow :(BOOL)isSMS{
    CHDCreateMessageMailViewController* newMessageViewController = [CHDCreateMessageMailViewController new];
    newMessageViewController.selectedPeopleArray = [[NSArray alloc] initWithObjects:_people, nil];;
    newMessageViewController.currentUser = _currentUser;
    newMessageViewController.organizationId = _organizationId;
        newMessageViewController.isSMS = isSMS;
    UINavigationController *navigationVC = [[UINavigationController new] initWithRootViewController:newMessageViewController];
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
        [temporaryArray addObject:NSLocalizedString(@"Mobile phone", @"")];
        [_peopleAttributeValues addObject:[_people.contact objectForKey:@"phone"]];
    }
    if ([_people.contact objectForKey:@"homePhone"] != (id)[NSNull null] && [[_people.contact objectForKey:@"homePhone"] length] != 0 ) {
        [temporaryArray addObject:NSLocalizedString(@"Home Phone", @"")];
        [_peopleAttributeValues addObject:[_people.contact objectForKey:@"homePhone"]];
    }
    if ([_people.contact objectForKey:@"workPhone"] != (id)[NSNull null] && [[_people.contact objectForKey:@"workPhone"] length] != 0 ) {
        [temporaryArray addObject:NSLocalizedString(@"Work Phone", @"")];
        [_peopleAttributeValues addObject:[_people.contact objectForKey:@"workPhone"]];
    }
    if (_people.occupation != (id)[NSNull null] && _people.occupation.length != 0 ) {
        [temporaryArray addObject:NSLocalizedString(@"Job Title", @"")];
        [_peopleAttributeValues addObject:_people.occupation];
    }
    if (_people.birthday != NULL) {
        [temporaryArray addObject:NSLocalizedString(@"Birthday", @"")];
        [_peopleAttributeValues addObject:[self.dateFormatter stringFromDate:_people.birthday]];
    }
    if (_people.registered != NULL) {
        [temporaryArray addObject:NSLocalizedString(@"Registered on", @"")];
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
    if (_people.tags.count > 0) {
        [temporaryArray addObject:NSLocalizedString(@"Tags", @"")];
        NSMutableArray *personTags = [[NSMutableArray alloc] init];
        for (int i=0; i < _people.tags.count; i++) {
            NSDictionary *singleTag = [_people.tags objectAtIndex:i];
            [personTags addObject:[singleTag valueForKey:@"name"]];
        }
        [_peopleAttributeValues addObject:personTags];
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
