//
//  CHDListSelectorViewController.m
//  ChurchDesk
//
//  Created by Jakob Vinther-Larsen on 02/03/15.
//  Copyright (c) 2015 Shape A/S. All rights reserved.
//

#import "CHDListSelectorViewController.h"
#import "CHDSelectorTableViewCell.h"
#import "CHDListSelectableProtocol.h"

@interface CHDListSelectorViewController ()
@property (nonatomic, strong) NSArray *selectableElements;

@property (nonatomic, strong) UITableView *tableView;
@end

NSString* const kSelectorCellIdentifyer = @"CHDSelectorTableViewCell";

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
        _tableView.contentInset = UIEdgeInsetsMake(35, 0, 0, 0);
        _tableView.dataSource = self;
        _tableView.delegate = self;
    }
    return _tableView;
}


#pragma mark - Table Delegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.selectableElements.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    CHDSelectorTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kSelectorCellIdentifyer forIndexPath:indexPath];

    id<CHDListSelectableProtocol> element = self.selectableElements[indexPath.row];

    cell.titleLabel.text = element.title;
    cell.selected = element.selected;
    cell.dotColor = element.dotColor;

    return cell;
}

@end
