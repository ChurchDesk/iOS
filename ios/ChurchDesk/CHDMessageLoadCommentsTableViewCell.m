//
//  CHDMessageLoadCommentsTableViewCell.m
//  ChurchDesk
//
//  Created by Jakob Vinther-Larsen on 25/02/15.
//  Copyright (c) 2015 Shape A/S. All rights reserved.
//

#import "CHDMessageLoadCommentsTableViewCell.h"

@interface CHDMessageLoadCommentsTableViewCell()
@property (nonatomic, strong) UILabel* messageLabel;
@property (nonatomic, strong) UILabel* countLabel;
@end

@implementation CHDMessageLoadCommentsTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        [self.cellBackgroundView setBorderColor:[UIColor clearColor]];
    }
    return self;
}

#pragma mark - Lazy initialization

- (void) makeViews {
    [super makeViews];
    UIView *contentView = self.contentView;

    [contentView addSubview:self.messageLabel];
    [contentView addSubview:self.countLabel];
}

-(void) makeConstraints {
    [super makeConstraints];
    UIView *contentView = self.contentView;

    [self.messageLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(contentView).offset(17);
        make.left.equalTo(contentView).offset(15);
        make.baseline.equalTo(contentView).offset(-17);
    }];

    [self.countLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.messageLabel.mas_right).offset(5);
        make.centerY.equalTo(self.messageLabel);
    }];
}

-(UILabel*) messageLabel {
    if(!_messageLabel){
        _messageLabel = [UILabel new];
        _messageLabel.font = [UIFont chd_fontWithFontWeight:CHDFontWeightRegular size:16];
        _messageLabel.textColor = [UIColor chd_blueColor];
    }
    return _messageLabel;
}

-(UILabel*) countLabel {
    if(!_countLabel){
        _countLabel = [UILabel new];
        _countLabel.font = [UIFont chd_fontWithFontWeight:CHDFontWeightRegular size:16];
        _countLabel.textColor = [UIColor chd_textExtraLightColor];
    }
    return _countLabel;
}

@end
