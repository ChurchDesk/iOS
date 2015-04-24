//
// Created by Jakob Vinther-Larsen on 24/04/15.
// Copyright (c) 2015 Shape A/S. All rights reserved.
//

#import "CHDActiveFilterView.h"
@interface CHDActiveFilterView()
@property (nonatomic, strong) UIView *titleContainer;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *filterName;
@property (nonatomic, strong) UIButton *closeButton;
@end

@implementation CHDActiveFilterView

- (instancetype)init {
    if(self = [super init]){
        [self setup];
    }
    return self;
}

-(void)setup{
    self.backgroundColor = [UIColor chd_darkBlueColor];
    [self addSubview:self.titleContainer];
    [self.titleContainer addSubview:self.titleLabel];
    [self.titleContainer addSubview:self.filterName];
    [self addSubview:self.closeButton];

    [self.titleContainer mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self);
        make.centerY.equalTo(self);
        make.left.equalTo(self.titleLabel);
        make.right.equalTo(self.filterName);
    }];
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.filterName.mas_left).offset(-5);
        make.centerY.equalTo(self.titleContainer);
    }];
    [self.filterName mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.titleContainer);
    }];

    [self.closeButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.equalTo(self);
        make.width.equalTo(self.closeButton.mas_height);
        make.right.equalTo(self).offset(-5);
        make.centerY.equalTo(self);
    }];
}
-(UILabel*) titleLabel{
    if(!_titleLabel){
        _titleLabel = [UILabel new];
        _titleLabel.font = [UIFont chd_fontWithFontWeight:CHDFontWeightRegular size:14];
        _titleLabel.textColor = [UIColor whiteColor];
        _titleLabel.text = NSLocalizedString(@"title_before_filter", @"Filter in calendar or messages");
    }
    return _titleLabel;
}
-(UILabel*) filterName{
    if(!_filterName){
        _filterName = [UILabel new];
        _filterName.font = [UIFont chd_fontWithFontWeight:CHDFontWeightMedium size:14];
        _filterName.textColor = [UIColor whiteColor];
    }
    return _filterName;
}
-(UIButton*)closeButton{
    if(!_closeButton){
        _closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_closeButton setImage:kImgFilterWarning forState:UIControlStateNormal];
    }
    return _closeButton;
}
-(UIView*)titleContainer{
    if(!_titleContainer){
        _titleContainer = [UIView new];
    }
    return _titleContainer;
}
@end