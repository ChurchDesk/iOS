//
//  Created by Peter Gammelgaard on 20/10/14.
//  Copyright (c) 2014 SHAPE A/S. All rights reserved.
//

#import "SHPCalendarPickerWeekDayHeaderView.h"
#import "SHPCalendarPickerLayouter.h"

static const int NumberOfWeekDays = 7;

@interface SHPCalendarPickerWeekDayHeaderView ()
@property (nonatomic, strong) NSArray *weekDayLabels;
@property (nonatomic, strong) UILabel *currentMonthLabel;
@property (nonatomic, strong) UIButton *nextButton;
@property (nonatomic, strong) UIButton *nextTitleButton;
@property (nonatomic, strong) UIButton *prevButton;
@property (nonatomic, strong) UIButton *prevTitleButton;
@property (nonatomic, strong) UILabel *nextMonthLabel;
@property (nonatomic, strong) UILabel *prevMonthLabel;
@property(nonatomic, strong) UITapGestureRecognizer *tapGestureRecognizer;
@property(nonatomic, strong) NSLayoutConstraint *currentMonthLabelConstraint;
@property(nonatomic, strong) NSLayoutConstraint *nextMonthLabelConstraint;
@property(nonatomic, strong) NSLayoutConstraint *prevMonthLabelConstraint;
@property(nonatomic, strong) NSLayoutConstraint *nextMonthButtonConstraint;
@property(nonatomic, strong) NSLayoutConstraint *prevMonthButtonConstraint;

@end

@implementation SHPCalendarPickerWeekDayHeaderView {

}

+ (void)initialize {
    [[SHPCalendarPickerWeekDayHeaderView appearance] setPrevButtonTintColor:[UIColor grayColor]];
    [[SHPCalendarPickerWeekDayHeaderView appearance] setNextButtonTintColor:[UIColor grayColor]];
    [[SHPCalendarPickerWeekDayHeaderView appearance] setPrevButtonImage:[[UIImage imageNamed:@"SHPCalendarPickerResources.bundle/images/shp_calendar_picker_prev_button"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]];
    [[SHPCalendarPickerWeekDayHeaderView appearance] setNextButtonImage:[[UIImage imageNamed:@"SHPCalendarPickerResources.bundle/images/shp_calendar_picker_next_button"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]];
    [[SHPCalendarPickerWeekDayHeaderView appearance] setWeekDayDefaultColor:[UIColor blackColor]];
    [[SHPCalendarPickerWeekDayHeaderView appearance] setWeekDayDefaultFont:[UIFont systemFontOfSize:15.0]];
    [[SHPCalendarPickerWeekDayHeaderView appearance] setMonthDefaultColor:[UIColor grayColor]];
    [[SHPCalendarPickerWeekDayHeaderView appearance] setMonthDefaultFont:[UIFont boldSystemFontOfSize:18.0]];
    [[SHPCalendarPickerWeekDayHeaderView appearance] setBackgroundColor:[UIColor colorWithRed:241.f/255.f green:241.f/255.f blue:241.f/255.f alpha:1.f]];
    [[SHPCalendarPickerWeekDayHeaderView appearance] setButtonDefaultColor:[UIColor blackColor]];
    [[SHPCalendarPickerWeekDayHeaderView appearance] setButtonDefaultFont:[UIFont systemFontOfSize:18.0]];
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self addSubviews];
        [self setupConstraints];

        [self.nextButton addTarget:self action:@selector(nextPressed) forControlEvents:UIControlEventTouchUpInside];
        [self.prevButton addTarget:self action:@selector(prevPressed) forControlEvents:UIControlEventTouchUpInside];
        [self.nextTitleButton addTarget:self action:@selector(nextPressed) forControlEvents:UIControlEventTouchUpInside];
        [self.prevTitleButton addTarget:self action:@selector(prevPressed) forControlEvents:UIControlEventTouchUpInside];

        self.tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(monthLabelPressed)];
        [self.currentMonthLabel addGestureRecognizer:self.tapGestureRecognizer];

        self.prevButtonTintColor = [[SHPCalendarPickerWeekDayHeaderView appearance] prevButtonTintColor];
        self.nextButtonTintColor = [[SHPCalendarPickerWeekDayHeaderView appearance] nextButtonTintColor];
        self.prevButtonImage = [[SHPCalendarPickerWeekDayHeaderView appearance] prevButtonImage];
        self.nextButtonImage = [[SHPCalendarPickerWeekDayHeaderView appearance] nextButtonImage];
        self.weekDayDefaultColor = [[SHPCalendarPickerWeekDayHeaderView appearance] weekDayDefaultColor];
        self.weekDayDefaultFont = [[SHPCalendarPickerWeekDayHeaderView appearance] weekDayDefaultFont];
        self.monthDefaultColor = [[SHPCalendarPickerWeekDayHeaderView appearance] monthDefaultColor];
        self.monthDefaultFont = [[SHPCalendarPickerWeekDayHeaderView appearance] monthDefaultFont];
        self.backgroundColor = [[SHPCalendarPickerWeekDayHeaderView appearance] backgroundColor];
        self.buttonDefaultFont = [[SHPCalendarPickerWeekDayHeaderView appearance] buttonDefaultFont];
        self.buttonDefaultColor = [[SHPCalendarPickerWeekDayHeaderView appearance] buttonDefaultColor];
    }

    return self;
}

- (void)setupConstraints {
    [[self layoutForView:self.prevButton].centerY.equal toView:self.currentMonthLabel offset:0];
    [[self layoutForView:self.prevButton].width.equal toValue:50];
    [[self layoutForView:self.prevButton].height.equal toValue:30];
    self.prevMonthButtonConstraint = [[self layoutForView:self.prevButton].left.equal toView:self offset:0][0];

    self.nextMonthButtonConstraint = [[self layoutForView:self.nextButton].right.equal toView:self offset:0][0];
    [[self layoutForView:self.nextButton].centerY.equal toView:self.currentMonthLabel offset:0];
    [[self layoutForView:self.nextButton].width.equal toValue:50];
    [[self layoutForView:self.nextButton].height.equal toValue:30];

    [[self layoutForView:self.nextTitleButton].right.equal toAttributes:[self layoutForView:self.nextButton].left offset:20];
    [[self layoutForView:self.nextTitleButton].baseline.equal toView:self.currentMonthLabel offset:0];
    [[self layoutForView:self.prevTitleButton].left.equal toAttributes:[self layoutForView:self.prevButton].right offset:-20];
    [[self layoutForView:self.prevTitleButton].baseline.equal toView:self.currentMonthLabel offset:0];
    
    [[self layoutForView:self.currentMonthLabel].top.equal toView:self offset:16];
    [[self layoutForView:self.currentMonthLabel].height.greaterThanOrEqual toValue:20];
    self.currentMonthLabelConstraint = [[self layoutForView:self.currentMonthLabel].centerX.equal toView:self offset:0][0];

    [[self layoutForView:self.nextMonthLabel].top.equal toView:self offset:16];
    [[self layoutForView:self.nextMonthLabel].height.greaterThanOrEqual toValue:20];
    self.nextMonthLabelConstraint = [[self layoutForView:self.nextMonthLabel].centerX.equal toView:self offset:0][0];

    [[self layoutForView:self.prevMonthLabel].top.equal toView:self offset:16];
    [[self layoutForView:self.prevMonthLabel].height.greaterThanOrEqual toValue:20];
    self.prevMonthLabelConstraint = [[self layoutForView:self.prevMonthLabel].centerX.equal toView:self offset:0][0];

    __block UIView *lastView = nil;
    [self.weekDayLabels enumerateObjectsUsingBlock:^(UILabel *weekDayLabel, NSUInteger idx, BOOL *stop) {
        if (lastView) {
            [[self layoutForView:weekDayLabel].left.equal toAttributes:[self layoutForView:lastView].right];
            [[self layoutForView:weekDayLabel].width.equal toView:lastView];
        } else {
            [[self layoutForView:weekDayLabel].left.equal toView:self];
        }
        [[self layoutForView:weekDayLabel].top.equal toAttributes:[self layoutForView:self.currentMonthLabel].bottom offset:12];

        lastView = weekDayLabel;
    }];

    [[self layoutForView:lastView].right.equal toView:self];
}

- (void)monthLabelPressed {
    [self.delegate didSelectCurrentMonthForCalendarPickerWeekDayHeaderView:self];
}

- (void)prevPressed {
    [self.delegate didSelectPrevMonthForCalendarPickerWeekDayHeaderView:self];
}

- (void)nextPressed {
    [self.delegate didSelectNextMonthForCalendarPickerWeekDayHeaderView:self];
}

- (void)addSubviews {
    [self addSubview:self.currentMonthLabel];
    [self addSubview:self.nextMonthLabel];
    [self addSubview:self.prevMonthLabel];

    [self addSubview:self.nextButton];
    [self addSubview:self.prevButton];
    [self addSubview:self.nextTitleButton];
    [self addSubview:self.prevTitleButton];

    [self.weekDayLabels enumerateObjectsUsingBlock:^(UILabel *weekDayLabel, NSUInteger idx, BOOL *stop) {
        [self addSubview:weekDayLabel];
    }];
}

- (SHPCalendarPickerLayoutAttributes *)layoutForView:(UIView *)view {
    return [[SHPCalendarPickerLayoutAttributes alloc] initWithView:view];
}

- (void)updateConstraints {
    CGFloat width = CGRectGetWidth(self.frame)-40;
    [self.currentMonthLabelConstraint setConstant:0];
    [self.nextMonthLabelConstraint setConstant:width];
    [self.prevMonthLabelConstraint setConstant:-width];

    [super updateConstraints];
}

- (void)setFrame:(CGRect)frame {
    [super setFrame:frame];

    [self setNeedsUpdateConstraints];
}

- (void)setBounds:(CGRect)bounds {
    [super setBounds:bounds];

    [self setNeedsUpdateConstraints];
}

- (void)setTitleText:(NSString *)titleText {
    _titleText = titleText;

    [self.currentMonthLabel setText:titleText];
}

- (void)setNextTitleText:(NSString *)nextTitleText {
    _nextTitleText = nextTitleText;

    [self.nextMonthLabel setText:nextTitleText];
}

- (void)setPrevTitleText:(NSString *)prevTitleText {
    _prevTitleText = prevTitleText;

    [self.prevMonthLabel setText:prevTitleText];
}

- (void)setPrevMonthName:(NSString *)prevMonthName {
    _prevMonthName = prevMonthName;
    [self updateButtonLabels];
}

- (void)setNextMonthName:(NSString *)nextMonthName {
    _nextMonthName = nextMonthName;
    [self updateButtonLabels];
}

- (void)setWeekDayNames:(NSArray *)weekDayNames {
    _weekDayNames = weekDayNames;
    NSAssert(weekDayNames.count == self.weekDayLabels.count, @"Number of week day names must match the number of week day labels");

    [self.weekDayLabels enumerateObjectsUsingBlock:^(UILabel *weekDayLabel, NSUInteger idx, BOOL *stop) {
        weekDayLabel.text = weekDayNames[idx];
    }];
}

#pragma mark - Update

- (void)updateMonthLabelsFont {
    self.currentMonthLabel.font = [self monthDefaultFont];
    self.prevMonthLabel.font = [self monthDefaultFont];
    self.nextMonthLabel.font = [self monthDefaultFont];
}

- (void)updateMonthLabelsColor {
    self.currentMonthLabel.textColor = [self monthDefaultColor];
    self.prevMonthLabel.textColor = [self monthDefaultColor];
    self.nextMonthLabel.textColor = [self monthDefaultColor];
}

- (void)updatePrevButton {
    [self.prevButton setImage:[self prevButtonImage] forState:UIControlStateNormal];
    [self.prevButton setTintColor:[self prevButtonTintColor]];
}

- (void)updateNextButton {
    [self.nextButton setImage:[self nextButtonImage] forState:UIControlStateNormal];
    [self.nextButton setTintColor:[self nextButtonTintColor]];
}

- (void)updateWekDayLabelsFont {
    for (UILabel *label in self.weekDayLabels) {
        label.font = [self weekDayDefaultFont];
    }
}

- (void)updateWekDayLabelsColor {
    for (UILabel *label in self.weekDayLabels) {
        label.textColor = [self weekDayDefaultColor];
    }
}

#pragma mark - Properties

- (UILabel *)currentMonthLabel {
    if (!_currentMonthLabel) {
        _currentMonthLabel = [UILabel new];
        _currentMonthLabel.textAlignment = NSTextAlignmentCenter;
        _currentMonthLabel.font = [self monthDefaultFont];
        _currentMonthLabel.textColor = [self monthDefaultColor];
        [_currentMonthLabel setUserInteractionEnabled:YES];
    }
    return _currentMonthLabel;
}

- (UILabel *)nextMonthLabel {
    if (!_nextMonthLabel) {
        _nextMonthLabel = [UILabel new];
        _nextMonthLabel.textAlignment = NSTextAlignmentCenter;
        _nextMonthLabel.font = [self monthDefaultFont];
        _nextMonthLabel.textColor = [self monthDefaultColor];
        [_nextMonthLabel setUserInteractionEnabled:YES];
    }
    return _nextMonthLabel;
}

- (UILabel *)prevMonthLabel {
    if (!_prevMonthLabel) {
        _prevMonthLabel = [UILabel new];
        _prevMonthLabel.textAlignment = NSTextAlignmentCenter;
        _prevMonthLabel.font = [self monthDefaultFont];
        _prevMonthLabel.textColor = [self monthDefaultColor];
        [_prevMonthLabel setUserInteractionEnabled:YES];
    }
    return _prevMonthLabel;
}

- (UIButton *)nextButton {
    if (!_nextButton) {
        _nextButton = [UIButton new];
        [_nextButton setImage:[self nextButtonImage] forState:UIControlStateNormal];
        [_nextButton setTintColor:[self nextButtonTintColor]];
    }
    return _nextButton;
}

- (UIButton *)prevButton {
    if (!_prevButton) {
        _prevButton = [UIButton new];
        [_prevButton setImage:[self prevButtonImage] forState:UIControlStateNormal];
        [_prevButton setTintColor:[self prevButtonTintColor]];
    }
    return _prevButton;
}

- (UIButton *)prevTitleButton {
    if (!_prevTitleButton) {
        _prevTitleButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _prevTitleButton.hidden = YES;
    }
    return _prevTitleButton;
}

- (UIButton *)nextTitleButton {
    if (!_nextTitleButton) {
        _nextTitleButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _nextTitleButton.hidden = YES;
    }
    return _nextTitleButton;
    
}

- (NSArray *)weekDayLabels {
    if (!_weekDayLabels) {
        NSMutableArray *array = [NSMutableArray new];
        for (NSInteger index = 0; index < NumberOfWeekDays; index++) {
            [array addObject:[self createWeekDayLabel]];
        }

        _weekDayLabels = array;
    }
    return _weekDayLabels;
}

#pragma mark - Setters

- (void)setMonthDefaultFont:(UIFont *)monthDefaultFont {
    _monthDefaultFont = monthDefaultFont;
    [self updateMonthLabelsFont];
}

- (void)setMonthDefaultColor:(UIColor *)monthDefaultColor {
    _monthDefaultColor = monthDefaultColor;
    [self updateMonthLabelsColor];
}

- (void)setWeekDayDefaultFont:(UIFont *)weekDayDefaultFont {
    _weekDayDefaultFont = weekDayDefaultFont;
    [self updateWekDayLabelsFont];
}

- (void)setWeekDayDefaultColor:(UIColor *)weekDayDefaultColor {
    _weekDayDefaultColor = weekDayDefaultColor;
    [self updateWekDayLabelsColor];
}

- (void)setNextButtonImage:(UIImage *)nextButtonImage {
    _nextButtonImage = nextButtonImage;
    [self updateNextButton];
}

- (void)setPrevButtonImage:(UIImage *)prevButtonImage {
    _prevButtonImage = prevButtonImage;
    [self updatePrevButton];
}

- (void)setNextButtonTintColor:(UIColor *)nextButtonTintColor {
    _nextButtonTintColor = nextButtonTintColor;
    [self updateNextButton];
}

- (void)setPrevButtonTintColor:(UIColor *)prevButtonTintColor {
    _prevButtonTintColor = prevButtonTintColor;
    [self updatePrevButton];
}

- (void)setButtonDefaultFont:(UIFont *)buttonDefaultFont {
    _buttonDefaultFont = buttonDefaultFont;
    self.prevTitleButton.titleLabel.font = buttonDefaultFont;
    self.nextTitleButton.titleLabel.font = buttonDefaultFont;
}

- (void)setButtonDefaultColor:(UIColor *)buttonDefaultColor {
    _buttonDefaultColor = buttonDefaultColor;
    [self.prevTitleButton setTitleColor:buttonDefaultColor forState:UIControlStateNormal];
    [self.nextTitleButton setTitleColor:buttonDefaultColor forState:UIControlStateNormal];
}

- (void)setPrevButtonHorizontalOffset:(CGFloat)prevButtonHorizontalOffset {
    [self.prevMonthButtonConstraint setConstant:prevButtonHorizontalOffset];
}

- (void)setNextButtonHorizontalOffset:(CGFloat)nextButtonHorizontalOffset {
    [self.nextMonthButtonConstraint setConstant:nextButtonHorizontalOffset];
}

- (void)setButtonsShowMonthName:(BOOL)buttonsShowMonthName {
    _buttonsShowMonthName = buttonsShowMonthName;
    _nextTitleButton.hidden = NO;
    _prevTitleButton.hidden = NO;
    [self updateButtonLabels];
}

#pragma mark - Helpers

- (UILabel *)createWeekDayLabel {
    UILabel *weekDayLabel = [UILabel new];
    weekDayLabel.textAlignment = NSTextAlignmentCenter;
    weekDayLabel.textColor = [self weekDayDefaultColor];
    weekDayLabel.font = [self weekDayDefaultFont];

    return weekDayLabel;
}

- (SHPCalendarPickerLayoutAttributes *)layout
{
    return [[SHPCalendarPickerLayoutAttributes alloc] initWithView:self];
}

- (void)animateToNextMonthName {
    if ([self.currentMonthLabel.text isEqualToString:self.nextMonthLabel.text]) {
        return;
    }
    
    UILabel *temp = self.currentMonthLabel;
    self.currentMonthLabel = self.nextMonthLabel;
    self.nextMonthLabel = self.prevMonthLabel;
    self.prevMonthLabel = temp;

    NSLayoutConstraint *tempConstraint = self.currentMonthLabelConstraint;
    self.currentMonthLabelConstraint = self.nextMonthLabelConstraint;
    self.nextMonthLabelConstraint = self.prevMonthLabelConstraint;
    self.prevMonthLabelConstraint = tempConstraint;

    [self setNeedsUpdateConstraints];
    [self updateConstraintsIfNeeded];
    
    [self animateMonthLabel:self.prevMonthLabel toMonthLabel:self.currentMonthLabel ignoreMonthLabel:self.nextMonthLabel];

    [self.currentMonthLabel addGestureRecognizer:self.tapGestureRecognizer];
}

- (void)animateToPrevMonthName {
    if ([self.currentMonthLabel.text isEqualToString:self.prevMonthLabel.text]) {
        return;
    }
    
    UILabel *temp = self.currentMonthLabel;
    self.currentMonthLabel = self.prevMonthLabel;
    self.prevMonthLabel = self.nextMonthLabel;
    self.nextMonthLabel = temp;

    NSLayoutConstraint *tempConstraint = self.currentMonthLabelConstraint;
    self.currentMonthLabelConstraint = self.prevMonthLabelConstraint;
    self.prevMonthLabelConstraint = self.nextMonthLabelConstraint;
    self.nextMonthLabelConstraint = tempConstraint;

    [self setNeedsUpdateConstraints];
    [self updateConstraintsIfNeeded];
    
    [self animateMonthLabel:self.nextMonthLabel toMonthLabel:self.currentMonthLabel ignoreMonthLabel:self.prevMonthLabel];

    [self.currentMonthLabel addGestureRecognizer:self.tapGestureRecognizer];
}

- (void)animateMonthLabel:(UILabel *)monthLabel toMonthLabel:(UILabel *)toMonthLabel ignoreMonthLabel:(UILabel *)ignoreMonthLabel {
    toMonthLabel.alpha = 0.0f;
    monthLabel.alpha = 1.0f;
    ignoreMonthLabel.alpha = 0.0f;
    [UIView animateWithDuration:.4f delay:0.0f usingSpringWithDamping:0.8f initialSpringVelocity:0.0f options:UIViewAnimationOptionTransitionNone animations:^{
        [self layoutIfNeeded];
    } completion:^(BOOL finished) {
        toMonthLabel.alpha = 1.0f;
        monthLabel.alpha = 1.0f;
        ignoreMonthLabel.alpha = 1.0f;
    }];

    [UIView animateWithDuration:0.08 delay:0.0f options:UIViewAnimationOptionCurveEaseOut animations:^{
        monthLabel.alpha = 0.0f;
    } completion:^(BOOL finished) {

    }];

    [UIView animateWithDuration:0.3 delay:0.0f options:UIViewAnimationOptionCurveEaseIn animations:^{
        toMonthLabel.alpha = 1.0f;
    } completion:^(BOOL finished) {

    }];
}

- (void) updateButtonLabels {
    [self.prevTitleButton setTitle:self.buttonsShowMonthName ? self.prevMonthName : nil forState:UIControlStateNormal];
    [self.nextTitleButton setTitle:self.buttonsShowMonthName ? self.nextMonthName : nil forState:UIControlStateNormal];
}

@end