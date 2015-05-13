//
//  CHDEventDateTableViewCell.m
//  ChurchDesk
//
//  Created by Mikkel Selsøe Sørensen on 06/03/15.
//  Copyright (c) 2015 Shape A/S. All rights reserved.
//

#import "CHDEventValueTableViewCell.h"

@interface CHDEventValueTableViewCell ()

@property (nonatomic, strong) UILabel *valueLabel;

@end

@implementation CHDEventValueTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if ((self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])) {
        [self setupSubviews];
        [self makeConstraints];
    }
    return self;
}

- (void) setupSubviews {
    [self.contentView addSubview:self.valueLabel];
}

- (void) makeConstraints {
    [self.valueLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.baseline.equalTo(self.titleLabel);
        make.right.equalTo(self.contentView).offset(-kIndentedRightMargin);
        make.left.greaterThanOrEqualTo(self.titleLabel.mas_right).offset(6);
    }];
}

#pragma mark - Lazy Initialization

- (UILabel *)valueLabel {
    if (!_valueLabel) {
        _valueLabel = [UILabel chd_regularLabelWithSize:17];
        _valueLabel.textColor = [UIColor chd_blueColor];
    }
    return _valueLabel;
}

@end
