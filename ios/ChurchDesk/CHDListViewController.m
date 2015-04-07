//
//  CHDListSelectorViewController.m
//  ChurchDesk
//
//  Created by Jakob Vinther-Larsen on 02/03/15.
//  Copyright (c) 2015 Shape A/S. All rights reserved.
//

#import "CHDListViewController.h"
#import "CHDSelectorTableViewCell.h"


@interface CHDListViewController ()
@property (nonatomic, strong) NSArray *elements;

@property (nonatomic, strong) UITableView *tableView;
@end

NSString* const kListCellIdentifyer = @"CHDListTableViewCell";

@implementation CHDListViewController

- (instancetype)initWithItems:(NSArray *)items {
    if((self = [super init])){
        self.elements = items;
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
}

- (UITableView *)tableView {
    if(!_tableView){
        _tableView = [UITableView new];
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.backgroundView.backgroundColor = [UIColor chd_lightGreyColor];
        _tableView.backgroundColor = [UIColor chd_lightGreyColor];
        [_tableView registerClass:[CHDSelectorTableViewCell class] forCellReuseIdentifier:kListCellIdentifyer];
        _tableView.contentInset = UIEdgeInsetsMake(35, 0, 0, 0);
        _tableView.dataSource = self;
        _tableView.delegate = self;
    }
    return _tableView;
}

#pragma mark - Table Delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.elements.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    CHDSelectorTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kListCellIdentifyer forIndexPath:indexPath];
    CHDListConfigModel* element = self.elements[indexPath.row];

    cell.titleLabel.text = element.title;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.dotColor = element.dotColor;
    cell.selected = NO;

    cell.dividerLineHidden = (indexPath.row == [self tableView:tableView numberOfRowsInSection:indexPath.section] -1);

    return cell;
}

@end
