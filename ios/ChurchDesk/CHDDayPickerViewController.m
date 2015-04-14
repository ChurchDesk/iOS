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
#import "CHDDayPickerDelegateProtocol.h"

static CGFloat kTopLineHeight = 1.0f;
static NSUInteger kItemCount = 21;
static NSUInteger kVisibleDayCount = 7;

@interface CHDDayPickerViewController () <UICollectionViewDataSource, UICollectionViewDelegate>

@property (nonatomic, strong) CHDDayPickerViewModel *viewModel;
@property (nonatomic, strong) UIView *topLineView;
@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) UICollectionViewFlowLayout *collectionViewLayout;

@property (nonatomic, strong) NSDate *referenceDate; // First visible day - should be a monday

@property (nonatomic, assign) NSUInteger currentWeekNumber;

@end

@implementation CHDDayPickerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.viewModel = [CHDDayPickerViewModel new];
    
    NSDate *today = [[NSCalendar currentCalendar] dateBySettingHour:0 minute:0 second:0 ofDate:[NSDate date] options:0];
    self.referenceDate = [self.viewModel dateForMondayOfWeekWithDate:self.selectedDate ?: today];
    
    [self setupSubviews];
    [self makeConstraints];
    [self setupBindings];
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

- (void) setupBindings {
    [self rac_liftSelector:@selector(scrollToDate:animated:) withSignals:[RACObserve(self, selectedDate) ignore:nil], [RACSignal return:@YES], nil];
    
    [self shprac_liftSelector:@selector(updateCellSelection) withSignal:RACObserve(self, selectedDate)];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    self.collectionViewLayout.itemSize = CGSizeMake(self.view.bounds.size.width/kVisibleDayCount, self.view.bounds.size.height-kTopLineHeight);
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.view layoutIfNeeded];
    [self scrollToDate:self.referenceDate animated:NO];
    if (self.selectedDate) {
        [self.collectionView selectItemAtIndexPath:[self indexPathForItemAtDate:self.selectedDate] animated:NO scrollPosition:UICollectionViewScrollPositionNone];
    }
}

#pragma mark - Actions

- (void) scrollToDate: (NSDate*) date animated: (BOOL) animated {
    NSDate *mondayOfDate = [self.viewModel dateForMondayOfWeekWithDate:date];
    NSIndexPath *newIndexPath = [self indexPathForItemAtDate:mondayOfDate];

    if(newIndexPath.item < 2){
        [self reloadDataWithReferenceDate:mondayOfDate];
        return;
    }

    if (newIndexPath.item < kVisibleDayCount) {
        return;
    }
    
    if (newIndexPath.item > kItemCount-1) {
        [self reloadDataWithReferenceDate:mondayOfDate];
        return;
    }
    
    [self.collectionView scrollToItemAtIndexPath:newIndexPath atScrollPosition:UICollectionViewScrollPositionLeft animated:animated];
}

- (void)reloadShownDates {
    [self.collectionView reloadData];
}


#pragma mark - UIScrollViewDelegate

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset {
    scrollView.scrollEnabled = NO;
}

- (void)scrollViewDidEndDecelerating:(UICollectionView *)collectionView {
    NSIndexPath *indexPath = [collectionView indexPathForItemAtPoint:collectionView.contentOffset];

    NSDate *currentDate = [self dateForItemAtIndexPath:indexPath];
    
    [self reloadDataWithReferenceDate:currentDate];
    
    self.currentWeekNumber = [[NSCalendar currentCalendar] component:NSCalendarUnitWeekOfYear fromDate:currentDate];
    
    collectionView.scrollEnabled = YES;
}

#pragma mark - UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    CHDDayCollectionViewCell *cellToSelect = (CHDDayCollectionViewCell *)[collectionView cellForItemAtIndexPath:indexPath];
    self.selectedDate = [self dateForItemAtIndexPath:indexPath];
    for (CHDDayCollectionViewCell *cell in collectionView.visibleCells) {
        cell.picked = cell == cellToSelect;
    }
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
    cell.picked = [date isEqualToDate:self.selectedDate];
    cell.showDot = [self.delegate chdDayPickerEventsExistsOnDay:date];

    return cell;
}

#pragma mark - Private

- (void) reloadDataWithReferenceDate: (NSDate*) date {
    self.referenceDate = date;
    [self.collectionView reloadData];
    [self.collectionView layoutIfNeeded];
    self.collectionView.contentOffset = CGPointMake(self.collectionView.bounds.size.width, 0);
}

- (NSDate*) dateForItemAtIndexPath: (NSIndexPath*) indexPath {
    return [self dateForItemAtIndexPath:indexPath referenceDate:self.referenceDate];
}

- (NSDate*) dateForItemAtIndexPath: (NSIndexPath*) indexPath referenceDate: (NSDate*) referenceDate {
    if (!indexPath) {
        return nil;
    }
    return [self.viewModel dateOffsetByDays:indexPath.item - kVisibleDayCount fromDate:referenceDate];
}

- (NSIndexPath*) indexPathForItemAtDate: (NSDate*) date {
    NSInteger offset = [self.viewModel daysFromReferenceDate:self.referenceDate toDate:date];
    return [NSIndexPath indexPathForItem: kVisibleDayCount + offset inSection: 0];
}

- (void) updateCellSelection {
    for (CHDDayCollectionViewCell *cell in self.collectionView.visibleCells) {
        NSIndexPath *indexPath = [self.collectionView indexPathForCell:cell];
        NSDate *date = [self dateForItemAtIndexPath:indexPath];
        cell.picked = self.selectedDate ? [self.viewModel daysFromReferenceDate:self.selectedDate toDate:date] == 0 : NO;
    }
}

#pragma mark - Lazy Initialization

- (UICollectionViewFlowLayout *)collectionViewLayout {
    if (!_collectionViewLayout) {
        _collectionViewLayout = [[UICollectionViewFlowLayout alloc] init];
        _collectionViewLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        _collectionViewLayout.minimumInteritemSpacing = 0;
        _collectionViewLayout.minimumLineSpacing = 0;
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
        _collectionView.pagingEnabled = YES;
        [_collectionView registerClass:[CHDDayCollectionViewCell class] forCellWithReuseIdentifier:@"cell"];
    }
    return _collectionView;
}

@end
