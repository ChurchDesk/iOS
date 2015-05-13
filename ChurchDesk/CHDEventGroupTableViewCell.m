//
//  CHDEventGroupTableViewCell.m
//  ChurchDesk
//
//  Created by Mikkel Selsøe Sørensen on 26/02/15.
//  Copyright (c) 2015 Shape A/S. All rights reserved.
//

#import "CHDEventGroupTableViewCell.h"

@interface CHDEventGroupTableViewCell ()

@property (nonatomic, strong) UILabel *groupLabel;

@end

@implementation CHDEventGroupTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if ((self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])) {
        self.iconImageView.image = kImgEventGroup;
        self.disclosureArrowHidden = YES;
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        [self setupSubviews];
        [self makeConstraints];
    }
    return self;
}

- (void) setupSubviews {
    [self.contentView addSubview:self.groupLabel];
}

- (void) makeConstraints {
    [self.groupLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.contentView);
        make.right.equalTo(self.contentView).offset(-kSideMargin);
    }];
}

#pragma mark - Lazy Initialization

- (UILabel *)groupLabel {
    if (!_groupLabel) {
        _groupLabel = [UILabel chd_regularLabelWithSize:13];
    }
    return _groupLabel;
}

@end
