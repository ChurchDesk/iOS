//
// Created by Jakob Vinther-Larsen on 23/03/15.
// Copyright (c) 2015 Shape A/S. All rights reserved.
//

#import "CHDEventAlertView.h"
@import WebKit;

@interface CHDEventAlertView ()
@property (nonatomic) CHDEventAlertStatus status;
@property (nonatomic) BOOL isShown;

@property (nonatomic, strong) UIWindow *parentView;
@property (nonatomic, strong) UIVisualEffectView *backgroundView;
@property (nonatomic, strong) UIView *containerView;
@property (nonatomic, strong) UIView *headerView;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *descriptionLabel;
@property (nonatomic, strong) WKWebView *webView;
@property (nonatomic, strong) UIButton *allowButton;
@property (nonatomic, strong) UIButton *cancelButton;
@end

@implementation CHDEventAlertView

-(instancetype) initWithHtml: (NSString*) htmlError {
    self = [super init];
    if(self){
        [self setupSubviews];
        [self makeConstraints];
        [self makeBindings];

        [self.webView loadHTMLString:htmlError baseURL:[NSURL new]];
    }
    return self;
}

-(void) setupSubviews {
    [self addSubview:self.backgroundView];
    [self addSubview:self.containerView];
    [self.containerView addSubview:self.headerView];
    [self.headerView addSubview:self.titleLabel];
    [self.headerView addSubview:self.descriptionLabel];
    [self.containerView addSubview:self.webView];
    [self addSubview:self.allowButton];
    [self addSubview:self.cancelButton];
}

-(void) makeConstraints {
    [self.backgroundView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self);
    }];

    [self.containerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self).offset(20);
        make.left.equalTo(self).offset(20);
        make.right.equalTo(self).offset(-20);
        make.bottom.equalTo(self.allowButton.mas_top).offset(-40);
    }];

    [self.headerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.equalTo(self.containerView);
    }];

    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.headerView).offset(20);
        make.centerX.equalTo(self.headerView);
    }];
    [self.descriptionLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.titleLabel.mas_bottom).offset(10);
        make.bottom.equalTo(self.headerView).offset(-10);
        make.left.equalTo(self.headerView).offset(5);
        make.right.equalTo(self.headerView).offset(-5);
    }];

    [self.webView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.headerView.mas_bottom);
        make.left.right.bottom.equalTo(self.containerView);
    }];

    [self.allowButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self).offset(20);
        make.right.equalTo(self).offset(-20);
        make.height.equalTo(@50);
    }];
    [self.cancelButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.allowButton.mas_bottom).offset(10);
        make.bottom.equalTo(self).offset(-20);
        make.left.equalTo(self).offset(20);
        make.right.equalTo(self).offset(-20);
        make.height.equalTo(@50);
    }];
}

-(void) makeBindings {
    RACSignal *buttonAllowSignal = [[self.allowButton rac_signalForControlEvents:UIControlEventTouchUpInside] map:^id(id value) {
        return @(CHDEventAlertStatusAllowDoubleBooking);
    }];
    RACSignal *buttonCancelSignal = [[self.cancelButton rac_signalForControlEvents:UIControlEventTouchUpInside] map:^id(id value) {
        return @(CHDEventAlertStatusCancel);
    }];

    [self rac_liftSelector:@selector(setStatus:) withSignals:[RACSignal merge:@[buttonAllowSignal, buttonCancelSignal]], nil];

    [self shprac_liftSelector:@selector(toggleStatusView) withSignal:RACObserve(self, show)];
}

#pragma mark -Toggle alert view
-(void) toggleStatusView {
    if(self.show){
        [self showAlertView];
    }else{
        [self hideAlertView];
    }
}

- (void)showAlertView {
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

- (void)hideAlertView {
    [UIView animateWithDuration:1.0 delay:0 usingSpringWithDamping:.60 initialSpringVelocity:.8 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
        self.alpha = 0;
    } completion:^(BOOL finished) {
        if(finished && !self.show) {
            self.isShown = NO;
            [self removeFromSuperview];
        }
    }];
}


#pragma mark -Lazy initialization
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

-(UIView*) containerView{
    if(!_containerView){
        _containerView = [UIView new];
        _containerView.layer.cornerRadius = 4;
        _containerView.clipsToBounds = YES;
    }
    return _containerView;
}

-(UIView*) headerView{
    if(!_headerView){
        _headerView = [UIView new];
        _headerView.backgroundColor = [UIColor chd_blueColor];
    }
    return _headerView;
}

-(UILabel*)titleLabel {
    if(!_titleLabel){
        _titleLabel = [UILabel new];
        _titleLabel.font = [UIFont chd_fontWithFontWeight:CHDFontWeightRegular size:18];
        _titleLabel.textColor = [UIColor whiteColor];
        _titleLabel.text = NSLocalizedString(@"Double booking", @"");
    }
    return _titleLabel;
}
-(UILabel*)descriptionLabel {
    if (!_descriptionLabel) {
        _descriptionLabel = [UILabel new];
        _descriptionLabel.font = [UIFont chd_fontWithFontWeight:CHDFontWeightRegular size:15];
        _descriptionLabel.textColor = [UIColor whiteColor];
        _descriptionLabel.textAlignment = NSTextAlignmentCenter;
        _descriptionLabel.numberOfLines = 0;
        _descriptionLabel.text = NSLocalizedString(@"You are about to make a double booking of one or more resources/users.", @"");
    }
    return _descriptionLabel;
}
-(WKWebView*) webView {
    if(!_webView){
        WKWebViewConfiguration *configuration = [[WKWebViewConfiguration alloc] init];
        configuration.preferences.minimumFontSize = 13;
        configuration.preferences.javaScriptCanOpenWindowsAutomatically = NO;
        configuration.preferences.javaScriptEnabled = NO;
        configuration.mediaPlaybackRequiresUserAction = YES;
        configuration.allowsInlineMediaPlayback = NO;
        configuration.mediaPlaybackAllowsAirPlay = NO;
        _webView = [[WKWebView alloc] initWithFrame:CGRectMake(0, 0, 300, 300) configuration:configuration];
        _webView.allowsBackForwardNavigationGestures = NO;
    }
    return _webView;
}

-(UIButton*) allowButton {
    if(!_allowButton){
        _allowButton = [UIButton new];
        _allowButton.titleLabel.font = [UIFont chd_fontWithFontWeight:CHDFontWeightRegular size:18];
        [_allowButton setTitleColor:[UIColor chd_blueColor] forState:UIControlStateNormal];
        [_allowButton setTitle:NSLocalizedString(@"Allow double booking", @"") forState:UIControlStateNormal];
        _allowButton.backgroundColor = [UIColor whiteColor];
        _allowButton.layer.cornerRadius = 4;

    }
    return _allowButton;
}
-(UIButton*) cancelButton {
    if(!_cancelButton){
        _cancelButton = [UIButton new];
        _cancelButton.titleLabel.font = [UIFont chd_fontWithFontWeight:CHDFontWeightRegular size:18];
        [_cancelButton setTitle:NSLocalizedString(@"Cancel", @"") forState:UIControlStateNormal];
        [_cancelButton setTitleColor:[UIColor darkTextColor] forState:UIControlStateNormal];
        _cancelButton.backgroundColor = [UIColor whiteColor];
        _cancelButton.layer.cornerRadius = 4;
    }
    return _cancelButton;
}
@end