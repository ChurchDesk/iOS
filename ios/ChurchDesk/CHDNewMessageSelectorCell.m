//
// Created by Jakob Vinther-Larsen on 27/02/15.
// Copyright (c) 2015 Shape A/S. All rights reserved.
//

#import "CHDNewMessageSelectorCell.h"

@interface CHDNewMessageSelectorCell()
@property (nonatomic, strong) UILabel* titleLabel;
@property (nonatomic, strong) UILabel* selectedLabel;
@end

@implementation CHDNewMessageSelectorCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if(self){
        [self makeViews];
        [self makeConstraints];
    }
    return self;
}

#pragma mark - Lazy initialization
- (void)makeConstraints {
    UIView *contentView = self.contentView;

    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(contentView);
        make.left.equalTo(contentView).offset(15);
    }];

    [self.selectedLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(contentView);
        make.right.equalTo(contentView).offset(-33);
    }];
}

- (void)makeViews {
    UIView *contentView = self.contentView;

    [contentView addSubview:self.titleLabel];
    [contentView addSubview:self.selectedLabel];
}

- (UILabel *)titleLabel {
    if(!_titleLabel){
        _titleLabel = [UILabel new];
        _titleLabel.font = [UIFont chd_fontWithFontWeight:CHDFontWeightRegular size:17];
        _titleLabel.textColor = [UIColor chd_textDarkColor];
    }
    return _titleLabel;
}

- (UILabel *)selectedLabel {
    if(!_selectedLabel){
        _selectedLabel = [UILabel new];
        _selectedLabel.font = [UIFont chd_fontWithFontWeight:CHDFontWeightRegular size:17];
        _selectedLabel.textColor = [UIColor chd_blueColor];
        _selectedLabel.textAlignment = NSTextAlignmentRight;
    }
    return _selectedLabel;
}
@end