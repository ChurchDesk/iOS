//
// Created by Jakob Vinther-Larsen on 07/05/15.
// Copyright (c) 2015 Shape A/S. All rights reserved.
//

#import "CHDEventTitleTableViewCell.h"
@interface CHDEventTitleTableViewCell()
@property (nonatomic, strong) UILabel *titleLabel;
@end

@implementation CHDEventTitleTableViewCell
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
    [self.contentView addSubview:self.titleLabel];
}

- (void) makeConstraints {
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.contentView).offset(17);
        make.left.equalTo(self.contentView).offset(15);
        make.right.equalTo(self.contentView).offset(-15);
        make.bottom.equalTo(self.contentView).offset(-17);
    }];
}

#pragma mark - Lazy Initialization

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [UILabel chd_regularLabelWithSize:20];
        _titleLabel.textColor = [UIColor blackColor];
        _titleLabel.shadowColor = [UIColor whiteColor];
        _titleLabel.shadowOffset = CGSizeMake(0, 1);
        _titleLabel.numberOfLines = 0;
    }
    return _titleLabel;
}

@end