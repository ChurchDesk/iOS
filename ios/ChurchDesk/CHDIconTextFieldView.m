//
//  CHDIconTextFieldView.m
//  ChurchDesk
//
//  Created by Mikkel Selsøe Sørensen on 02/03/15.
//  Copyright (c) 2015 Shape A/S. All rights reserved.
//

#import "CHDIconTextFieldView.h"

@interface CHDIconTextFieldView ()

@property (nonatomic, strong) UIView *iconContainerView;
@property (nonatomic, strong) UIImageView *iconImageView;
@property (nonatomic, strong) UITextField *textField;

@end

@implementation CHDIconTextFieldView

- (instancetype)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
        self.backgroundColor = [UIColor whiteColor];
        self.layer.cornerRadius = 2.0f;
        
        [self setupSubviews];
        [self makeContraints];
    }
    return self;
}

- (void) setupSubviews {
    [self addSubview:self.iconContainerView];
    [self.iconContainerView addSubview:self.iconImageView];
    [self addSubview:self.textField];
}

- (void) makeContraints {
    [self.iconContainerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.bottom.equalTo(self);
        make.width.equalTo(@44);
    }];
    
    [self.iconImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self.iconContainerView);
    }];
    
    [self.textField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.bottom.right.equalTo(self);
        make.left.equalTo(self.iconContainerView.mas_right);
    }];
}

- (CGSize)intrinsicContentSize {
    return CGSizeMake(0, 50);
}

#pragma mark - Lazy Initialization

- (UIView *)iconContainerView {
    if (!_iconContainerView) {
        _iconContainerView = [UIView new];
    }
    return _iconContainerView;
}

- (UIImageView *)iconImageView {
    if (!_iconImageView) {
        _iconImageView = [UIImageView new];
    }
    return _iconImageView;
}

- (UITextField *)textField {
    if (!_textField) {
        _textField = [UITextField new];
        _textField.textColor = [UIColor chd_darkBlueColor];
        _textField.font = [UIFont chd_fontWithFontWeight:CHDFontWeightRegular size:18];
    }
    return _textField;
}

@end
