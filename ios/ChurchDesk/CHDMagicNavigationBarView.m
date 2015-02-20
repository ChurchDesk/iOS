//
//  CHDMagicNavigationBarView.m
//  ChurchDesk
//
//  Created by Mikkel Selsøe Sørensen on 19/02/15.
//  Copyright (c) 2015 Shape A/S. All rights reserved.
//

#import "CHDMagicNavigationBarView.h"

static CGFloat kDrawerHeight = 44.0f;
static CGFloat kCollapsedHeight = 64.0f;
static CGFloat kExpandedHeight = 108.0f;

@interface CHDMagicNavigationBarView ()

@property (nonatomic, strong) UIView *drawerView;
@property (nonatomic, strong) UIView *snapshotContainerView;

@property (nonatomic, strong) MASConstraint *drawerHeightConstraint;
@property (nonatomic, strong) MASConstraint *containerTopConstraint;
@property (nonatomic, weak) UINavigationController *navigationController;

@end

@implementation CHDMagicNavigationBarView

- (instancetype)initWithNavigationController: (UINavigationController*) navigationController {
    self = [super init];
    if (self) {
        self.backgroundColor = [UIColor chd_blueColor];
        self.navigationController = navigationController;
        
//        self.layer.masksToBounds = NO;
//        self.layer.shadowOffset = CGSizeMake(0, 1);
//        self.layer.shadowRadius = 1;
//        self.layer.shadowOpacity = 0.5;
        
        [self setupSubviews];
        [self makeConstraints];
        [self setupBindings];
    }
    return self;
}

- (void) setupSubviews {
    [self addSubview:self.snapshotContainerView];
    [self addSubview:self.drawerView];
}

- (void) makeConstraints {
    [self.drawerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self);
        make.top.equalTo(self).offset(20);
        self.drawerHeightConstraint = make.height.equalTo(@0);
    }];
    
    [self.snapshotContainerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.equalTo(self);
        self.containerTopConstraint = make.top.equalTo(self).offset(20);
    }];
}

- (void) setupBindings {
    UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] init];
    [self.snapshotContainerView addGestureRecognizer:tapRecognizer];
    
    [self rac_liftSelector:@selector(setShowDrawer:animated:) withSignals:[tapRecognizer.rac_gestureSignal mapReplace:@NO], [RACSignal return:@YES], nil];
}

- (void)setShowDrawer:(BOOL)showDrawer {
    [self setShowDrawer:showDrawer animated:NO];
}

- (void)setShowDrawer:(BOOL)showDrawer animated:(BOOL)animated {
    [self willChangeValueForKey:@"showDrawer"];
    _showDrawer = showDrawer;
    [self didChangeValueForKey:@"showDrawer"];
    
    if (showDrawer) {
        [self showDrawerAnimated:animated];
    }
    else {
        [self hideDrawerAnimated:animated];
    }
}

- (void)setTopConstraint:(MASConstraint *)topConstraint {
    _topConstraint = topConstraint;
    [_topConstraint setOffset:self.showDrawer ? 0 : -kCollapsedHeight];
}

- (void) showDrawerAnimated: (BOOL) animated {
    [self.topConstraint setOffset:0];
    self.navigationController.navigationBarHidden = YES;
    [self layoutIfNeeded];
    
    [self.drawerHeightConstraint setOffset:kDrawerHeight];
    [self.containerTopConstraint setOffset:20 + kDrawerHeight];
    [self invalidateIntrinsicContentSize];
    
    [UIView animateWithDuration: animated ? 0.4 : 0 delay:0 usingSpringWithDamping:0.8 initialSpringVelocity:1.0 options:0 animations:^{
        [self.superview layoutIfNeeded];
    } completion:nil];
}

- (void) hideDrawerAnimated: (BOOL) animated {

    [self.drawerHeightConstraint setOffset:0];
    [self.containerTopConstraint setOffset:20];
    [self invalidateIntrinsicContentSize];
    
    [UIView animateWithDuration: animated ? 0.4 : 0 delay:0 usingSpringWithDamping:0.8 initialSpringVelocity:1.0 options:0 animations:^{
        [self.superview layoutIfNeeded];
    } completion:^(BOOL finished) {
        [self.topConstraint setOffset:-kCollapsedHeight];
        self.navigationController.navigationBarHidden = NO;
        [self layoutIfNeeded];
    }];
}

- (CGSize)intrinsicContentSize {
    return CGSizeMake(0, self.showDrawer ? kExpandedHeight : kCollapsedHeight);
}

#pragma mark - Private

- (void) takeSnapshot {
    UIView *snapshotView = [self.navigationController.navigationBar snapshotViewAfterScreenUpdates:NO];
    [self.snapshotContainerView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [self.snapshotContainerView addSubview:snapshotView];
    [snapshotView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.snapshotContainerView);
    }];
}

#pragma mark - Lazy Initialization

- (UIView *)drawerView {
    if (!_drawerView) {
        _drawerView = [UIView new];
        _drawerView.backgroundColor = [UIColor chd_darkBlueColor];
    }
    return _drawerView;
}

- (UIView *)snapshotContainerView {
    if (!_snapshotContainerView) {
        _snapshotContainerView = [UIView new];
    }
    return _snapshotContainerView;
}

@end
