//
//  CHDColorDotLabelView.m
//  ChurchDesk
//
//  Created by Mikkel Selsøe Sørensen on 02/03/15.
//  Copyright (c) 2015 Shape A/S. All rights reserved.
//

#import "CHDColorDotLabelView.h"
#import "CHDDotView.h"

@interface CHDColorDotLabelView ()

@property (nonatomic, strong) CHDDotView *dotView;
@property (nonatomic, strong) UILabel *titleLabel;

@end

@implementation CHDColorDotLabelView

- (instancetype)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
        [self setupSubviews];
        [self makeConstraints];
        [self setupBindings];
    }
    return self;
}

- (void) setupSubviews {
    [self addSubview:self.titleLabel];
    [self addSubview:self.dotView];
}

- (void) makeConstraints {
    [self.dotView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self);
        make.top.equalTo(self).offset(5);
        make.size.equalTo([NSValue valueWithCGSize:CGSizeMake(6, 6)]);
    }];
    
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.right.bottom.equalTo(self);
        make.left.equalTo(self.dotView.mas_right).offset(6);
    }];
}

- (void) setupBindings {
    RAC(self.titleLabel, text) = RACObserve(self, title);
    RAC(self.dotView, dotColor) = RACObserve(self, color);
}

#pragma mark - Lazy Initialization

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [UILabel chd_regularLabelWithSize:13];
        _titleLabel.numberOfLines = 0;
    }
    return _titleLabel;
}

- (CHDDotView *)dotView {
    if (!_dotView) {
        _dotView = [CHDDotView new];
    }
    return _dotView;
}

@end
