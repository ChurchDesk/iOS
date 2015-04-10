//
//  CHDCalendarTitleView.m
//  ChurchDesk
//
//  Created by Mikkel Selsøe Sørensen on 23/02/15.
//  Copyright (c) 2015 Shape A/S. All rights reserved.
//

#import "CHDCalendarTitleView.h"

@interface CHDCalendarTitleView ()

@property (nonatomic, strong) UIView *contentView;
@property (nonatomic, strong) UIButton *titleButton;
@property (nonatomic, strong) UIImageView *titleArrowView;

@end

@implementation CHDCalendarTitleView

- (instancetype)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
        [self setupSubviews];
        [self makeConstraints];
        
        RAC(self, frame) = RACObserve(self.contentView, bounds);
        RAC(self.titleArrowView, transform) = [RACObserve(self, pointArrowDown) map:^id(NSNumber *nPointDown) {
            CGAffineTransform transform = nPointDown.boolValue ? CGAffineTransformRotate(CGAffineTransformIdentity, M_PI) : CGAffineTransformIdentity;
            return [NSValue valueWithCGAffineTransform:transform];
        }];
    }
    return self;
}

- (void) setupSubviews {
    [self addSubview:self.contentView];
    [self.contentView addSubview:self.titleButton];
    [self.contentView addSubview:self.titleArrowView];
}

- (void) makeConstraints {
    [self.contentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self);
    }];
    
    [self.titleButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.bottom.equalTo(self.contentView);
    }];
    
    [self.titleArrowView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.contentView);
        make.centerY.equalTo(self.contentView);
        make.left.equalTo(self.titleButton.mas_right).offset(6);
    }];
}

#pragma mark - Lazy Initialization

- (UIView *)contentView {
    if (!_contentView) {
        _contentView = [UIView new];
    }
    return _contentView;
}

- (UIImageView *)titleArrowView {
    if (!_titleArrowView) {
        _titleArrowView = [[UIImageView alloc] initWithImage:kImgMonthTitleActive];
    }
    return _titleArrowView;
}

- (UIButton *)titleButton {
    if (!_titleButton) {
        _titleButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _titleButton.hitTestEdgeInsets = UIEdgeInsetsMake(-5, -10, -10, -15);
        _titleButton.titleLabel.font = [UIFont chd_fontWithFontWeight:CHDFontWeightRegular size:20];
        [_titleButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    }
    return _titleButton;
}


@end
