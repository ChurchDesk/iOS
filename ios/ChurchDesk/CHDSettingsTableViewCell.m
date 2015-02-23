//
//  CHDSettingsTableViewCell.m
//  ChurchDesk
//
//  Created by Jakob Vinther-Larsen on 23/02/15.
//  Copyright (c) 2015 Shape A/S. All rights reserved.
//

#import "CHDSettingsTableViewCell.h"
@interface CHDSettingsTableViewCell()
@property (nonatomic, strong) UIView* separatorView;
@property (nonatomic, strong) UILabel* titleLabel;
@property (nonatomic, strong) UISwitch *aSwitch;
@end

@implementation CHDSettingsTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        [self makeViews];
        [self makeConstraints];
    }
    return self;
}

-(void) borderAsLast: (BOOL) last {
    if(last){
        self.separatorView.backgroundColor = [UIColor shpui_colorWithHexValue:0xc8c7cc];
        [self.separatorView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.bottom.left.right.equalTo(self);
            make.height.equalTo(@1);
        }];
    }else{
        self.separatorView.backgroundColor = [UIColor shpui_colorWithHexValue:0xd6d5d9];
        [self.separatorView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.bottom.right.equalTo(self);
            make.left.equalTo(self).with.offset(15);
            make.height.equalTo(@1);
        }];
    }
}

-(void) makeViews {
    UIView *contentView = self.contentView;

    [self addSubview:self.separatorView];
    [contentView addSubview:self.aSwitch];
    [contentView addSubview:self.titleLabel];
}
-(void) makeConstraints {
    UIView *contentView = self.contentView;

    [self borderAsLast:NO];

    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(contentView);
        make.left.equalTo(contentView).with.offset(15);
    }];

    [self.aSwitch mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.titleLabel);
        make.right.equalTo(contentView).with.offset(-15);
    }];
}

#pragma mark - Sub Views lazy initialization
-(UIView *) separatorView{
    if(!_separatorView){
        _separatorView = [UIView new];
        _separatorView.backgroundColor = [UIColor shpui_colorWithHexValue:0xd6d5d9];
    }
    return _separatorView;
}

-(UISwitch*) aSwitch {
    if(!_aSwitch){
        _aSwitch = [UISwitch new];
    }
    return _aSwitch;
}

-(UILabel*) titleLabel {
    if(!_titleLabel){
        _titleLabel = [UILabel new];
        _titleLabel.font = [UIFont chd_fontWithFontWeight:CHDFontWeightRegular size:15];
        _titleLabel.textColor = [UIColor blackColor];
    }
    return _titleLabel;
}

@end
