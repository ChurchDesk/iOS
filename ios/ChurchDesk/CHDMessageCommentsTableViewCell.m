//
//  CHDMessageCommentsTableViewCell.m
//  ChurchDesk
//
//  Created by Jakob Vinther-Larsen on 25/02/15.
//  Copyright (c) 2015 Shape A/S. All rights reserved.
//

#import "CHDMessageCommentsTableViewCell.h"

@interface CHDMessageCommentsTableViewCell()
@property (nonatomic, strong) UIButton *editButton;
@property (nonatomic, strong) UIImageView *profileImageView;
@property (nonatomic, strong) UILabel *userNameLabel;
@property (nonatomic, strong) UILabel *createdDateLabel;
@property (nonatomic, strong) UILabel *messageLabel;
@end

@implementation CHDMessageCommentsTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;

        [self.editButton rac_liftSelector:@selector(setHidden:) withSignals:[RACObserve(self, canEdit) not], nil];
        [self.editButton rac_liftSelector:@selector(setEnabled:) withSignals:RACObserve(self, canEdit), nil];
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
    [contentView addSubview:self.messageLabel];
    [contentView addSubview:self.editButton];
}

-(void)makeConstraints {
    [super makeConstraints];
    UIView *contentView = self.contentView;

    [self.profileImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.height.equalTo(@32);
        make.top.equalTo(contentView).offset(18);
        make.left.equalTo(contentView).offset(8);
    }];

    [self.messageLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(contentView).offset(45);
        make.bottom.equalTo(contentView).offset(-40);
        make.right.equalTo(contentView).offset(-15);
        make.left.equalTo(self.userNameLabel);
    }];

    [self.userNameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.profileImageView).offset(5);
        make.left.equalTo(self.profileImageView.mas_right).offset(8);
    }];

    [self.createdDateLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(contentView).offset(-20);
        make.left.equalTo(self.messageLabel);
    }];

    [self.editButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(contentView);
        make.top.equalTo(contentView);
    }];
}

-(UIButton*) editButton {
    if(!_editButton){
        _editButton = [UIButton new];
        [_editButton setImage:kImgDisclosureArrowDown forState:UIControlStateNormal];
        _editButton.contentEdgeInsets = UIEdgeInsetsMake(15, 15, 15, 15);
    }
    return _editButton;
}

-(UIImageView*) profileImageView {
    if(!_profileImageView){
        _profileImageView = [UIImageView new];
        _profileImageView.layer.cornerRadius = 16;
        _profileImageView.layer.backgroundColor = [UIColor chd_lightGreyColor].CGColor;
        _profileImageView.layer.masksToBounds = YES;
    }
    return _profileImageView;
}

-(UILabel*) userNameLabel{
    if(!_userNameLabel){
        _userNameLabel = [UILabel new];
        _userNameLabel.font = [UIFont chd_fontWithFontWeight:CHDFontWeightMedium size:17];
        _userNameLabel.textColor = [UIColor blackColor];
    }
    return _userNameLabel;
}
-(UILabel*) createdDateLabel{
    if(!_createdDateLabel){
        _createdDateLabel = [UILabel new];
        _createdDateLabel.font = [UIFont chd_fontWithFontWeight:CHDFontWeightRegular size:14];
        _createdDateLabel.textColor = [UIColor chd_textExtraLightColor];
    }
    return _createdDateLabel;
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
@end
