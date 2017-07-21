//
// Created by Jakob Vinther-Larsen on 11/03/15.
// Copyright (c) 2015 Shape A/S. All rights reserved.
//

#import "CHDStatusView.h"

@interface CHDStatusView ()
@property (nonatomic, strong) UIVisualEffectView *backgroundView;
@property (nonatomic, strong) UIActivityIndicatorView *spinner;
@property (nonatomic, strong) UILabel *statusLabel;
@property (nonatomic, strong) UIImageView *successImageView;
@property (nonatomic, strong) UIImageView *errorImageView;
@property (nonatomic, strong) UIWindow *parentView;

//Is true when the view is not hidden
@property (nonatomic) BOOL isShown;
@end

@implementation CHDStatusView

- (instancetype)init {
    return [self initWithStatus:CHDStatusViewHidden];
}

- (instancetype)initWithStatus: (CHDStatusViewStatus) status{
    self = [super init];
    if (self){
        self.alpha = 0;

        [self makeViews];
        [self makeConstraints];
        [self makeBindings];

        self.currentStatus = status;
    }
    return self;
}

-(void) makeViews {
    [self addSubview:self.backgroundView];
    [self addSubview:self.spinner];
    [self addSubview:self.statusLabel];
    [self addSubview:self.successImageView];
    [self addSubview:self.errorImageView];
}

-(void) makeConstraints {

    [self.backgroundView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self);
    }];

    [self.spinner mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self);
        make.centerY.equalTo(self.mas_top).offset(230);
    }];

    [self.successImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self);
        make.centerY.equalTo(self.mas_top).offset(230);
    }];

    [self.errorImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self);
        make.centerY.equalTo(self.mas_top).offset(230);
    }];

    [self.statusLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self);
        make.left.greaterThanOrEqualTo(self);
        make.right.lessThanOrEqualTo(self);
        make.bottom.equalTo(self).offset(-100);
    }];
}

-(void) makeBindings {
    RACSignal *statusSignal = RACObserve(self, currentStatus);

    RAC(self.spinner, hidden) = [statusSignal map:^id(NSNumber *iStatus) {
        CHDStatusViewStatus status = iStatus.integerValue;
        return @(status != CHDStatusViewProcessing);
    }];

    RACSignal *startSpinning = [statusSignal filter:^BOOL(NSNumber *iStatus) {
        CHDStatusViewStatus status = iStatus.integerValue;
        return status == CHDStatusViewProcessing;
    }];

    RACSignal *stopSpinning = [statusSignal filter:^BOOL(NSNumber *iStatus) {
        CHDStatusViewStatus status = iStatus.integerValue;
        return status != CHDStatusViewProcessing;
    }];

    [self.spinner shprac_liftSelector:@selector(startAnimating) withSignal:startSpinning];
    [self.spinner shprac_liftSelector:@selector(stopAnimating) withSignal:stopSpinning];

    RAC(self.successImageView, hidden) = [statusSignal map:^id(NSNumber *iStatus) {
        CHDStatusViewStatus status = iStatus.integerValue;
        return @(status != CHDStatusViewSuccess);
    }];

    RAC(self.errorImageView, hidden) = [statusSignal map:^id(NSNumber *iStatus) {
        CHDStatusViewStatus status = iStatus.integerValue;
        return @(status != CHDStatusViewError);
    }];

    RAC(self.statusLabel, text) = [statusSignal map:^id(NSNumber *iStatus) {
        CHDStatusViewStatus status = iStatus.integerValue;
        if(status == CHDStatusViewProcessing){
            return self.processingText;
        }
        if(status == CHDStatusViewDeleting){
            return self.deletingText;
        }
        if(status == CHDStatusViewError){
            return self.errorText;
        }
        if(status == CHDStatusViewSuccess){
            return self.successText;
        }
        if(status == CHDStatusViewDelete){
            return self.deleteSuccessText;
        }

        return @"";
    }];

    [self shprac_liftSelector:@selector(statusChangedTo:) withSignal:statusSignal];
    [self shprac_liftSelector:@selector(toggleStatusView) withSignal:RACObserve(self, show)];
}

-(void) statusChangedTo: (CHDStatusViewStatus) status {
    if(status == CHDStatusViewSuccess && self.autoHideOnSuccessAfterTime > 0 && self.isShown == YES){
        [self hideStatusViewWithDelay:self.autoHideOnSuccessAfterTime];
        return;
    }

    if(status == CHDStatusViewError && self.autoHideOnErrorAfterTime > 0 && self.isShown == YES){
        [self hideStatusViewWithDelay:self.autoHideOnErrorAfterTime];
        return;
    }
}

-(void) toggleStatusView {
    if(self.show){
        [self showStatusView];
    }else{
        [self hideStatusViewWithDelay:0];
    }
}

-(void) showStatusView {
    if(!self.isShown) {
        self.isShown = YES;
        [self.parentView addSubview:self];

        [self mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.parentView);
        }];
    }

    [UIView animateWithDuration:1.0 delay:0 usingSpringWithDamping:.60 initialSpringVelocity:.8 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
        self.alpha = 1;
    } completion:^(BOOL finished) {

    }];
}

-(void) hideStatusViewWithDelay: (NSTimeInterval) delay {
    [UIView animateWithDuration:1.0 delay:delay usingSpringWithDamping:.60 initialSpringVelocity:.8 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
        self.alpha = 0;
    } completion:^(BOOL finished) {
        if(finished && !self.show) {
            self.isShown = NO;
            [self removeFromSuperview];
        }
    }];
}

#pragma mark - Lazy loading

-(UIWindow*) parentView{
    if(!_parentView){
        _parentView = [[UIApplication sharedApplication] keyWindow];
    }
    return _parentView;
}

-(UIVisualEffectView *)backgroundView {
    if(!_backgroundView){
        UIBlurEffect *effect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
        _backgroundView = [[UIVisualEffectView alloc] initWithEffect:effect];
    }
    return _backgroundView;
}

-(UIActivityIndicatorView *)spinner {
    if(!_spinner){
        _spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    }
    return _spinner;
}

-(UILabel *)statusLabel {
    if(!_statusLabel){
        _statusLabel = [UILabel new];
        _statusLabel.text = @"";
        _statusLabel.font = [UIFont chd_fontWithFontWeight:CHDFontWeightRegular size:20];
        _statusLabel.numberOfLines = 4;
        _statusLabel.textColor = [UIColor whiteColor];
        _statusLabel.adjustsFontSizeToFitWidth = YES;
        _statusLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _statusLabel;
}

-(UIImageView *)successImageView {
    if(!_successImageView){
        _successImageView = [[UIImageView alloc] initWithImage:kImgCheckmarkMessagesent];
    }
    return _successImageView;
}

-(UIImageView *)errorImageView {
    if(!_errorImageView){
        _errorImageView = [[UIImageView alloc] initWithImage:kImgCrossError];
    }
    return _errorImageView;
}

@end
