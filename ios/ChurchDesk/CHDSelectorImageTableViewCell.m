//
//  CHDSelectorImageTableViewCell.m
//  ChurchDesk
//
//  Created by Jakob Vinther-Larsen on 27/04/15.
//  Copyright (c) 2015 Shape A/S. All rights reserved.
//

#import "CHDSelectorImageTableViewCell.h"

static CGFloat kSelectorImageSize = 28.0f;

@interface CHDSelectorImageTableViewCell ()

@property (nonatomic, strong) UIImageView *thumbnailImageView;
@property (nonatomic, strong) UILabel *nameLabel;

@property (nonatomic, strong) UIImageView* checkMark;

@end

@implementation CHDSelectorImageTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if ((self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])) {
        self.disclosureArrowHidden = YES;
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.backgroundColor = [UIColor whiteColor];
        
        [self setupSubviews];
        [self makeConstraints];
        [self setupBindings];
    }
    return self;
}

- (void) setupSubviews {
    [self.contentView addSubview:self.thumbnailImageView];
    [self.contentView addSubview:self.nameLabel];
    [self.contentView addSubview:self.checkMark];
}

- (void) makeConstraints {
    [self.thumbnailImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView).offset(15);
        make.top.equalTo(self.contentView).offset(7);
        make.bottom.equalTo(self.contentView).offset(-8);
        make.width.height.equalTo(@(kSelectorImageSize));
    }];

    [self.checkMark mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.contentView);
        make.right.equalTo(self.contentView).offset(-11);
    }];
    
    [self.nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.contentView);
        make.left.equalTo(self.contentView).offset(52);
        make.right.lessThanOrEqualTo(self.checkMark.mas_left).offset(-10);
    }];
}

- (void) setupBindings {
    RAC(self.checkMark, hidden) = [RACObserve(self, selected) map:^id(NSNumber * value) {
        return @(!value.boolValue);
    }];
    RAC(self.nameLabel, textColor) = [RACObserve(self, selected) map: ^id(NSNumber * value) {
        return value.boolValue? [UIColor chd_textDarkColor] : [UIColor chd_textLightColor];
    }];
}

#pragma mark - Lazy Initialization

- (UIImageView *)thumbnailImageView {
    if (!_thumbnailImageView) {
        _thumbnailImageView = [UIImageView new];
        _thumbnailImageView.layer.cornerRadius = kSelectorImageSize/2;
        _thumbnailImageView.layer.backgroundColor = [UIColor chd_lightGreyColor].CGColor;
        _thumbnailImageView.clipsToBounds = YES;
    }
    return _thumbnailImageView;
}

- (UILabel *)nameLabel {
    if (!_nameLabel) {
        _nameLabel = [UILabel chd_regularLabelWithSize:17];
    }
    return _nameLabel;
}
-(UIImageView*) checkMark {
    if(!_checkMark){
        _checkMark = [[UIImageView alloc] initWithImage:kImgCheckmark];
    }
    return _checkMark;
}

@end
