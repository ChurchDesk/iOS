//
//  CHDMessageTableViewCell.m
//  ChurchDesk
//
//  Created by Jakob Vinther-Larsen on 25/02/15.
//  Copyright (c) 2015 Shape A/S. All rights reserved.
//

#import "CHDMessageTableViewCell.h"

@interface CHDMessageTableViewCell()
@property (nonatomic, strong) UIImageView *profileImageView;
@property (nonatomic, strong) UILabel *userNameLabel;
@property (nonatomic, strong) UILabel *createdDateLabel;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *messageLabel;
@property (nonatomic, strong) UILabel *groupLabel;
@property (nonatomic, strong) UILabel *parishLabel;
@end

@implementation CHDMessageTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        [self.cellBackgroundView setBorderColor:[UIColor clearColor]];
    }
    return self;
}

#pragma mark - Lazy initialization

-(void) makeViews{
    [super makeViews];
    UIView *contentView = self.contentView;

    [contentView addSubview:self.profileImageView];
    [contentView addSubview:self.userNameLabel];
    [contentView addSubview:self.createdDateLabel];
    [contentView addSubview:self.titleLabel];
    [contentView addSubview:self.messageLabel];
    [contentView addSubview:self.groupLabel];
    [contentView addSubview:self.parishLabel];
}
-(void) makeConstraints {
    [super makeConstraints];
    UIView *contentView = self.contentView;

    [self.profileImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.height.equalTo(@50);
        make.left.equalTo(contentView).offset(8);
        make.top.equalTo(contentView).offset(16);
    }];

    [self.userNameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.profileImageView.mas_right).offset(8);
        make.baseline.equalTo(self.profileImageView.mas_top).offset(24);
    }];

    [self.createdDateLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.userNameLabel);
        make.baseline.equalTo(self.profileImageView.mas_bottom).offset(-8);
    }];

    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.profileImageView.mas_bottom).offset(16);
        make.left.equalTo(contentView).offset(15);
        make.right.equalTo(contentView).offset(-15);
    }];

    [self.messageLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.titleLabel.mas_bottom).offset(3);
        make.left.equalTo(self.titleLabel);
        make.right.equalTo(contentView).offset(-14);
        make.bottom.equalTo(contentView.mas_bottom).offset(-25);
    }];

    [self.groupLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.userNameLabel);
        make.right.equalTo(contentView).offset(-14);
        make.left.greaterThanOrEqualTo(self.userNameLabel.mas_right).offset(5);
    }];

    [self.parishLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.groupLabel);
        make.centerY.equalTo(self.createdDateLabel);
    }];
}

-(UIImageView*) profileImageView {
    if(!_profileImageView){
        _profileImageView = [UIImageView new];
        _profileImageView.layer.cornerRadius = 25;
        _profileImageView.layer.backgroundColor = [UIColor chd_lightGreyColor].CGColor;
        _profileImageView.layer.masksToBounds = YES;
    }
    return _profileImageView;
}

-(UILabel*) userNameLabel{
    if(!_userNameLabel){
        _userNameLabel = [UILabel new];
        _userNameLabel.font = [UIFont chd_fontWithFontWeight:CHDFontWeightMedium size:18];
        _userNameLabel.textColor = [UIColor blackColor];
    }
    return _userNameLabel;
}
-(UILabel*) createdDateLabel{
    if(!_createdDateLabel){
        _createdDateLabel = [UILabel new];
        _createdDateLabel.font = [UIFont chd_fontWithFontWeight:CHDFontWeightRegular size:14];
        _createdDateLabel.textColor = [UIColor blackColor];
    }
    return _createdDateLabel;
}
-(UILabel*) titleLabel{
    if(!_titleLabel){
        _titleLabel = [UILabel new];
        _titleLabel.font = [UIFont chd_fontWithFontWeight:CHDFontWeightMedium size:20];
        _titleLabel.textColor = [UIColor blackColor];
        _titleLabel.numberOfLines = 0;
    }
    return _titleLabel;
}
-(UILabel*) messageLabel{
    if(!_messageLabel){
        _messageLabel = [UILabel new];
        _messageLabel.font = [UIFont chd_fontWithFontWeight:CHDFontWeightRegular size:15];
        _messageLabel.textColor = [UIColor blackColor];
        _messageLabel.numberOfLines = 0;
        _messageLabel.lineBreakMode = NSLineBreakByWordWrapping;
    }
    return _messageLabel;
}
-(UILabel*) groupLabel{
    if(!_groupLabel){
        _groupLabel = [UILabel new];
        _groupLabel.font = [UIFont chd_fontWithFontWeight:CHDFontWeightRegular size:14];
        _groupLabel.textColor = [UIColor shpui_colorWithHexValue:0x646464];
    }
    return _groupLabel;
}
-(UILabel*) parishLabel{
    if(!_parishLabel){
        _parishLabel = [UILabel new];
        _parishLabel.font = [UIFont chd_fontWithFontWeight:CHDFontWeightRegular size:14];
        _parishLabel.textColor = [UIColor shpui_colorWithHexValue:0xc0c0c0];
    }
    return _parishLabel;
}

@end
