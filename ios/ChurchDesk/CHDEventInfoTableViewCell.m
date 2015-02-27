//
//  CHDEventInfoTableViewCell.m
//  ChurchDesk
//
//  Created by Mikkel Selsøe Sørensen on 26/02/15.
//  Copyright (c) 2015 Shape A/S. All rights reserved.
//

#import "CHDEventInfoTableViewCell.h"

@interface CHDEventInfoTableViewCell ()

@property (nonatomic, strong) UIImageView *iconImageView;
@property (nonatomic, strong) UILabel *titleLabel;

@end

@implementation CHDEventInfoTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if ((self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])) {
        [self _setupSubviews];
        [self _makeConstraints];
    }
    return self;
}

- (void) _setupSubviews {
    [self.contentView addSubview:self.iconImageView];
    [self.contentView addSubview:self.titleLabel];
}

- (void) _makeConstraints {
    __block MASConstraint *iconLeftConstraint = nil;
    [self.iconImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.contentView);
        iconLeftConstraint = make.left.equalTo(self.contentView);
    }];
    
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.contentView);
        make.left.equalTo(self.iconImageView.mas_right).offset(6);
    }];
    
    [self.contentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self);
    }];
    
    RAC(iconLeftConstraint, offset) = [RACObserve(self.iconImageView, image) map:^id(UIImage *image) {
        return @(image == nil ? kSideMargin-6 : kSideMargin);
    }];
}

#pragma mark - Lazy Initialization

- (UIImageView *)iconImageView {
    if (!_iconImageView) {
        _iconImageView = [UIImageView new];
    }
    return _iconImageView;
}

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [UILabel chd_regularLabelWithSize:16];
    }
    return _titleLabel;
}

@end
