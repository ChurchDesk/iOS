//
//  CHDAccessoryTableViewCell.m
//  ChurchDesk
//
//  Created by Jakob Vinther-Larsen on 23/02/15.
//  Copyright (c) 2015 Shape A/S. All rights reserved.
//

#import "CHDAccessoryTableViewCell.h"

@interface CHDAccessoryTableViewCell()
@property (nonatomic, strong) NSMutableArray *accessoryButtons;
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIView *scrollContentViewWithOffset;
@property (nonatomic, strong) UIView *scrollContentView;
@property (nonatomic, strong) UIView *accessoryButtonView;

@property CGFloat accessoryRightWidth;
@property (nonatomic, strong) MASConstraint* scrollContentViewWithOffsetSizeConstraint;

@end

@implementation CHDAccessoryTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if ((self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;

        self.scrollView.userInteractionEnabled = NO;
        [self.contentView addGestureRecognizer:self.scrollView.panGestureRecognizer];

        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapped:)];
        [self.contentView addGestureRecognizer:tapGesture];
        tapGesture.delegate = self;

        self.accessoryEnabled = YES;

        RAC(self.scrollView, scrollEnabled) = RACObserve(self, accessoryEnabled);
    }
    return self;
}

#pragma mark - lazy initialization

- (void) makeViews {
    [super makeViews];
    UIView *contentView = self.contentView;

    [contentView addSubview:self.accessoryButtonView];
    [contentView addSubview:self.scrollView];
    [self.scrollView addSubview:self.scrollContentViewWithOffset];
    [self.scrollContentViewWithOffset addSubview:self.scrollContentView];

    //Replace the leftBorder
    [self.cellBackgroundView removeFromSuperview];
    [self.scrollContentView addSubview:self.cellBackgroundView];
}

-(void) makeConstraints {
    [super makeConstraints];

    [self.scrollView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.contentView);
    }];

    [self.accessoryButtonView mas_makeConstraints:^(MASConstraintMaker *make) {
       make.edges.equalTo(self.contentView);
    }];

    //Set reference for the size constraint
    //This will be updated when accessory is added
    [self.scrollContentViewWithOffset mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.scrollView);
        self.scrollContentViewWithOffsetSizeConstraint = make.size.equalTo(self.contentView);
    }];

    [self.scrollContentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.equalTo(self.contentView);
        make.left.top.bottom.equalTo(self.scrollContentViewWithOffset);
    }];

    //Clear out old constraints
    //[self.leftBorder removeConstraints:self.leftBorder.constraints];
    [self.cellBackgroundView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.scrollContentView);
    }];
}

#pragma mark - Accessory

-(void) setAccessoryWithTitles: (NSArray*) buttonTitles backgroundColors: (NSArray*) buttonColors buttonWidth:(CGFloat) btnWidth {
    //Clear out all subviews
    [self.accessoryButtonView.subviews enumerateObjectsUsingBlock:^(UIView * subView, NSUInteger idx, BOOL *stop) {
        [subView removeFromSuperview];
    }];

    self.accessoryButtons = [NSMutableArray new];
    CGFloat buttonWidth = btnWidth;

    self.accessoryRightWidth = buttonWidth * buttonTitles.count;
    [self.scrollContentViewWithOffsetSizeConstraint setSizeOffset:CGSizeMake(self.accessoryRightWidth, 0)];

    [buttonTitles enumerateObjectsUsingBlock:^(NSString* buttonTitle, NSUInteger idx, BOOL *stop) {
        UIButton* button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.titleLabel.font = [UIFont chd_fontWithFontWeight:CHDFontWeightRegular size:16];
        button.titleLabel.textColor = [UIColor whiteColor];
        button.titleLabel.textAlignment = NSTextAlignmentCenter;
        button.titleLabel.numberOfLines = 0;
        button.titleEdgeInsets = UIEdgeInsetsMake(0, 5, 0, 5);
        [button setBackgroundColor:buttonColors[idx]];
        [button setTitle:buttonTitle forState:UIControlStateNormal];

        UIView* buttonStretch = [UIView new];
        buttonStretch.backgroundColor = button.backgroundColor;

        [self.accessoryButtonView addSubview:buttonStretch];
        [self.accessoryButtonView addSubview:button];

        __block MASConstraint* buttonRight;

        [button mas_makeConstraints:^(MASConstraintMaker *make) {
            buttonRight = make.left.equalTo(self.accessoryButtonView.mas_right);
            make.top.bottom.equalTo(self.accessoryButtonView);
            make.width.equalTo(@(buttonWidth));
        }];

        [buttonStretch mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.bottom.equalTo(button);
            make.left.equalTo(button.mas_right);
            make.width.equalTo(button);
        }];

        RAC(buttonRight, offset) = [RACObserve(self.scrollView, contentOffset) map:^id(NSValue* offset) {
            CGFloat percentOfWidth = (CGFloat)offset.CGPointValue.x / self.accessoryRightWidth;
            CGFloat offsetX = -(self.accessoryRightWidth - (buttonWidth * idx)) * percentOfWidth;
            return @(offsetX);
        }];

        [self.accessoryButtons addObject:button];
    }];
}

-(void) closeAccessoryAnimated: (BOOL) animated {
    NSTimeInterval animateDuration = (animated)? 0.2 : 0;

    [UIView animateWithDuration:animateDuration delay:0 usingSpringWithDamping:0.8 initialSpringVelocity:0.0 options:0 animations:^{
        self.scrollView.contentOffset = CGPointZero;
    } completion:nil];
}

-(void) openAccessoryAnimated: (BOOL) animated {
    NSTimeInterval animateDuration = (animated)? 0.2 : 0;

    [UIView animateWithDuration:animateDuration delay:0 usingSpringWithDamping:0.8 initialSpringVelocity:0.0 options:0 animations:^{
        self.scrollView.contentOffset = CGPointMake(self.accessoryRightWidth, 0);
    } completion:nil];
}

#pragma mark - lazy initialization

-(UIScrollView*) scrollView {
    if(!_scrollView){
        _scrollView = [UIScrollView new];
        _scrollView.showsHorizontalScrollIndicator = NO;
        _scrollView.showsVerticalScrollIndicator = NO;
        _scrollView.alwaysBounceVertical = NO;
        _scrollView.delegate = self;
        _scrollView.decelerationRate = UIScrollViewDecelerationRateFast;
    }
    return _scrollView;
}


-(UIView*) scrollContentViewWithOffset{
    if(!_scrollContentViewWithOffset){
        _scrollContentViewWithOffset = [UIView new];
    }
    return _scrollContentViewWithOffset;
}

-(UIView*) scrollContentView{
    if(!_scrollContentView){
        _scrollContentView = [UIView new];
    }
    return _scrollContentView;
}

-(UIView*) accessoryButtonView{
    if(!_accessoryButtonView){
        _accessoryButtonView = [UIView new];
    }
    return _accessoryButtonView;
}

#pragma mark - TableViewCell Delegates
- (void)prepareForReuse {
    [self closeAccessoryAnimated:NO];
    self.accessoryEnabled = YES;
}

#pragma mark - Gestures
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    return !CGPointEqualToPoint(CGPointZero, self.scrollView.contentOffset);
}


#pragma mark - ScrollView delegate
-(void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset {
    if(velocity.x > 0){
        *targetContentOffset = CGPointMake(self.accessoryRightWidth, 0);
    }else if(velocity.x < 0){
        *targetContentOffset = CGPointMake(0, 0);
    }else{
        if (scrollView.contentOffset.x >= self.accessoryRightWidth/2) {
            *targetContentOffset = CGPointMake(self.accessoryRightWidth, 0);
        }
        else {
            *targetContentOffset = CGPointMake(0, 0);
        }
    }
}

- (void) tapped: (id) sender {
    [UIView animateWithDuration:0.2 delay:0 usingSpringWithDamping:0.8 initialSpringVelocity:0.0 options:0 animations:^{
        self.scrollView.contentOffset = CGPointZero;
    } completion:nil];
}

@end
