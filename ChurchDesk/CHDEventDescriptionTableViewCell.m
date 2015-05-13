//
//  CHDEventDescriptionTableViewCell.m
//  ChurchDesk
//
//  Created by Mikkel Selsøe Sørensen on 02/03/15.
//  Copyright (c) 2015 Shape A/S. All rights reserved.
//

#import "CHDEventDescriptionTableViewCell.h"

@interface CHDEventDescriptionTableViewCell ()

@property (nonatomic, strong) UILabel *descriptionLabel;

@end

@implementation CHDEventDescriptionTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if ((self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])) {
        [self setupSubviews];
        [self makeConstraints];
    }
    return self;
}

- (void) setupSubviews {
    [self.contentView addSubview:self.descriptionLabel];
}

- (void) makeConstraints {
    [self.descriptionLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.equalTo(self.contentView).offset(kSideMargin);
        make.bottom.equalTo(self.contentView).offset(-kSideMargin);
        make.right.equalTo(self.contentView).offset(-kIndentedRightMargin);
    }];
}

#pragma mark - Lazy Initialization

- (UILabel *)descriptionLabel {
    if (!_descriptionLabel) {
        _descriptionLabel = [UILabel chd_regularLabelWithSize:15];
        _descriptionLabel.textColor = [UIColor chd_textLightColor];
        _descriptionLabel.numberOfLines = 3;
    }
    return _descriptionLabel;
}

@end
