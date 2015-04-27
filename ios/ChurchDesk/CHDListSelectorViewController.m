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


@interface CHDListSelectorViewController ()
@property (nonatomic, strong) NSArray *selectableElements;

@property (nonatomic, strong) UITableView *tableView;
@end

NSString* const kSelectorCellIdentifyer = @"CHDSelectorTableViewCell";
NSString* const kSelectorImageCellIdentifyer = @"CHDSelectorImageTableViewCell";

@implementation CHDListSelectorViewController

- (instancetype)initWithSelectableItems:(NSArray *)items {
    if((self = [super init])){
        self.selectableElements = items;
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
        _tableView.contentInset = UIEdgeInsetsMake(35, 0, 0, 0);
        _tableView.dataSource = self;
        _tableView.delegate = self;
    }
    return _tableView;
}

- (NSArray *)selectedItems {
    return [self.selectableElements shp_filter:^BOOL(CHDListSelectorConfigModel *element) {
        return element.selected;
    }];
}

#pragma mark - Table Delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView cellForRowAtIndexPath:indexPath].selected = YES;
    
    CHDListSelectorConfigModel* element = self.selectableElements[indexPath.row];
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
    CHDListSelectorConfigModel* element = self.selectableElements[indexPath.row];

    [self willChangeValueForKey:@"selectedItems"];
    element.selected = NO;
    [self didChangeValueForKey:@"selectedItems"];

    [tableView cellForRowAtIndexPath:indexPath].selected = NO;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.selectableElements.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    CHDListSelectorConfigModel* element = self.selectableElements[indexPath.row];

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

        cell.titleLabel.text = element.title;
        if(element.selected){
            [tableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
        }
        //cell.selected = element.selected;
        cell.dotColor = element.dotColor;

        cell.dividerLineHidden = (indexPath.row == [self tableView:tableView numberOfRowsInSection:indexPath.section] -1);

        return cell;
    }
}

@end
