//
//  CHDLeftMenuTableViewCell.m
//  ChurchDesk
//
//  Created by Jakob Vinther-Larsen on 20/02/15.
//  Copyright (c) 2015 Shape A/S. All rights reserved.
//

#import "CHDLeftMenuTableViewCell.h"
@interface CHDLeftMenuTableViewCell()
@property (nonatomic, strong) UIView* separatorView;
@property (nonatomic, strong) UIImageView* thumbnailLeft;
@property (nonatomic, strong) UILabel* titleLabel;
@end

@implementation CHDLeftMenuTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self makeViews];
        [self makeConstraints];
        [self makeBindings];
    }
    return self;
}

-(void) makeViews {
    self.backgroundColor = [UIColor chd_menuLightBlue];
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    self.selectedBackgroundView.backgroundColor = self.backgroundColor;

    [self addSubview:self.separatorView];
    [self.contentView addSubview:self.titleLabel];
    [self.contentView addSubview:self.thumbnailLeft];
}

-(void) makeConstraints{
    UIView* superview = self;
    UIView *containerView = self.contentView;

    [self.separatorView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.right.left.equalTo(superview);
        make.height.equalTo(@1);
    }];

    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(containerView);
        make.left.equalTo(containerView).with.offset(54);
    }];

    [self.thumbnailLeft mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(containerView);
        make.centerX.equalTo(containerView.mas_left).with.offset(27);
    }];
}

-(void) makeBindings{
    [self.titleLabel shprac_liftSelector:@selector(setFont:) withSignal:[RACObserve(self, selected) map:^id(NSNumber *iSelected) {
        return iSelected.boolValue? [UIFont chd_fontWithFontWeight:CHDFontWeightRegular size:18] : [UIFont chd_fontWithFontWeight:CHDFontWeightMedium size:18];
    }]];
    [self.titleLabel shprac_liftSelector:@selector(setTextColor:) withSignal:[RACObserve(self, selected) map:^id(NSNumber *iSelected) {
        return iSelected.boolValue? [UIColor chd_menuSelectedColor] : [UIColor chd_menuNotSelectedColor];
    }]];

    [self.thumbnailLeft shprac_liftSelector:@selector(setTintColor:) withSignal:[RACObserve(self, selected) map:^id(NSNumber *iSelected) {
        return iSelected.boolValue? [UIColor chd_menuSelectedColor] : [UIColor chd_menuNotSelectedColor];
    }]];
}

#pragma mark - Sub Views lazy initialization
-(UIView *) separatorView{
    if(!_separatorView){
        _separatorView = [UIView new];
        _separatorView.backgroundColor = [UIColor chd_menuDarkBlue];
    }

    return _separatorView;
}

-(UIImageView*)thumbnailLeft {
    if(!_thumbnailLeft){
        _thumbnailLeft = [UIImageView new];
    }
    return _thumbnailLeft;
}

-(UILabel*)titleLabel {
    if(!_titleLabel){
        _titleLabel = [UILabel new];
//        _titleLabel.font = [UIFont chd_fontWithFontWeight:CHDFontWeightRegular size:18];
//        _titleLabel.textColor = [UIColor whiteColor];
    }
    return _titleLabel;
}

@end
