//
//  Created by Peter Gammelgaard on 19/10/14.
//  Copyright (c) 2014 SHAPE A/S. All rights reserved.
//

#import <SHPCalendarPicker/SHPCalendarPickerWeekDayHeaderView.h>
#import "SHPCalendarPickerView.h"
#import "SHPCalendarPickerDayCell.h"
#import "SHPCalendarPickerWeekDayHeaderView.h"
#import "SHPCalendarPickerLayouter.h"

static NSString *const SHPCalendarPickerDayCellIdentifier = @"SHPCalendarPickerDayCellIdentifier";

static const int CollectionViewContentInset = 7;

@interface SHPCalendarPickerCollectionView : UICollectionView
- (SHPCalendarPickerLayoutAttributes *)layout;
@end

@implementation SHPCalendarPickerCollectionView

- (SHPCalendarPickerLayoutAttributes *)layout
{
    return [[SHPCalendarPickerLayoutAttributes alloc] initWithView:self];
}

@end

@class SHPCalendarPickerCalendarView;

@protocol SHPCalendarPickerCalendarViewDelegate
- (void)calendarPickerCalendarView:(SHPCalendarPickerCalendarView *)calendarPickerCalendarView didSelectDate:(NSDate *)date;
- (void)calendarPickerCalendarView:(SHPCalendarPickerCalendarView *)calendarPickerCalendarView didDeselectDate:(NSDate *)date;
- (NSDictionary *)selectedDatesDictionaryForCalendarPickerCalendarView:(SHPCalendarPickerCalendarView *)calendarPickerCalendarView;
@end

@interface SHPCalendarPickerCalendarView : UIView <UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>
@property (nonatomic, strong) SHPCalendarPickerCollectionView *calendarCollectionView;
@property(nonatomic, strong) UICollectionViewFlowLayout *flowLayout;
@property (nonatomic, strong) NSDate *currentMonth;
@property (nonatomic, strong) NSCalendar *calendar;
@property (nonatomic, assign) enum SHPCalendarPickerViewSelectionMode selectionMode;
@property (nonatomic, assign) BOOL disablePastDates;
@property (nonatomic, weak) id<SHPCalendarPickerCalendarViewDelegate> delegate;

@property(nonatomic, strong) UIFont *textFont;
@property(nonatomic, strong) UIColor *circleDefaultColor;
@property(nonatomic, strong) UIColor *circleSelectedColor;
@property(nonatomic, strong) UIColor *circleHighlightedColor;
@property(nonatomic, strong) UIColor *circleTodayColor;
@property(nonatomic, strong) UIColor *textColor;
@property(nonatomic, strong) UIColor *textTodayColor;
@property(nonatomic, strong) UIColor *textSelectedColor;
@property(nonatomic, strong) UIColor *textHighlightedColor;
@property(nonatomic, strong) UIColor *textDistantColor;

@property(nonatomic, copy) BOOL (^disableDateBlock)(NSDate *);

- (SHPCalendarPickerLayoutAttributes *)layout;

- (void)updateDateSelection;
@end

@implementation SHPCalendarPickerCalendarView

- (instancetype)init {
    self = [super init];
    if (self) {
        [self setTranslatesAutoresizingMaskIntoConstraints:NO];

        [self.calendarCollectionView registerClass:[SHPCalendarPickerDayCell class] forCellWithReuseIdentifier:SHPCalendarPickerDayCellIdentifier];

        [self addSubviews];
    }

    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];

    self.calendarCollectionView.frame = self.bounds;
}

- (void)addSubviews {
    [self addSubview:self.calendarCollectionView];
}

#pragma mark - UICollectionViewCellDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return 6*7; //Worst case we need 6 rows and 7 columns
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    SHPCalendarPickerDayCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:SHPCalendarPickerDayCellIdentifier forIndexPath:indexPath];

    if (self.textFont) {
        cell.textDefaultFont = self.textFont;
    }
    if (self.circleSelectedColor) {
        cell.circleSelectedColor = self.circleSelectedColor;
    }
    if (self.textColor) {
        cell.textDefaultColor = self.textColor;
    }
    if (self.textTodayColor) {
        cell.textTodayColor = self.textTodayColor;
    }
    if (self.textSelectedColor) {
        cell.textSelectedColor = self.textSelectedColor;
    }
    if (self.textDistantColor) {
        cell.textDistantColor = self.textDistantColor;
    }
    if (self.textHighlightedColor) {
        cell.textHighlightedColor = self.textHighlightedColor;
    }
    if (self.circleDefaultColor) {
        cell.circleDefaultColor = self.circleDefaultColor;
    }
    if (self.circleHighlightedColor) {
        cell.circleHighlightedColor = self.circleHighlightedColor;
    }
    if (self.circleTodayColor) {
        cell.circleTodayColor = self.circleTodayColor;
    }
    NSDate *currentDate = [NSDate date];

    NSDate *cellDate = [self dateForCellAtIndexPath:indexPath];
    NSDateComponents *cellDateComponents = [self.calendar components:NSDayCalendarUnit|NSMonthCalendarUnit|NSYearCalendarUnit fromDate:cellDate];
    NSDateComponents *currentMonthComponents = [self.calendar components:NSDayCalendarUnit|NSMonthCalendarUnit fromDate:self.currentMonth];
    NSDateComponents *currentDateComponents = [self.calendar components:NSDayCalendarUnit|NSMonthCalendarUnit|NSYearCalendarUnit fromDate:currentDate];

    BOOL differentMonth = currentMonthComponents.month!=cellDateComponents.month;
    BOOL distantDate = differentMonth || (self.disablePastDates && [self isDate:cellDate earlierThanDate:currentDate]);
    BOOL disableDate = NO;
    if (self.disableDateBlock) {
        disableDate = self.disableDateBlock(cellDate);
    }
    [cell setDistant:distantDate || disableDate];
    [cell setToday:currentDateComponents.month == cellDateComponents.month && currentDateComponents.day == cellDateComponents.day && currentDateComponents.year == cellDateComponents.year];

    cell.dayLabel.text = [NSString stringWithFormat:@"%d", cellDateComponents.day];

    NSDictionary *selectedDatesDictionary = [self.delegate selectedDatesDictionaryForCalendarPickerCalendarView:self];
    NSString *identifier = [self identifierForDate:cellDate];
    BOOL isSelectedDate = selectedDatesDictionary[identifier] != nil;
    if (isSelectedDate) {
        [collectionView selectItemAtIndexPath:indexPath animated:NO scrollPosition:UICollectionViewScrollPositionNone];
        [cell setSelected:isSelectedDate animated:NO];
    }

    cell.frame = [collectionView.collectionViewLayout initialLayoutAttributesForAppearingItemAtIndexPath:indexPath].frame;

    return cell;
}

- (NSDate *)dateForCellAtIndexPath:(NSIndexPath *)indexPath
{
    NSDate *firstOfMonth = [self firstDateMonth];
    NSInteger ordinalityOfFirstDay = [self.calendar ordinalityOfUnit:NSDayCalendarUnit inUnit:NSWeekCalendarUnit forDate:firstOfMonth];
    NSDateComponents *dateComponents = [NSDateComponents new];
    dateComponents.day = (1 - ordinalityOfFirstDay) + indexPath.item;

    return [self.calendar dateByAddingComponents:dateComponents toDate:firstOfMonth options:0];
}

- (NSDate *)firstDateMonth
{
    NSDateComponents *components = [self.calendar components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay
                                                    fromDate:self.currentMonth];
    components.day = 1;

    return [self.calendar dateFromComponents:components];
}

- (BOOL)isDate:(NSDate *)date earlierThanDate:(NSDate *)anotherDate {
    NSDateComponents *dateComponents = [self.calendar components:NSDayCalendarUnit|NSMonthCalendarUnit|NSYearCalendarUnit fromDate:date];
    NSDateComponents *anotherDateComponents = [self.calendar components:NSDayCalendarUnit|NSMonthCalendarUnit|NSYearCalendarUnit fromDate:anotherDate];

    return [date earlierDate:anotherDate] == date && (dateComponents.month < anotherDateComponents.month || (dateComponents.month == anotherDateComponents.month && dateComponents.day < anotherDateComponents.day) || dateComponents.year < anotherDateComponents.year);
}

#pragma mark - UICollectionViewDelegate

- (BOOL)collectionView:(UICollectionView *)collectionView shouldDeselectItemAtIndexPath:(NSIndexPath *)indexPath {
    return collectionView.allowsMultipleSelection;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    NSDate *cellDate = [self dateForCellAtIndexPath:indexPath];
    BOOL disableDate = NO;
    if (self.disableDateBlock) {
        disableDate = self.disableDateBlock(cellDate);
    }

    NSDate *selectedDate = [self.delegate selectedDatesDictionaryForCalendarPickerCalendarView:self].allValues.firstObject;
    if (disableDate) {
        [collectionView deselectItemAtIndexPath:indexPath animated:NO];

        if (!collectionView.allowsMultipleSelection) {
            [collectionView reloadData];
        }
    } else if (!collectionView.allowsMultipleSelection && selectedDate) {
        [self.delegate calendarPickerCalendarView:self didDeselectDate:selectedDate];
    }

    NSString *identifier = [self identifierForDate:cellDate];
    NSDictionary *selectedDatesDictionary = [self.delegate selectedDatesDictionaryForCalendarPickerCalendarView:self];
    if (selectedDatesDictionary[identifier]) {
        [self.delegate calendarPickerCalendarView:self didDeselectDate:cellDate];
    } else {
        [self.delegate calendarPickerCalendarView:self didSelectDate:cellDate];
    }
}

- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath {
    if (collectionView.allowsMultipleSelection) {
        NSDate *cellDate = [self dateForCellAtIndexPath:indexPath];
        [self.delegate calendarPickerCalendarView:self didDeselectDate:cellDate];
    }
}

#pragma mark - Setters

- (void)setSelectionMode:(enum SHPCalendarPickerViewSelectionMode)selectionMode {
    _selectionMode = selectionMode;

    if (self.selectionMode == SHPCalendarPickerViewSelectionModeSingle) {
        [self.calendarCollectionView setAllowsMultipleSelection:NO];
    } else if (self.selectionMode == SHPCalendarPickerViewSelectionModeMultiple) {
        [self.calendarCollectionView setAllowsMultipleSelection:YES];
    }
}

- (void)setFrame:(CGRect)frame {
    [super setFrame:frame];
	
    [self updateCalendarLayout];
}

- (void)setBounds:(CGRect)bounds {
    [super setBounds:bounds];

    [self updateCalendarLayout];
}

- (void)setCurrentMonth:(NSDate *)currentMonth {
    _currentMonth = currentMonth;

    [UIView setAnimationsEnabled:NO];
    [self.calendarCollectionView reloadData];
    [UIView setAnimationsEnabled:YES];
}

#pragma mark - Update layout

- (void)updateCalendarLayout {
    CGFloat width = CGRectGetWidth(self.bounds);
    CGFloat height = CGRectGetHeight(self.bounds);

    if (width>0 && height > 0) {
        CGFloat itemWidth = floorf((width-(2*6))/7);
        CGFloat itemHeight = (height-5*2.0f-CollectionViewContentInset*2)/6.f;
        self.flowLayout.itemSize = (CGSize){itemWidth, itemHeight};
        [self.flowLayout invalidateLayout];
        [self.calendarCollectionView reloadData];
    }
}

- (void)updateDateSelection {
    NSArray *cells = [self.calendarCollectionView visibleCells];
    NSDictionary *selectedDatesDictionary = [self.delegate selectedDatesDictionaryForCalendarPickerCalendarView:self];

    for (SHPCalendarPickerDayCell *cell in cells) {
        NSIndexPath *indexPath = [self.calendarCollectionView indexPathForCell:cell];
        NSDate *cellDate = [self dateForCellAtIndexPath:indexPath];

        NSString *identifier = [self identifierForDate:cellDate];
        BOOL isSelectedDate = selectedDatesDictionary[identifier] != nil;
        if (isSelectedDate) {
            [self.calendarCollectionView selectItemAtIndexPath:indexPath animated:NO scrollPosition:UICollectionViewScrollPositionNone];
            [cell setSelected:isSelectedDate animated:NO];
        } else {
            [self.calendarCollectionView deselectItemAtIndexPath:indexPath animated:NO];
            [cell setSelected:isSelectedDate animated:NO];
        }
    }
}

- (void)setTextFont:(UIFont *)textFont {
    _textFont = textFont;

    for (SHPCalendarPickerDayCell *cell in self.calendarCollectionView.visibleCells) {
        cell.textDefaultFont = textFont;
    }
}

- (void)setCircleSelectedColor:(UIColor *)circleSelectedColor {
    _circleSelectedColor = circleSelectedColor;

    for (SHPCalendarPickerDayCell *cell in self.calendarCollectionView.visibleCells) {
        cell.circleSelectedColor = circleSelectedColor;
    }
}

- (void)setTextColor:(UIColor *)textColor {
    _textColor = textColor;

    for (SHPCalendarPickerDayCell *cell in self.calendarCollectionView.visibleCells) {
        cell.textDefaultColor = textColor;
    }
}

- (void)setTextTodayColor:(UIColor *)textTodayColor {
    _textTodayColor = textTodayColor;

    for (SHPCalendarPickerDayCell *cell in self.calendarCollectionView.visibleCells) {
        cell.textTodayColor = textTodayColor;
    }
}

- (void)setTextSelectedColor:(UIColor *)textSelectedColor {
    _textSelectedColor = textSelectedColor;

    for (SHPCalendarPickerDayCell *cell in self.calendarCollectionView.visibleCells) {
        cell.textSelectedColor = textSelectedColor;
    }
}

- (void)setTextDistantColor:(UIColor *)textDistantColor {
    _textDistantColor = textDistantColor;

    for (SHPCalendarPickerDayCell *cell in self.calendarCollectionView.visibleCells) {
        cell.textDistantColor = textDistantColor;
    }
}

- (void)setTextHighlightedColor:(UIColor *)textHighlightedColor {
    _textHighlightedColor = textHighlightedColor;

    for (SHPCalendarPickerDayCell *cell in self.calendarCollectionView.visibleCells) {
        cell.textHighlightedColor = textHighlightedColor;
    }
}

- (void)setCircleTodayColor:(UIColor *)circleTodayColor {
    _circleTodayColor = circleTodayColor;

    for (SHPCalendarPickerDayCell *cell in self.calendarCollectionView.visibleCells) {
        cell.circleTodayColor = circleTodayColor;
    }
}

- (void)setCircleHighlightedColor:(UIColor *)circleHighlightedColor {
    _circleHighlightedColor = circleHighlightedColor;

    for (SHPCalendarPickerDayCell *cell in self.calendarCollectionView.visibleCells) {
        cell.circleHighlightedColor = circleHighlightedColor;
    }
}

- (void)setCircleDefaultColor:(UIColor *)circleDefaultColor {
    _circleDefaultColor = circleDefaultColor;

    for (SHPCalendarPickerDayCell *cell in self.calendarCollectionView.visibleCells) {
        cell.circleDefaultColor = circleDefaultColor;
    }
}

#pragma mark - Helpers

- (NSString *)identifierForDate:(NSDate *)date {
    NSDateComponents *dateComponents = [self.calendar components:NSDayCalendarUnit|NSMonthCalendarUnit|NSYearCalendarUnit fromDate:date];
    return [NSString stringWithFormat:@"%d%d%d", dateComponents.day, dateComponents.month, dateComponents.year];
}

#pragma mark - Properties

- (SHPCalendarPickerCollectionView *)calendarCollectionView {
    if (!_calendarCollectionView) {
        _calendarCollectionView = [[SHPCalendarPickerCollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:self.flowLayout];
        _calendarCollectionView.backgroundColor = [UIColor whiteColor];
        _calendarCollectionView.dataSource = self;
        _calendarCollectionView.delegate = self;
        _calendarCollectionView.showsVerticalScrollIndicator = NO;
        _calendarCollectionView.showsHorizontalScrollIndicator = NO;
        _calendarCollectionView.alwaysBounceHorizontal = NO;
        [_calendarCollectionView setAllowsMultipleSelection:YES];
        _calendarCollectionView.contentInset = UIEdgeInsetsMake(CollectionViewContentInset, 0, -CollectionViewContentInset, 0);
    }
    return _calendarCollectionView;
}

- (UICollectionViewFlowLayout *)flowLayout {
    if (!_flowLayout) {
        _flowLayout = [UICollectionViewFlowLayout new];
        _flowLayout.minimumLineSpacing = 2.0f;
        _flowLayout.minimumInteritemSpacing = 2.0f;
    }
    return _flowLayout;
}

- (SHPCalendarPickerLayoutAttributes *)layout
{
    return [[SHPCalendarPickerLayoutAttributes alloc] initWithView:self];
}

@end


@interface SHPCalendarPickerView() <SHPCalendarPickerWeekDayHeaderViewDelegate, SHPCalendarPickerCalendarViewDelegate>
@property (nonatomic, strong) SHPCalendarPickerWeekDayHeaderView *headerView;
@property (nonatomic, strong) SHPCalendarPickerCalendarView *prevCalendarView;
@property (nonatomic, strong) SHPCalendarPickerCalendarView *currentCalendarView;
@property (nonatomic, strong) SHPCalendarPickerCalendarView *nextCalendarView;
@property(nonatomic, strong) NSMutableDictionary *selectedDatesDictionary;
@end

@implementation SHPCalendarPickerView {

}

#pragma mark - Life cycle

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self addSubviews];

        self.currentMonth = [NSDate date];
        self.selectionMode = SHPCalendarPickerViewSelectionModeSingle;
        self.disablePastDates = YES;
        self.selectedDatesDictionary = [NSMutableDictionary new];
        self.clipsToBounds = YES;
        self.backgroundColor = [UIColor whiteColor];
    }

    return self;
}

- (instancetype)init {
    return [self initWithFrame:CGRectZero];
}

- (void)layoutSubviews {
    [super layoutSubviews];

    CGFloat width = CGRectGetWidth(self.frame);
    CGFloat height = CGRectGetHeight(self.frame);
    CGFloat headerViewHeight = 72;
    CGFloat calendarViewHeight = height - headerViewHeight;

    self.headerView.frame = CGRectMake(0, 0, width, headerViewHeight);

    self.currentCalendarView.frame = CGRectMake(0, headerViewHeight, width, calendarViewHeight);
    self.prevCalendarView.frame = CGRectMake(-width, headerViewHeight, width, calendarViewHeight);
    self.nextCalendarView.frame = CGRectMake(width, headerViewHeight, width, calendarViewHeight);
}

- (void)addSubviews {
    [self addSubview:self.headerView];

    [self addSubview:self.currentCalendarView];
}

- (void)setSelectedDates:(NSArray *)selectedDates {
    [self.selectedDatesDictionary removeAllObjects];

    if (self.selectionMode == SHPCalendarPickerViewSelectionModeSingle) {
        NSDate *date = selectedDates.firstObject;
        NSString *identifier = [self identifierForDate:date];
        self.selectedDatesDictionary[identifier] = date;
    } else {
        for (NSDate *date in selectedDates) {
            NSString *identifier = [self identifierForDate:date];
            self.selectedDatesDictionary[identifier] = date;
        }
    }

    _selectedDates = self.selectedDatesDictionary.allValues;
    [self.currentCalendarView updateDateSelection];
}

- (void)setSelectionMode:(enum SHPCalendarPickerViewSelectionMode)selectionMode {
    _selectionMode = selectionMode;

    [self.prevCalendarView setSelectionMode:self.selectionMode];
    [self.currentCalendarView setSelectionMode:self.selectionMode];
    [self.nextCalendarView setSelectionMode:self.selectionMode];
}

- (void)setDisablePastDates:(BOOL)disablePastDates {
    _disablePastDates = disablePastDates;

    [self.prevCalendarView setDisablePastDates:self.disablePastDates];
    [self.currentCalendarView setDisablePastDates:self.disablePastDates];
    [self.nextCalendarView setDisablePastDates:self.disablePastDates];
}

- (void)setCurrentMonth:(NSDate *)currentMonth {
    NSDateComponents *newValComps = currentMonth ? [[NSCalendar currentCalendar] components:NSCalendarUnitYear | NSCalendarUnitMonth fromDate:currentMonth] : nil;
    NSDateComponents *curValComps = _currentMonth ? [[NSCalendar currentCalendar] components:NSCalendarUnitYear | NSCalendarUnitMonth fromDate:_currentMonth] : nil;
    
    if (newValComps.year == curValComps.year && newValComps.month == curValComps.month) {
        return;
    }
    
    _currentMonth = currentMonth;

    [self.prevCalendarView setCurrentMonth:[self dateOneMonthFromDate:_currentMonth inFuture:NO]];
    [self.currentCalendarView setCurrentMonth:_currentMonth];
    [self.nextCalendarView setCurrentMonth:[self dateOneMonthFromDate:_currentMonth inFuture:YES]];

    [self updateHeaderView];
    [self updateHeaderMonthNamesFromDate:_currentMonth];
}

- (void) setHeaderDateFormat: (NSString*) headerDateFormat {
    _headerDateFormat = headerDateFormat;
    [self updateHeaderView];
}

- (void)setButtonsShowMonthName:(BOOL)buttonsShowMonthName {
    _buttonsShowMonthName = buttonsShowMonthName;
    self.headerView.buttonsShowMonthName = buttonsShowMonthName;
}

- (void)updateHeaderView {
    NSDateFormatter * df = [[NSDateFormatter alloc] init];
    [df setLocale: [NSLocale currentLocale]];
    [df setDateFormat:self.headerDateFormat ?: @"MMMM yyyy"];

    [self.headerView setTitleText:[[df stringFromDate:self.currentMonth] capitalizedString]];
    [self.headerView setNextTitleText:[[df stringFromDate:[self dateOneMonthFromDate:self.currentMonth inFuture:YES]] capitalizedString]];
    [self.headerView setPrevTitleText:[[df stringFromDate:[self dateOneMonthFromDate:self.currentMonth inFuture:NO]] capitalizedString]];

    df.dateFormat = @"MMMM";
}

- (void)updateHeaderMonthNamesFromDate: (NSDate *) date {
    NSDateFormatter * df = [[NSDateFormatter alloc] init];
    [df setLocale: [NSLocale currentLocale]];
    df.dateFormat = @"MMMM";
    
    self.headerView.prevMonthName = [[df stringFromDate:[self dateOneMonthFromDate:date inFuture:NO]] capitalizedString];
    self.headerView.nextMonthName = [[df stringFromDate:[self dateOneMonthFromDate:date inFuture:YES]] capitalizedString];
}

- (void)animateToNextMonth {
    [self addSubview:self.nextCalendarView];
    [self.nextCalendarView updateDateSelection];

    SHPCalendarPickerCalendarView *temp = self.currentCalendarView;
    self.currentCalendarView = self.nextCalendarView;
    self.nextCalendarView = self.prevCalendarView;
    self.prevCalendarView = temp;

    [self bringSubviewToFront:self.currentCalendarView];

    [self setNeedsLayout];

    NSDate *nextMonth = [self dateOneMonthFromDate:self.currentMonth inFuture:YES];
    [self updateHeaderMonthNamesFromDate:nextMonth];
    
    [self.headerView setUserInteractionEnabled:NO];
    [UIView animateWithDuration:.4f delay:0.0f usingSpringWithDamping:0.8f initialSpringVelocity:0.0f options:UIViewAnimationOptionTransitionNone animations:^{
        [self layoutIfNeeded];
    } completion:^(BOOL finished) {
        [self.prevCalendarView removeFromSuperview];
        [self.headerView setUserInteractionEnabled:YES];
        self.currentMonth = nextMonth;
    }];

    [self.headerView animateToNextMonthName];
}

- (void)animateToPrevMonth {
    [self addSubview:self.prevCalendarView];
    [self.prevCalendarView updateDateSelection];

    [self addSubview:self.prevCalendarView];
    SHPCalendarPickerCalendarView *temp = self.currentCalendarView;
    self.currentCalendarView = self.prevCalendarView;
    self.prevCalendarView = self.nextCalendarView;
    self.nextCalendarView = temp;

    [self bringSubviewToFront:self.currentCalendarView];

    [self setNeedsLayout];

    NSDate *prevMonth = [self dateOneMonthFromDate:self.currentMonth inFuture:NO];
    [self updateHeaderMonthNamesFromDate:prevMonth];
    
    [self.headerView setUserInteractionEnabled:NO];
    [UIView animateWithDuration:.4f delay:0.0f usingSpringWithDamping:0.8f initialSpringVelocity:0.0f options:UIViewAnimationOptionTransitionNone animations:^{
        [self layoutIfNeeded];
    } completion:^(BOOL finished) {
        [self.nextCalendarView removeFromSuperview];
        [self.headerView setUserInteractionEnabled:YES];
        self.currentMonth = prevMonth;
    }];

    [self.headerView animateToPrevMonthName];
}

#pragma mark - SHPCalendarPickerWeekDayHeaderView

- (void)didSelectNextMonthForCalendarPickerWeekDayHeaderView:(SHPCalendarPickerWeekDayHeaderView *)calendarPickerWeekDayHeaderView {
    [self animateToNextMonth];
}

- (void)didSelectPrevMonthForCalendarPickerWeekDayHeaderView:(SHPCalendarPickerWeekDayHeaderView *)calendarPickerWeekDayHeaderView {
    [self animateToPrevMonth];
}

- (void)didSelectCurrentMonthForCalendarPickerWeekDayHeaderView:(SHPCalendarPickerWeekDayHeaderView *)calendarPickerWeekDayHeaderView {
    NSDate *newDate = [NSDate date];
    if ([self.delegate respondsToSelector:@selector(calendarPickerView:willChangeToMonth:)]) {
        [self.delegate calendarPickerView:self willChangeToMonth:newDate];
    }

    self.currentMonth = newDate;

    if ([self.delegate respondsToSelector:@selector(calendarPickerView:didChangeToMonth:)]) {
        [self.delegate calendarPickerView:self didChangeToMonth:newDate];
    }
}

- (NSDate *)dateOneMonthFromDate:(NSDate *)date inFuture:(BOOL)future {
    NSDateComponents *components = [[NSDateComponents alloc] init];
    components.month = 1;
    if (future) {
        components.month = 1;
    } else {
        components.month = -1;
    }

    return [[NSCalendar currentCalendar] dateByAddingComponents:components toDate:date options:0];
}

#pragma mark - SHPCalendarPickerCalendarViewDelegate

- (void)calendarPickerCalendarView:(SHPCalendarPickerCalendarView *)calendarPickerCalendarView didSelectDate:(NSDate *)date {
    BOOL disableDate = NO;
    if (self.disableDateBlock) {
        disableDate = self.disableDateBlock(date);
    }

    if (!disableDate) {
        NSString *identifier = [self identifierForDate:date];
//        BOOL containsDate = self.selectedDatesDictionary[identifier] != nil;

        if (self.selectionMode == SHPCalendarPickerViewSelectionModeSingle) {
            [self.selectedDatesDictionary removeAllObjects];
        }

        self.selectedDatesDictionary[identifier] = date;

        [self willChangeValueForKey:@"selectedDates"];
        _selectedDates = self.selectedDatesDictionary.allValues;
        [self didChangeValueForKey:@"selectedDates"];

        if ([self.delegate respondsToSelector:@selector(calendarPickerView:didSelectDate:)]) {
            [self.delegate calendarPickerView:self didSelectDate:date];
        }
    }

    NSDateComponents *currentMonthComponents = [self.calendar components:NSMonthCalendarUnit|NSYearCalendarUnit fromDate:calendarPickerCalendarView.currentMonth];
    NSDateComponents *cellDateComponents = [self.calendar components:NSMonthCalendarUnit|NSYearCalendarUnit fromDate:date];
    if (currentMonthComponents.month!=cellDateComponents.month) { //|| containsDate
        BOOL isFuture = (cellDateComponents.year == currentMonthComponents.year && cellDateComponents.month > currentMonthComponents.month) ||
                (cellDateComponents.year > currentMonthComponents.year);

        if (isFuture) {
            [self animateToNextMonth];
        } else {
            [self animateToPrevMonth];
        }
    }


}

- (void)calendarPickerCalendarView:(SHPCalendarPickerCalendarView *)calendarPickerCalendarView didDeselectDate:(NSDate *)date {
    NSString *identifier = [self identifierForDate:date];
    [self.selectedDatesDictionary removeObjectForKey:identifier];

    [self willChangeValueForKey:@"selectedDates"];
    _selectedDates = self.selectedDatesDictionary.allValues;
    [self didChangeValueForKey:@"selectedDates"];


    if ([self.delegate respondsToSelector:@selector(calendarPickerView:didDeselectDate:)]) {
        [self.delegate calendarPickerView:self didDeselectDate:date];
    }
}

- (NSDictionary *)selectedDatesDictionaryForCalendarPickerCalendarView:(SHPCalendarPickerCalendarView *)calendarPickerCalendarView {
    return self.selectedDatesDictionary;
}

#pragma mark - Helpers

- (NSString *)identifierForDate:(NSDate *)date {
    NSDateComponents *dateComponents = [self.calendar components:NSDayCalendarUnit|NSMonthCalendarUnit|NSYearCalendarUnit fromDate:date];
    return [NSString stringWithFormat:@"%d%d%d", dateComponents.day, dateComponents.month, dateComponents.year];
}

#pragma mark - Properties

- (SHPCalendarPickerWeekDayHeaderView *)headerView {
    if (!_headerView) {
        _headerView = [SHPCalendarPickerWeekDayHeaderView new];
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setCalendar:self.calendar];
        NSArray * weekdays = [dateFormatter shortWeekdaySymbols];
        weekdays = [[weekdays arrayByAddingObject:[weekdays firstObject]] subarrayWithRange:NSMakeRange(1, weekdays.count)];
        [_headerView setWeekDayNames:weekdays];
        _headerView.delegate = self;
    }
    return _headerView;
}

- (SHPCalendarPickerCalendarView *)prevCalendarView {
    if (!_prevCalendarView) {
        _prevCalendarView = [SHPCalendarPickerCalendarView new];
        _prevCalendarView.delegate = self;
    }
    return _prevCalendarView;
}

- (SHPCalendarPickerCalendarView *)currentCalendarView {
    if (!_currentCalendarView) {
        _currentCalendarView = [SHPCalendarPickerCalendarView new];
        _currentCalendarView.delegate = self;
    }
    return _currentCalendarView;
}

- (SHPCalendarPickerCalendarView *)nextCalendarView {
    if (!_nextCalendarView) {
        _nextCalendarView = [SHPCalendarPickerCalendarView new];
        _nextCalendarView.delegate = self;
    }
    return _nextCalendarView;
}

- (NSCalendar *)calendar {
    if (!_calendar) {
        _calendar = [NSCalendar currentCalendar];
        [_calendar setFirstWeekday:2]; // Weekday should start on monday

        [self.prevCalendarView setCalendar:_calendar];
        [self.currentCalendarView setCalendar:_calendar];
        [self.nextCalendarView setCalendar:_calendar];
    }
    return _calendar;
}

#pragma mark - Setters

- (void)setTextFont:(UIFont *)textFont {
    _textFont = textFont;

    self.prevCalendarView.textFont = textFont;
    self.currentCalendarView.textFont = textFont;
    self.nextCalendarView.textFont = textFont;
}

- (void)setCircleSelectedColor:(UIColor *)circleSelectedColor {
    _circleSelectedColor = circleSelectedColor;

    self.prevCalendarView.circleSelectedColor = circleSelectedColor;
    self.currentCalendarView.circleSelectedColor = circleSelectedColor;
    self.nextCalendarView.circleSelectedColor = circleSelectedColor;
}

- (void)setTextColor:(UIColor *)textColor {
    _textColor = textColor;

    self.prevCalendarView.textColor = textColor;
    self.currentCalendarView.textColor = textColor;
    self.nextCalendarView.textColor = textColor;
}

- (void)setTextTodayColor:(UIColor *)textTodayColor {
    _textTodayColor = textTodayColor;

    self.prevCalendarView.textTodayColor = textTodayColor;
    self.currentCalendarView.textTodayColor = textTodayColor;
    self.nextCalendarView.textTodayColor = textTodayColor;
}

- (void)setTextSelectedColor:(UIColor *)textSelectedColor {
    _textSelectedColor = textSelectedColor;

    self.prevCalendarView.textSelectedColor = textSelectedColor;
    self.currentCalendarView.textSelectedColor = textSelectedColor;
    self.nextCalendarView.textSelectedColor = textSelectedColor;
}

- (void)setTextDistantColor:(UIColor *)textDistantColor {
    _textDistantColor = textDistantColor;

    self.prevCalendarView.textDistantColor = textDistantColor;
    self.currentCalendarView.textDistantColor = textDistantColor;
    self.nextCalendarView.textDistantColor = textDistantColor;
}

- (void)setCircleDefaultColor:(UIColor *)circleDefaultColor {
    _circleDefaultColor = circleDefaultColor;

    self.prevCalendarView.circleDefaultColor = circleDefaultColor;
    self.currentCalendarView.circleDefaultColor = circleDefaultColor;
    self.nextCalendarView.circleDefaultColor = circleDefaultColor;
}

- (void)setCircleHighlightedColor:(UIColor *)circleHighlightedColor {
    _circleHighlightedColor = circleHighlightedColor;

    self.prevCalendarView.circleHighlightedColor = circleHighlightedColor;
    self.currentCalendarView.circleHighlightedColor = circleHighlightedColor;
    self.nextCalendarView.circleHighlightedColor = circleHighlightedColor;
}

- (void)setCircleTodayColor:(UIColor *)circleTodayColor {
    _circleTodayColor = circleTodayColor;

    self.prevCalendarView.circleTodayColor = circleTodayColor;
    self.currentCalendarView.circleTodayColor = circleTodayColor;
    self.nextCalendarView.circleTodayColor = circleTodayColor;
}

- (void)setTextHighlightedColor:(UIColor *)textHighlightedColor {
    _textHighlightedColor = textHighlightedColor;

    self.prevCalendarView.textHighlightedColor = textHighlightedColor;
    self.currentCalendarView.textHighlightedColor = textHighlightedColor;
    self.nextCalendarView.textHighlightedColor = textHighlightedColor;
}

- (void)setWeekDayHeaderTextColor:(UIColor *)weekDayHeaderTextColor {
    _weekDayHeaderTextColor = weekDayHeaderTextColor;

    self.headerView.weekDayDefaultColor = weekDayHeaderTextColor;
}

- (void)setWeekDayHeaderFont:(UIFont *)weekDayHeaderFont {
    _weekDayHeaderFont = weekDayHeaderFont;

    self.headerView.weekDayDefaultFont = weekDayHeaderFont;
}

- (void)setWeekDayHeaderBackgroundColor:(UIColor *)weekDayHeaderBackgroundColor {
    _weekDayHeaderBackgroundColor = weekDayHeaderBackgroundColor;

    self.headerView.backgroundColor = weekDayHeaderBackgroundColor;
}

- (void)setMonthTextColor:(UIColor *)monthTextColor {
    _monthTextColor = monthTextColor;

    self.headerView.monthDefaultColor = monthTextColor;
}

- (void)setMonthFont:(UIFont *)monthFont {
    _monthFont = monthFont;

    self.headerView.monthDefaultFont = monthFont;
}

- (void)setButtonFont:(UIFont *)buttonFont {
    _buttonFont = buttonFont;
    self.headerView.buttonDefaultFont = buttonFont;
}

- (void)setButtonTextColor:(UIColor *)buttonTextColor {
    _buttonTextColor = buttonTextColor;
    self.headerView.buttonDefaultColor = buttonTextColor;
}

- (void)setNextButtonTintColor:(UIColor *)nextButtonTintColor {
    _nextButtonTintColor = nextButtonTintColor;

    self.headerView.nextButtonTintColor = nextButtonTintColor;
}

- (void)setPrevButtonTintColor:(UIColor *)prevButtonTintColor {
    _prevButtonTintColor = prevButtonTintColor;

    self.headerView.prevButtonTintColor = prevButtonTintColor;
}

- (void)setNextButtonImage:(UIImage *)nextButtonImage {
    _nextButtonImage = nextButtonImage;

    self.headerView.nextButtonImage = nextButtonImage;
}

- (void)setPrevButtonImage:(UIImage *)prevButtonImage {
    _prevButtonImage = prevButtonImage;

    self.headerView.prevButtonImage = prevButtonImage;
}

- (void)setDisableDateBlock:(BOOL (^)(NSDate *))disableDateBlock {
    _disableDateBlock = disableDateBlock;
    
    self.currentCalendarView.disableDateBlock = disableDateBlock;
    self.prevCalendarView.disableDateBlock = disableDateBlock;
    self.nextCalendarView.disableDateBlock = disableDateBlock;
}

- (void)setPrevButtonHorizontalOffset:(CGFloat)prevButtonHorizontalOffset {
    _prevButtonHorizontalOffset = prevButtonHorizontalOffset;
    self.headerView.prevButtonHorizontalOffset = prevButtonHorizontalOffset;
}

- (void)setNextButtonHorizontalOffset:(CGFloat)nextButtonHorizontalOffset {
    _nextButtonHorizontalOffset = nextButtonHorizontalOffset;
    self.headerView.nextButtonHorizontalOffset = nextButtonHorizontalOffset;
}

@end