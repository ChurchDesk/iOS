//
//  CHDEventTextValueTableViewCell.m
//  ChurchDesk
//
//  Created by Mikkel Selsøe Sørensen on 02/03/15.
//  Copyright (c) 2015 Shape A/S. All rights reserved.
//

#import "CHDEventTextValueTableViewCell.h"

@interface CHDEventTextValueTableViewCell ()

@property (nonatomic, strong) UILabel *valueLabel;

@end

@implementation CHDEventTextValueTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if ((self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])) {
        self.disclosureArrowHidden = YES;
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        [self setupSubviews];
        [self makeConstraints];
        
    }
    return self;
}

- (void) setupSubviews {
    [self.contentView addSubview:self.valueLabel];
}

- (void) makeConstraints {
    [self.valueLabel setContentCompressionResistancePriority:UILayoutPriorityDefaultLow forAxis:UILayoutConstraintAxisHorizontal];
    [self.valueLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.baseline.equalTo(self.titleLabel);
        make.right.equalTo(self.contentView).offset(-kIndentedRightMargin);
        make.left.greaterThanOrEqualTo(self.titleLabel.mas_right).offset(8);
    }];
}

#pragma mark - Lazy Initialization

- (UILabel *)valueLabel {
    if (!_valueLabel) {
        _valueLabel = [UILabel chd_regularLabelWithSize:16];
        _valueLabel.textColor = [UIColor chd_textLightColor];
    }
    return _valueLabel;
}

@end
