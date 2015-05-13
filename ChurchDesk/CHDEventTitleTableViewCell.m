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
        self.disclosureArrowHidden = YES;
        self.dividerLineHidden = NO;

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
        make.centerY.equalTo(self.contentView);
        make.left.equalTo(self.contentView).offset(15);
        make.right.lessThanOrEqualTo(self.contentView).offset(-15);
    }];
    [self.contentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self);
        make.height.equalTo(@90).priorityLow();
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