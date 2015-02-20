//
//  CHDMessagesTableViewCell.m
//  ChurchDesk
//
//  Created by Jakob Vinther-Larsen on 19/02/15.
//  Copyright (c) 2015 Shape A/S. All rights reserved.
//

#import "CHDMessagesTableViewCell.h"

@interface CHDMessagesTableViewCell()
@property (nonatomic, strong) UILabel* groupLabel;
@property (nonatomic, strong) UILabel* parishLabel;
@property (nonatomic, strong) UILabel* authorLabel;
@property (nonatomic, strong) UILabel* contentLabel;
@property (nonatomic, strong) UILabel* receivedTimeLabel;

@property (nonatomic, strong) CHDDotView* receivedDot;
@end

@implementation CHDMessagesTableViewCell


-(void) makeConstraints {
    [super makeConstraints];
    UIView* contentView = self.contentView;

    [self.groupLabel mas_makeConstraints:^(MASConstraintMaker *make){
        make.top.left.equalTo(contentView).with.offset(15);
    }];

    [self.parishLabel mas_makeConstraints:^(MASConstraintMaker *make){
        make.top.equalTo(self.groupLabel);
        make.left.equalTo(self.groupLabel.mas_right).with.offset(4);
    }];

    [self.authorLabel mas_makeConstraints:^(MASConstraintMaker *make){
        make.top.equalTo(self.groupLabel.mas_baseline).with.offset(5);
        make.left.equalTo(self.groupLabel);
    }];

    [self.contentLabel mas_makeConstraints:^(MASConstraintMaker *make){
        make.top.equalTo(self.authorLabel.mas_baseline).with.offset(5);
        make.left.equalTo(self.groupLabel);
    }];

    [self.receivedTimeLabel mas_makeConstraints:^(MASConstraintMaker *make){
        make.right.equalTo(contentView).with.offset(-15);
        make.top.equalTo(contentView).with.offset(15);
    }];

    [self.receivedDot mas_makeConstraints:^(MASConstraintMaker *make){
        make.width.height.equalTo(@11);
        make.right.bottom.equalTo(@-15);
    }];
}

-(void) makeViews{
    [super makeViews];
    UIView* contentView = self.contentView;

    [contentView addSubview:self.groupLabel];
    [contentView addSubview:self.parishLabel];
    [contentView addSubview:self.authorLabel];
    [contentView addSubview:self.contentLabel];
    [contentView addSubview:self.receivedTimeLabel];
    [contentView addSubview:self.receivedDot];
}

- (UILabel*)groupLabel {
    if(!_groupLabel){
        _groupLabel = [UILabel new];
        _groupLabel.font = [UIFont chd_fontWithFontWeight:CHDFontWeightRegular size:14];
        _groupLabel.textColor = [UIColor chd_textLigthColor];
    }
    return _groupLabel;
}

- (UILabel*)parishLabel {
    if(!_parishLabel){
        _parishLabel = [UILabel new];
        _parishLabel.font = [UIFont chd_fontWithFontWeight:CHDFontWeightRegular size:14];
        _parishLabel.textColor = [UIColor chd_textExtraLightColor];
    }
    return _parishLabel;
}

- (UILabel*)authorLabel {
    if(!_authorLabel){
        _authorLabel = [UILabel new];
        _authorLabel.font = [UIFont chd_fontWithFontWeight:CHDFontWeightMedium size:18];
        _authorLabel.textColor = [UIColor chd_textDarkColor];
    }
    return _authorLabel;
}

- (UILabel*)contentLabel {
    if(!_contentLabel){
        _contentLabel = [UILabel new];
        _contentLabel.font = [UIFont chd_fontWithFontWeight:CHDFontWeightRegular size:14];
        _contentLabel.textColor = [UIColor chd_textLigthColor];
    }
    return _contentLabel;
}

- (UILabel*)receivedTimeLabel {
    if(!_receivedTimeLabel){
        _receivedTimeLabel = [UILabel new];
        _receivedTimeLabel.font = [UIFont chd_fontWithFontWeight:CHDFontWeightRegular size:14];;
        _receivedTimeLabel.textColor = [UIColor chd_textLigthColor];
    }
    return _receivedTimeLabel;
}

-(CHDDotView*) receivedDot {
    if(!_receivedDot){
        _receivedDot = [CHDDotView new];
    }
    return _receivedDot;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
