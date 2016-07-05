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
#import "CHDSelectParishForPeopleViewController.h"
#import "UINavigationController+ChurchDesk.h"
#import "CHDAPIClient.h"

@interface CHDLeftViewController () <UIGestureRecognizerDelegate, UIActionSheetDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate>
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

- (void)editAction: (id) sender {
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera] )
    {
        
        UIActionSheet *actionSheet = [[UIActionSheet alloc]
                                      initWithTitle:nil
                                      delegate:self
                                      cancelButtonTitle:NSLocalizedString(@"Cancel", @"")
                                      destructiveButtonTitle:nil
                                      otherButtonTitles:NSLocalizedString(@"Choose Photo", @""), NSLocalizedString(@"Take Photo", @""), nil];
        actionSheet.tag = 100;
        [actionSheet showFromToolbar:[[self navigationController] toolbar]];
    }
    else{
        UIActionSheet *actionSheet = [[UIActionSheet alloc]
                                      initWithTitle:nil
                                      delegate:self
                                      cancelButtonTitle:NSLocalizedString(@"Cancel", @"")
                                      destructiveButtonTitle:nil
                                      otherButtonTitles:NSLocalizedString(@"Choose Photo", @""), nil];
        actionSheet.tag = 102;
        [actionSheet showFromToolbar:[[self navigationController] toolbar]];
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
        CHDSite *organization = [user.sites objectAtIndex:0];
        NSData *encodedUser = [NSKeyedArchiver archivedDataWithRootObject:user];
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setObject:encodedUser forKey:kcurrentuser];
        [defaults setValue:user.userId forKey:@"userId"];
        [defaults setValue:organization.siteId forKey:@"organizationId"];
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
        _userImageView.userInteractionEnabled = YES;
        UITapGestureRecognizer *pgr = [[UITapGestureRecognizer alloc]
                                       initWithTarget:self action:@selector(editAction:)];
        pgr.delegate = self;
        [_userImageView addGestureRecognizer:pgr];
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
        [Heap track:@"Help and Support clicked"];
        [Intercom presentConversationList];
    }
    else{
        switch (indexPath.row) {
            case 0:
                [Heap track:@"Dashboard clicked"];
                break;
            case 1:
                [Heap track:@"Messages clicked"];
                break;
            case 2:
                [Heap track:@"Calendar clicked"];
                break;
            case 3:{
                //People
                NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                NSData *encodedObject = [defaults objectForKey:kcurrentuser];
                CHDUser *user = [NSKeyedUnarchiver unarchiveObjectWithData:encodedObject];
                [defaults setBool:NO forKey:ktoPeopleClicked];
                if (user.sites.count > 1) {
                    CHDSelectParishForPeopleViewController *selectParishViewController = [CHDSelectParishForPeopleViewController new];
                    selectParishViewController.organizations = user.sites;
                    UINavigationController *peopleNavigationController = [UINavigationController chd_sideMenuNavigationControllerWithRootViewController:selectParishViewController];
                    item.viewController = peopleNavigationController;
                }
                [Heap track:@"People clicked"];
                break;
            }
            case 5:
                [Heap track:@"Settings clicked"];
                break;
            default:
                break;
        }
        [self.shp_sideMenuController setSelectedViewController:item.viewController];
        [self.shp_sideMenuController close];
    }
        
}

#pragma mark - Actionsheet delegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (actionSheet.tag == 100)
    {
        if (buttonIndex == 0)
        {//Choose Photo
            UIImagePickerController *picker = [[UIImagePickerController alloc] init];
            picker.delegate = self;
            picker.allowsEditing = YES;
            picker.sourceType=UIImagePickerControllerSourceTypePhotoLibrary;
            [self presentViewController:picker animated:YES completion:nil];
            picker = nil;
        }
        else if (buttonIndex == 1)
        {//Take Photo
            UIImagePickerController *picker = [[UIImagePickerController alloc] init];
            picker.delegate = self;
            picker.allowsEditing = YES;
            picker.sourceType=UIImagePickerControllerSourceTypeCamera;
            //    [self presentModalViewController: picker animated:YES];
            [self presentViewController:picker animated:YES completion:nil];
            picker = nil;
        }
    }
    else if(actionSheet.tag == 102){
        if (buttonIndex == 0)
        {//Choose Photo
            UIImagePickerController *picker = [[UIImagePickerController alloc] init];
            picker.delegate = self;
            picker.allowsEditing = YES;
            picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
            [self presentViewController:picker animated:YES completion:nil];
            picker = nil;
        }
    }
}

- (void)navigationController:(UINavigationController *)navigationController didShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    if ([navigationController.viewControllers count] == 3)
    {
        CGFloat screenHeight = [[UIScreen mainScreen] bounds].size.height;
        
        UIView *plCropOverlay = [[[viewController.view.subviews objectAtIndex:1]subviews] objectAtIndex:0];
        
        plCropOverlay.hidden = YES;
        
        int position = 0;
        
        if (screenHeight == 568)
        {
            position = 124;
        }
        else
        {
            position = 80;
        }
        
        CAShapeLayer *circleLayer = [CAShapeLayer layer];
        
        UIBezierPath *path2 = [UIBezierPath bezierPathWithOvalInRect:
                               CGRectMake(0.0f, position, 320.0f, 320.0f)];
        [path2 setUsesEvenOddFillRule:YES];
        
        [circleLayer setPath:[path2 CGPath]];
        
        [circleLayer setFillColor:[[UIColor clearColor] CGColor]];
        UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(0, 0, 320, screenHeight-72) cornerRadius:0];
        
        [path appendPath:path2];
        [path setUsesEvenOddFillRule:YES];
        
        CAShapeLayer *fillLayer = [CAShapeLayer layer];
        fillLayer.path = path.CGPath;
        fillLayer.fillRule = kCAFillRuleEvenOdd;
        fillLayer.fillColor = [UIColor blackColor].CGColor;
        fillLayer.opacity = 0.8;
        [viewController.view.layer addSublayer:fillLayer];
        
        UILabel *moveLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 10, 320, 50)];
        [moveLabel setText:NSLocalizedString(@"Move and Scale", @"") ];
        [moveLabel setTextAlignment:NSTextAlignmentCenter];
        [moveLabel setTextColor:[UIColor whiteColor]];
        
        [viewController.view addSubview:moveLabel];
    }
}

- (void) imagePickerController:(UIImagePickerController *)picker
 didFinishPickingMediaWithInfo:(NSDictionary *)info {
    //obtaining saving path
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *imagePath = [documentsDirectory stringByAppendingPathComponent:@"people_photo.png"];
    
    //extracting image from the picker and saving it
    NSString *mediaType = [info objectForKey:UIImagePickerControllerMediaType];
    if ([mediaType isEqualToString:@"public.image"]){
        UIImage *editedImage = [info objectForKey:UIImagePickerControllerEditedImage];
        NSData *webData = UIImagePNGRepresentation(editedImage);
        [[CHDAPIClient sharedInstance] uploadPicture:webData organizationId:[[NSUserDefaults standardUserDefaults] valueForKey:@"organizationId"] userId:[[NSUserDefaults standardUserDefaults] valueForKey:@"userId"]];
        [webData writeToFile:imagePath atomically:YES];
    }
    [self.userImageView setImage:[UIImage imageWithContentsOfFile:imagePath]];
    [picker dismissViewControllerAnimated:YES completion:nil];
}

@end
