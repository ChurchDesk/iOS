//
//  CHDEventTitleImageTableViewCell.m
//  ChurchDesk
//
//  Created by Mikkel Selsøe Sørensen on 27/02/15.
//  Copyright (c) 2015 Shape A/S. All rights reserved.
//

#import "CHDEventTitleImageTableViewCell.h"

@interface CHDEventTitleImageTableViewCell ()

@property (nonatomic, strong) UIImageView *titleImageView;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UIView *gradientView;

@end

@implementation CHDEventTitleImageTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if ((self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.backgroundColor = [UIColor chd_lightGreyColor];
        [self setupSubviews];
        [self makeConstraints];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
}

- (void) setupSubviews {
    [self.contentView addSubview:self.titleImageView];
    [self.contentView addSubview:self.gradientView];
    [self.contentView addSubview:self.titleLabel];
}

- (void) makeConstraints {
    [self.titleImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.contentView);
    }];
    
    [self.gradientView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.equalTo(self.contentView);
        make.top.equalTo(self.titleLabel).offset(-10);
    }];
    
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView).offset(15);
        make.right.equalTo(self.contentView).offset(-15);
        make.bottom.equalTo(self.contentView).offset(-17);
    }];
    
    [self.contentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self);
        make.height.equalTo(@227).priorityLow();
    }];
}

#pragma mark - Lazy Initialization

- (UIImageView *)titleImageView {
    if (!_titleImageView) {
        _titleImageView = [[UIImageView alloc] init];
        _titleImageView.contentMode = UIViewContentModeScaleAspectFill;
        _titleImageView.clipsToBounds = YES;
    }
    return _titleImageView;
}

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [UILabel chd_regularLabelWithSize:20];
        _titleLabel.textColor = [UIColor whiteColor];
        _titleLabel.shadowColor = [UIColor blackColor];
        _titleLabel.shadowOffset = CGSizeMake(0, 1);
        _titleLabel.numberOfLines = 0;
    }
    return _titleLabel;
}

- (UIView *)gradientView {
    if (!_gradientView) {
        _gradientView = [UIView new];
        
        NSArray *colors = @[(id)[UIColor clearColor].CGColor, (id)[UIColor blackColor].CGColor];
        NSArray *locations = @[@0, @1];
        
        CAGradientLayer *gradientLayer = [CAGradientLayer layer];
        RAC(gradientLayer, frame) = RACObserve(_gradientView, bounds);
        gradientLayer.colors = colors;
        gradientLayer.locations = locations;
        [_gradientView.layer addSublayer:gradientLayer];
    }
    return _gradientView;
}

@end
