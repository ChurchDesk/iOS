//
//  CHDDescriptionTableViewCell.m
//  ChurchDesk
//
//  Created by Jakob Vinther-Larsen on 23/02/15.
//  Copyright (c) 2015 Shape A/S. All rights reserved.
//

#import "CHDDescriptionTableViewCell.h"
@interface CHDDescriptionTableViewCell()
@property (nonatomic, strong) UIView* separatorView;
@property (nonatomic, strong) UIView* separatorTopView;
@property (nonatomic, strong) UILabel* titleLabel;
@property (nonatomic, strong) UILabel* descriptionLabel;
@end

@implementation CHDDescriptionTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        [self makeViews];
        [self makeConstraints];
    }
    return self;
}

-(void) makeViews {
    UIView *contentView = self.contentView;

    [self addSubview:self.separatorView];
    [self addSubview:self.separatorTopView];
    [contentView addSubview:self.titleLabel];
    [contentView addSubview:self.descriptionLabel];
}
-(void) makeConstraints {
    UIView *contentView = self.contentView;

    [self.separatorView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.right.equalTo(self);
        make.left.equalTo(self).with.offset(15);
        make.height.equalTo(@1);
    }];

    [self.separatorTopView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.equalTo(self);
        make.height.equalTo(@1);
    }];

    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(contentView).with.offset(28);
        make.left.equalTo(contentView).with.offset(15);
    }];

    [self.descriptionLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.titleLabel.mas_baseline).with.offset(14);
        make.left.equalTo(self.titleLabel);
        make.right.equalTo(contentView).with.offset(15);
        make.baseline.equalTo(contentView.mas_bottom).with.offset(-24);
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

-(UIView *) separatorTopView{
    if(!_separatorTopView){
        _separatorTopView = [UIView new];
        _separatorTopView.backgroundColor = [UIColor shpui_colorWithHexValue:0xc8c7cc];
    }
    return _separatorTopView;
}

-(UILabel*) titleLabel {
    if(!_titleLabel){
        _titleLabel = [UILabel new];
        _titleLabel.font = [UIFont chd_fontWithFontWeight:CHDFontWeightRegular size:18];
        _titleLabel.textColor = [UIColor blackColor];
    }
    return _titleLabel;
}

-(UILabel*) descriptionLabel{
    if(!_descriptionLabel){
        _descriptionLabel = [UILabel new];
        _descriptionLabel.font = [UIFont chd_fontWithFontWeight:CHDFontWeightRegular size:15];
        _descriptionLabel.textColor = [UIColor shpui_colorWithHexValue:0x646464];
        _descriptionLabel.lineBreakMode = NSLineBreakByWordWrapping;
        _descriptionLabel.numberOfLines = 0;
    }
    return _descriptionLabel;
}

@end
