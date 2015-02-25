//
//  CHDDayPickerViewController.m
//  ChurchDesk
//
//  Created by Mikkel Selsøe Sørensen on 25/02/15.
//  Copyright (c) 2015 Shape A/S. All rights reserved.
//

#import "CHDDayPickerViewController.h"
#import "CHDDayCollectionViewCell.h"
#import "CHDDayPickerViewModel.h"

static CGFloat kTopLineHeight = 1.0f;
static NSUInteger kItemCount = 500;

@interface CHDDayPickerViewController () <UICollectionViewDataSource, UICollectionViewDelegate>

@property (nonatomic, strong) CHDDayPickerViewModel *viewModel;
@property (nonatomic, strong) UIView *topLineView;
@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) UICollectionViewFlowLayout *collectionViewLayout;

@property (nonatomic, strong) NSDate *selectedDate;
@property (nonatomic, strong) NSDate *referenceDate;

@end

@implementation CHDDayPickerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.viewModel = [CHDDayPickerViewModel new];
    
    self.selectedDate = [NSDate date];
    self.referenceDate = self.selectedDate;
    
    [self setupSubviews];
    [self makeConstraints];
}

- (void) setupSubviews {
    [self.view addSubview:self.topLineView];
    [self.view addSubview:self.collectionView];
}

- (void) makeConstraints {
    [self.topLineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.right.equalTo(self.view);
        make.height.equalTo(@(kTopLineHeight));
    }];
    
    [self.collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.bottom.right.equalTo(self.view);
        make.top.equalTo(self.topLineView.mas_bottom);
    }];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    self.collectionViewLayout.itemSize = CGSizeMake(53, self.view.bounds.size.height-kTopLineHeight);
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.view layoutIfNeeded];
    [self scrollToDate:self.referenceDate animated:NO];
    [self.collectionView selectItemAtIndexPath:[self indexPathForItemAtDate:self.selectedDate] animated:NO scrollPosition:UICollectionViewScrollPositionNone];
}

#pragma mark - UICollectionViewDelegate

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset {
    NSIndexPath *indexPath = [self.collectionView indexPathForItemAtPoint:*targetContentOffset];
    UICollectionViewLayoutAttributes *attrs = [self.collectionView layoutAttributesForItemAtIndexPath:indexPath];
    *targetContentOffset = CGPointMake(attrs.center.x - scrollView.center.x, 0);
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    NSIndexPath *indexPath = [self indexPathForCenterItem];
    self.referenceDate = [self dateForItemAtIndexPath:indexPath];
    [self.collectionView reloadData];
    [self.collectionView layoutIfNeeded];
    
    [self scrollToDate:self.referenceDate animated:NO];
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return kItemCount;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    CHDDayCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];

    NSDate *date = [self dateForItemAtIndexPath:indexPath];
    
    cell.weekdayLabel.text = [self.viewModel threeLetterWeekdayFromDate:date];
    cell.dayLabel.text = [self.viewModel dayOfMonthFromDate:date];
    
    return cell;
}

#pragma mark - Private

- (void) scrollToDate: (NSDate*) date animated: (BOOL) animated {
    NSIndexPath *newIndexPath = [self indexPathForItemAtDate:date];
    [self.collectionView scrollToItemAtIndexPath:newIndexPath atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:animated];
}

- (NSDate*) dateForItemAtIndexPath: (NSIndexPath*) indexPath {
    NSInteger offset = indexPath.item - (kItemCount/2);
    NSDate *date = offset != 0 ? [self.viewModel dateOffsetByDays:offset fromDate:self.referenceDate] : self.referenceDate;
    return date;
}

- (NSIndexPath*) indexPathForItemAtDate: (NSDate*) date {
    NSInteger offset = [self.viewModel daysFromReferenceDate:self.referenceDate toDate:date];
    return [NSIndexPath indexPathForItem:(kItemCount/2) + offset inSection: 0];
}

- (NSIndexPath*) indexPathForCenterItem {
    return [self.collectionView indexPathForItemAtPoint:CGPointMake(self.collectionView.contentOffset.x + self.collectionView.center.x, 0)];
}

#pragma mark - Lazy Initialization

- (UICollectionViewFlowLayout *)collectionViewLayout {
    if (!_collectionViewLayout) {
        _collectionViewLayout = [[UICollectionViewFlowLayout alloc] init];
        _collectionViewLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        _collectionViewLayout.minimumInteritemSpacing = 0;
        _collectionViewLayout.minimumLineSpacing = 1;
    }
    return _collectionViewLayout;
}

- (UIView *)topLineView {
    if (!_topLineView) {
        _topLineView = [UIView new];
        _topLineView.backgroundColor = [UIColor shpui_colorWithHexValue:0xededed];
    }
    return _topLineView;
}

- (UICollectionView *)collectionView {
    if (!_collectionView) {
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:self.collectionViewLayout];
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        _collectionView.showsHorizontalScrollIndicator = NO;
        _collectionView.backgroundColor = [UIColor shpui_colorWithHexValue:0xf9f9f9];
        [_collectionView registerClass:[CHDDayCollectionViewCell class] forCellWithReuseIdentifier:@"cell"];
    }
    return _collectionView;
}

@end
