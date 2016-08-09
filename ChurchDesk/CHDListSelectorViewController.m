//
//  CHDListSelectorViewController.m
//  ChurchDesk
//
//  Created by Jakob Vinther-Larsen on 02/03/15.
//  Copyright (c) 2015 Shape A/S. All rights reserved.
//

#import "CHDListSelectorViewController.h"
#import "CHDSelectorTableViewCell.h"
#import "CHDSelectorImageTableViewCell.h"
#import "UIImageView+Haneke.h"
#import "CHDDividerTableViewCell.h"


@interface CHDListSelectorViewController ()
@property (nonatomic, strong) NSMutableArray *selectableElements;
@property (nonatomic, strong) NSMutableArray *sectionIndices;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSArray *items;
@end

NSString* const kSelectorCellIdentifyer = @"CHDSelectorTableViewCell";
NSString* const kSelectorImageCellIdentifyer = @"CHDSelectorImageTableViewCell";
NSString* const kSelectorDeviderCellIdentifyer = @"CHDSelectorDeviderTableViewCell";

@implementation CHDListSelectorViewController

- (instancetype)initWithSelectableItems:(NSArray *)items {
    if((self = [super init])){
        self.items = items;
        [self setupData:items];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    [self makeViews];
    [self makeConstraints];
    [self makeBindings];
}

#pragma mark - lazy initialization
- (void) makeViews {
    [self.view addSubview:self.tableView];
    
    UIBarButtonItem *sendButton = [[UIBarButtonItem new] initWithTitle:NSLocalizedString(@"Save", @"") style:UIBarButtonItemStylePlain target:self action:@selector(rightBarButtonTouch)];
    [sendButton setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys: [UIColor whiteColor],  NSForegroundColorAttributeName,nil] forState:UIControlStateNormal];
    [sendButton setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys: [UIColor chd_menuDarkBlue],  NSForegroundColorAttributeName,nil] forState:UIControlStateDisabled];
    self.navigationItem.rightBarButtonItem = sendButton;

}

-(void) makeConstraints {
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
}

-(void) makeBindings {
    RAC(self.tableView, allowsMultipleSelection) = RACObserve(self, selectMultiple);
}

- (UITableView *)tableView {
    if(!_tableView){
        _tableView = [UITableView new];
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.backgroundView.backgroundColor = [UIColor chd_lightGreyColor];
        _tableView.backgroundColor = [UIColor chd_lightGreyColor];
        [_tableView registerClass:[CHDSelectorTableViewCell class] forCellReuseIdentifier:kSelectorCellIdentifyer];
        [_tableView registerClass:[CHDSelectorImageTableViewCell class] forCellReuseIdentifier:kSelectorImageCellIdentifyer];
        [_tableView registerClass:[CHDDividerTableViewCell class] forCellReuseIdentifier:kSelectorDeviderCellIdentifyer];
        _tableView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0);
        _tableView.dataSource = self;
        _tableView.delegate = self;
    }
    return _tableView;
}

- (NSArray *)selectedItems {
    return [self.items shp_filter:^BOOL(CHDListSelectorConfigModel *element) {
        return element.selected;
    }];
}

#pragma mark -TableData source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.sectionIndices.count;
}

#pragma mark - Table Delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView cellForRowAtIndexPath:indexPath].selected = YES;
    CHDListSelectorConfigModel* element = [[self.selectableElements objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    BOOL elementSelectedPreStage = element.selected;
    
    [self willChangeValueForKey:@"selectedItems"];
    element.selected = YES;
    [self didChangeValueForKey:@"selectedItems"];
    
    [self.selectorDelegate chdListSelectorDidSelect:element];

    //Only pop if the stage has changed
    if(elementSelectedPreStage != YES && !self.selectMultiple){
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath {
    CHDListSelectorConfigModel* element = [[self.selectableElements objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    [self willChangeValueForKey:@"selectedItems"];
    element.selected = NO;
    [self didChangeValueForKey:@"selectedItems"];
    [tableView cellForRowAtIndexPath:indexPath].selected = NO;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [[self.selectableElements objectAtIndex:section] count];
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView
{
    if (_isTag) {
        return self.sectionIndices;
    }
    else{
        return nil;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
//    if(indexPath.section == 0 || indexPath.section == [self numberOfSectionsInTableView:tableView] - 1){
//        CHDDividerTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kSelectorDeviderCellIdentifyer forIndexPath:indexPath];
//        cell.hideTopLine = indexPath.section == 0 && indexPath.row == 0;
//        cell.hideBottomLine = indexPath.section == [tableView numberOfSections]-1 && indexPath.row == [tableView numberOfRowsInSection:indexPath.section]-1;
//        return cell;
//    }

    CHDListSelectorConfigModel* element = [[self.selectableElements objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];

    if(element.imageURL){
        CHDSelectorImageTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kSelectorImageCellIdentifyer forIndexPath:indexPath];
        [cell layoutIfNeeded];
        [cell.thumbnailImageView hnk_setImageFromURL:element.imageURL];
        cell.nameLabel.text = element.title;
        cell.selected = element.selected;
        if(element.selected){
            [tableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
        }
        cell.dividerLineHidden = (indexPath.row == [self tableView:tableView numberOfRowsInSection:indexPath.section] -1);
        [cell layoutIfNeeded];
        return cell;
    }else{
        CHDSelectorTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kSelectorCellIdentifyer forIndexPath:indexPath];
        cell.isTag = _isTag;
        cell.titleLabel.text = element.title;
        if(element.selected){
            [tableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
        }
        //cell.selected = element.selected;
        cell.dotColor = element.dotColor;

        cell.dividerLineHidden = NO;
        return cell;
    }
}

-(void) rightBarButtonTouch{
    [self.navigationController popViewControllerAnimated:YES];
}

-(void) setupData :(NSArray *)items{
    _sectionIndices = [[NSMutableArray alloc] init];
    _selectableElements = [[NSMutableArray alloc] init];
    NSArray *alphaArray=[[NSArray alloc] initWithObjects:@"A",@"B",@"C",@"D",@"E",@"F",@"G",@"H",@"I",@"J",@"K",@"L",@"M",@"N",@"O",@"P",@"Q",@"R",@"S",@"T",@"U",@"V",@"W",@"X",@"Y",@"Z", nil];
    NSMutableArray *tempArray;
    NSString *prefix;
    for (int i=0; i<alphaArray.count; i++)
    {
        tempArray=[[NSMutableArray alloc] init];
        for(int j=0;j<items.count;j++)
        {
            NSCharacterSet *whitespace = [NSCharacterSet whitespaceAndNewlineCharacterSet];
            CHDListSelectorConfigModel* element = [items objectAtIndex:j];
            prefix = [[element.title stringByTrimmingCharactersInSet:whitespace] substringToIndex:1];
            if ([prefix caseInsensitiveCompare:[alphaArray objectAtIndex:i]] == NSOrderedSame )
            {
                [tempArray addObject:element];
            }
        }
        if (tempArray.count>0)
        {
            [_sectionIndices addObject:[alphaArray objectAtIndex:i]];
            [_selectableElements addObject:tempArray];
        }
    }
}
@end
