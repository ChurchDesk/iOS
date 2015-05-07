//
//  CHDLoginViewController.m
//  ChurchDesk
//
//  Created by Mikkel Selsøe Sørensen on 02/03/15.
//  Copyright (c) 2015 Shape A/S. All rights reserved.
//

#import <MBProgressHUD/MBProgressHUD.h>
#import <SHPNetworking/SHPAPIManager+ReactiveExtension.h>
#import "CHDLoginViewController.h"
#import "CHDIconTextFieldView.h"
#import "SHPKeyboardAwareness.h"
#import "CHDLoginViewModel.h"
#import "CHDAnalyticsManager.h"

@interface CHDLoginViewController () <UITextFieldDelegate>

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
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[CHDAnalyticsManager sharedInstance] trackVisitToScreen:@"login"];
}

- (void) setupSubviews {
    [self.view addSubview:self.scrollView];
    [self.scrollView addSubview:self.logoContainer];
    [self.logoContainer addSubview:self.logoImageView];
    [self.logoContainer addSubview:self.titleLabel];
    [self.scrollView addSubview:self.emailView];
    [self.scrollView addSubview:self.passwordView];
    [self.scrollView addSubview:self.loginButton];
    [self.scrollView addSubview:self.forgotPasswordButton];
}

- (void) makeConstraints {
    CGFloat screenHeight = [UIScreen mainScreen].bounds.size.height;
    
    [self.scrollView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    
    [self.logoContainer mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.scrollView);
        make.centerY.equalTo(self.scrollView.mas_top).offset(screenHeight/4.0f);
        make.left.greaterThanOrEqualTo(self.scrollView.mas_left);
        make.right.lessThanOrEqualTo(self.scrollView.mas_right);
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
    
    [self.forgotPasswordButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view);
        make.bottom.equalTo(self.view).offset(-45);
    }];
}

- (void) setupBindings {
    [self rac_liftSelector:@selector(handleKeyboardEvent:) withSignals:[self shp_keyboardAwarenessSignalForView:self.loginButton], nil];

    RAC(self.loginButton, enabled) = [RACSignal combineLatest:@[self.emailView.textField.rac_textSignal, self.passwordView.textField.rac_textSignal, self.viewModel.loginCommand.executing] reduce:^id (NSString *email, NSString *password, NSNumber *nExecuting) {
        return @([email shp_matchesEmailRegex] && password.length > 0 && !nExecuting.boolValue);
    }];
    
    RAC(self.forgotPasswordButton, enabled) = [self.viewModel.resetPasswordCommand.executing not];
    
    UITapGestureRecognizer *tapRecognizer = [UITapGestureRecognizer new];
    [self.view addGestureRecognizer:tapRecognizer];
    [self.view shprac_liftSelector:@selector(endEditing:) withSignal:[[tapRecognizer rac_gestureSignal] mapReplace:@YES]];

    [self rac_liftSelector:@selector(showProgress:) withSignals:[RACSignal merge:@[self.viewModel.loginCommand.executing, self.viewModel.resetPasswordCommand.executing]], nil];
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField == self.emailView.textField) {
        [self.passwordView.textField becomeFirstResponder];
    }
    else {
        [self loginAction:nil];
    }
    return YES;
}

#pragma mark - Actions

- (void) handleKeyboardEvent: (SHPKeyboardEvent*) keyboardEvent {
    BOOL show = keyboardEvent.keyboardEventType == SHPKeyboardEventTypeShow;
    
    [UIView animateWithDuration:keyboardEvent.keyboardAnimationDuration delay:0 options:keyboardEvent.keyboardAnimationOptionCurve animations:^{
        self.scrollView.contentOffset = show ? CGPointMake(0, self.scrollView.contentOffset.y -keyboardEvent.requiredViewOffset + (self.scrollView.contentOffset.y == 0 ? 20 : 0)) : CGPointZero;
        self.logoContainer.alpha = show ? 0.0 : 1.0;
    } completion:nil];
}

- (void) loginAction: (id) sender {
    [[CHDAnalyticsManager sharedInstance] trackEventWithCategory:ANALYTICS_CATEGORY_SIGNIN action:ANALYTICS_ACTION_BUTTON label:ANALYTICS_LABEL_LOGIN];
    [self.view endEditing:YES];
    [[self.viewModel loginWithUserName:self.emailView.textField.text password:self.passwordView.textField.text] subscribeError:^(NSError *error) {
        SHPHTTPResponse *response = error.userInfo[SHPAPIManagerReactiveExtensionErrorResponseKey];
        if (response.statusCode == 400) {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", @"") message:NSLocalizedString(@"Wrong username or password", @"Message shown on wrong username password") delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", @"") otherButtonTitles:nil];
            [alertView show];
        }

    }];
}

- (void) forgotPasswordAction: (id) sender {
    [[CHDAnalyticsManager sharedInstance] trackEventWithCategory:ANALYTICS_CATEGORY_SIGNIN action:ANALYTICS_ACTION_BUTTON label:ANALYTICS_LABEL_FORGOT_PASSWORD];
    NSString *emailFieldText = self.emailView.textField.text;
    BOOL validEmail = [emailFieldText shp_matchesEmailRegex];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Forgot Password", @"") message:validEmail ? NSLocalizedString(@"Instructions for resetting you password will be sent to your email.", @"") : NSLocalizedString(@"Please enter your email to receive instructions on how to reset your password.", @"") delegate:nil cancelButtonTitle:NSLocalizedString(@"Cancel", @"") otherButtonTitles:NSLocalizedString(@"Continue", @""), nil];
    if (!validEmail) {
        alert.alertViewStyle = UIAlertViewStylePlainTextInput;
        UITextField *textField = [alert textFieldAtIndex:0];
        textField.placeholder = NSLocalizedString(@"E-mail address", @"");
        textField.keyboardType = UIKeyboardTypeEmailAddress;
    }


    RACSignal *emailSignal = [[alert.rac_buttonClickedSignal ignore:@(alert.cancelButtonIndex)] map:^id(id value) {
        return alert.alertViewStyle == UIAlertViewStylePlainTextInput ? [alert textFieldAtIndex:0].text : emailFieldText;
    }];

    RACSignal *emailValidSignal = [emailSignal filter:^BOOL(NSString *emailString) {
        return [emailString shp_matchesEmailRegex];
    }];

    RACSignal *emailInValidSignal = [emailSignal filter:^BOOL(NSString *emailString) {
        return ![emailString shp_matchesEmailRegex];
    }];

    [self shprac_liftSelector:@selector(resetPasswordForMail:) withSignal:emailValidSignal];

    [emailInValidSignal subscribeNext:^(id x) {
        UIAlertView *errorAlert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Password reset failed", @"") message:NSLocalizedString(@"Something when wrong while resetting your password. Please try again.", @"") delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", @"") otherButtonTitles: nil];
        [errorAlert show];
    }];
    
    [alert show];
}

-(void) resetPasswordForMail: (NSString*) email {
    [[self.viewModel resetPasswordForEmail:email] subscribeNext:^(id x) {
        NSString *message = [NSString stringWithFormat:NSLocalizedString(@"Instructions for resetting your password will be sent to '%@'.", @""), email];
        UIAlertView *successAlert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Success", @"") message:message delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", @"") otherButtonTitles: nil];
        [successAlert show];
    } error:^(NSError *error) {
        NSLog(@"Error resetting password %@", error);
        UIAlertView *errorAlert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Password reset failed", @"") message:NSLocalizedString(@"Something when wrong while resetting your password. Please try again.", @"") delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", @"") otherButtonTitles: nil];
        [errorAlert show];
    }];
}

-(void) showProgress: (BOOL) show {
    if(show) {
        [MBProgressHUD hideAllHUDsForView:self.navigationController.view animated:YES];
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        hud.color = [UIColor colorWithWhite:0.7 alpha:0.7];
        hud.labelColor = [UIColor chd_textDarkColor];
        // Configure for text only and offset down
        hud.mode = MBProgressHUDModeIndeterminate;
        hud.margin = 10.f;
        hud.removeFromSuperViewOnHide = YES;
        hud.userInteractionEnabled = NO;
    }else{
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    }
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
        _titleLabel.numberOfLines = 0;
        _titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        _titleLabel.text = NSLocalizedString(@"More church, less administration", @"");
    }
    return _titleLabel;
}

- (CHDIconTextFieldView *)emailView {
    if (!_emailView) {
        _emailView = [CHDIconTextFieldView new];
        _emailView.textField.placeholder = NSLocalizedString(@"E-mail address", @"");
        _emailView.textField.keyboardType = UIKeyboardTypeEmailAddress;
        _emailView.textField.returnKeyType = UIReturnKeyNext;
        _emailView.textField.delegate = self;
        _emailView.iconImageView.image = kImgLoginMail;
        _emailView.textField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    }
    return _emailView;
}

- (CHDIconTextFieldView *)passwordView {
    if (!_passwordView) {
        _passwordView = [CHDIconTextFieldView new];
        _passwordView.textField.placeholder = NSLocalizedString(@"Password", @"");
        _passwordView.textField.secureTextEntry = YES;
        _passwordView.textField.returnKeyType = UIReturnKeyGo;
        _passwordView.textField.delegate = self;
        _passwordView.iconImageView.image = kImgLoginPassword;
    }
    return _passwordView;
}

- (UIButton *)loginButton {
    if (!_loginButton) {
        _loginButton = [UIButton chd_roundedBlueButton];
        [_loginButton setTitle:NSLocalizedString(@"Login", @"") forState:UIControlStateNormal];
        [_loginButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_loginButton setTitleColor:[UIColor chd_darkBlueColor] forState:UIControlStateDisabled];
        [_loginButton addTarget:self action:@selector(loginAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _loginButton;
}

- (UIButton *)forgotPasswordButton {
    if (!_forgotPasswordButton) {
        _forgotPasswordButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_forgotPasswordButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _forgotPasswordButton.titleLabel.font = [UIFont chd_fontWithFontWeight:CHDFontWeightRegular size:18];
        [_forgotPasswordButton setTitle: NSLocalizedString(@"Forgot password?", @"") forState:UIControlStateNormal];
        [_forgotPasswordButton addTarget:self action:@selector(forgotPasswordAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _forgotPasswordButton;
}

@end
