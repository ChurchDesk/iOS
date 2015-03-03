//
//  CHDLoginViewController.m
//  ChurchDesk
//
//  Created by Mikkel Selsøe Sørensen on 02/03/15.
//  Copyright (c) 2015 Shape A/S. All rights reserved.
//

#import "CHDLoginViewController.h"
#import "CHDIconTextFieldView.h"
#import "SHPKeyboardAwareness.h"
#import "CHDLoginViewModel.h"

@interface CHDLoginViewController ()

@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIView *logoContainer;
@property (nonatomic, strong) UIImageView *logoImageView;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) CHDIconTextFieldView *emailView;
@property (nonatomic, strong) CHDIconTextFieldView *passwordView;
@property (nonatomic, strong) UIButton *loginButton;
@property (nonatomic, strong) UIButton *forgotPasswordButton;

@property (nonatomic, strong) CHDLoginViewModel *viewModel;

@end

@implementation CHDLoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.viewModel = [CHDLoginViewModel new];
    
    self.view.backgroundColor = [UIColor chd_darkBlueColor];
    
    [self setupSubviews];
    [self makeConstraints];
    [self setupBindings];
    
#if DEBUG
    self.emailView.textField.text = @"shape@churchdesk.com";
    self.passwordView.textField.text = @"Shape2015";
#endif
}

- (void) setupSubviews {
    [self.view addSubview:self.scrollView];
    [self.scrollView addSubview:self.logoContainer];
    [self.logoContainer addSubview:self.logoImageView];
    [self.logoContainer addSubview:self.titleLabel];
    [self.scrollView addSubview:self.emailView];
    [self.scrollView addSubview:self.passwordView];
    [self.scrollView addSubview:self.loginButton];
}

- (void) makeConstraints {
    CGFloat screenHeight = [UIScreen mainScreen].bounds.size.height;
    
    [self.scrollView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    
    [self.logoContainer mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.scrollView);
        make.centerY.equalTo(self.scrollView.mas_top).offset(screenHeight/4.0f);
    }];
    
    [self.logoImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.logoContainer);
        make.centerX.equalTo(self.logoContainer);
    }];
    
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.equalTo(self.logoContainer);
        make.top.equalTo(self.logoImageView.mas_bottom).offset(15);
    }];
    
    [self.emailView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.scrollView).offset(screenHeight/2.0f);
        make.left.equalTo(self.scrollView).offset(48);
        make.right.equalTo(self.scrollView).offset(-48);
    }];
    
    [self.passwordView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.scrollView);
        make.top.equalTo(self.emailView.mas_bottom).offset(10);
        make.left.right.equalTo(self.emailView);
    }];
    
    [self.loginButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.passwordView);
        make.height.equalTo(self.passwordView);
        make.top.equalTo(self.passwordView.mas_bottom).offset(20);
        make.bottom.equalTo(self.scrollView);
    }];
}

- (void) setupBindings {
    [self rac_liftSelector:@selector(handleKeyboardEvent:) withSignals:[self shp_keyboardAwarenessSignalForView:self.loginButton], nil];
    
//    RAC(self.loginButton, enabled) = [RACSignal combineLatest:@[self.emailView.textField.rac_textSignal, self.passwordView.textField.rac_textSignal] reduce:^id (NSString *email, NSString *password) {
//        return @([email shp_matchesEmailRegex] && password.length > 0);
//    }];
}

#pragma mark - Actions

- (void) handleKeyboardEvent: (SHPKeyboardEvent*) keyboardEvent {
    BOOL show = keyboardEvent.keyboardEventType == SHPKeyboardEventTypeShow;
    if (show && keyboardEvent.requiredViewOffset == 0) {
        return;
    }
    
    [UIView animateWithDuration:keyboardEvent.keyboardAnimationDuration delay:0 options:keyboardEvent.keyboardAnimationOptionCurve animations:^{
        self.scrollView.contentOffset = show ? CGPointMake(0, -keyboardEvent.requiredViewOffset + 20) : CGPointZero;
        self.logoContainer.alpha = show ? 0.0 : 1.0;
    } completion:nil];
}

- (void) loginAction: (id) sender {
    [self.viewModel loginWithUserName:self.emailView.textField.text password:self.passwordView.textField.text];
}

#pragma mark - Lazy Initialization

- (UIView *)scrollView {
    if (!_scrollView) {
        _scrollView = [UIScrollView new];
        _scrollView.scrollEnabled = NO;
        _scrollView.showsVerticalScrollIndicator = NO;
    }
    return _scrollView;
}

- (UIView *)logoContainer {
    if (!_logoContainer) {
        _logoContainer = [UIView new];
    }
    return _logoContainer;
}

- (UIImageView *)logoImageView {
    if (!_logoImageView) {
        _logoImageView = [[UIImageView alloc] initWithImage:kImgLoginLogo];
    }
    return _logoImageView;
}

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [UILabel chd_regularLabelWithSize:18];
        _titleLabel.textColor = [UIColor whiteColor];
        _titleLabel.text = NSLocalizedString(@"More church, less administration", @"");
    }
    return _titleLabel;
}

- (CHDIconTextFieldView *)emailView {
    if (!_emailView) {
        _emailView = [CHDIconTextFieldView new];
        _emailView.textField.placeholder = NSLocalizedString(@"E-mail address", @"");
        _emailView.iconImageView.image = kImgLoginMail;
    }
    return _emailView;
}

- (CHDIconTextFieldView *)passwordView {
    if (!_passwordView) {
        _passwordView = [CHDIconTextFieldView new];
        _passwordView.textField.placeholder = NSLocalizedString(@"Password", @"");
        _passwordView.textField.secureTextEntry = YES;
        _passwordView.iconImageView.image = kImgLoginPassword;
    }
    return _passwordView;
}

- (UIButton *)loginButton {
    if (!_loginButton) {
        _loginButton = [UIButton chd_roundedBlueButton];
        [_loginButton setTitle:NSLocalizedString(@"Login", @"") forState:UIControlStateNormal];
        [_loginButton addTarget:self action:@selector(loginAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _loginButton;
}

@end
