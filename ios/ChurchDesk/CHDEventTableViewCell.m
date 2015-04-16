//
//  CHDEventTableViewCell.m
//  ChurchDesk
//
//  Created by Jakob Vinther-Larsen on 18/02/15.
//  Copyright (c) 2015 Shape A/S. All rights reserved.
//

#import "CHDEventTableViewCell.h"
@interface CHDEventTableViewCell()
@property (nonatomic, strong) UILabel* titleLabel;
@property (nonatomic, strong) UILabel* locationLabel;
@property (nonatomic, strong) UIImageView* locationIconView;
@property (nonatomic, strong) UILabel* dateTimeLabel;
@property (nonatomic, strong) UILabel* parishLabel;
@end

@implementation CHDEventTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if ((self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])) {
        RAC(self.locationIconView, hidden) = [RACObserve(self.locationLabel, text) map:^id(NSString *text) {
            return @(text.length == 0);
        }];
    }
    return self;
}

-(void) makeViews{
    [super makeViews];

    [self.contentView addSubview:self.titleLabel];
    [self.contentView addSubview:self.locationIconView];
    [self.contentView addSubview:self.locationLabel];
    [self.contentView addSubview:self.dateTimeLabel];
    [self.contentView addSubview:self.parishLabel];
}

-(void) makeConstraints{
    [super makeConstraints];

    UIView*contentView = self.contentView;

    [self.titleLabel setContentCompressionResistancePriority:UILayoutPriorityDefaultLow forAxis:UILayoutConstraintAxisHorizontal];
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make){
        make.top.left.equalTo(contentView).with.offset(10);
        make.right.lessThanOrEqualTo(self.dateTimeLabel.mas_left).offset(-4);
    }];

    [self.locationIconView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.locationLabel);
        make.left.equalTo(self.titleLabel);
    }];
    [self.locationLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.titleLabel.mas_baseline).offset(8);
        make.left.equalTo(self.locationIconView.mas_right).with.offset(3);
    }];

    [self.dateTimeLabel mas_makeConstraints:^(MASConstraintMaker *make){
        make.baseline.equalTo(self.titleLabel);
        make.right.equalTo(contentView).with.offset(-16);
    }];

    [self.parishLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.titleLabel.mas_baseline).offset(8);
        make.right.equalTo(self.dateTimeLabel);
    }];
}

-(UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [UILabel new];
        _titleLabel.font = [UIFont chd_fontWithFontWeight:CHDFontWeightMedium size:18];
        _titleLabel.textColor = [UIColor chd_textDarkColor];
    }
    return _titleLabel;
}
-(UILabel *)locationLabel {
    if (!_locationLabel) {
        _locationLabel = [UILabel new];
        _locationLabel.font = [UIFont chd_fontWithFontWeight:CHDFontWeightRegular size:14];
        _locationLabel.textColor = [UIColor chd_textLightColor];
    }
    return _locationLabel;
}
-(UIImageView *) locationIconView{
    if(!_locationIconView){
        _locationIconView = [[UIImageView new] initWithImage:kImgCalendarTimeLocation];
    }
    return _locationIconView;
}
-(UILabel *)dateTimeLabel {
    if (!_dateTimeLabel) {
        _dateTimeLabel = [UILabel new];
        _dateTimeLabel.font = [UIFont chd_fontWithFontWeight:CHDFontWeightRegular size:14];
        _dateTimeLabel.textColor = [UIColor chd_textDarkColor];
    }
    return _dateTimeLabel;
}
-(UILabel *)parishLabel {
    if (!_parishLabel) {
        _parishLabel = [UILabel new];
        _parishLabel.font = [UIFont chd_fontWithFontWeight:CHDFontWeightRegular size:14];
        _parishLabel.textColor = [UIColor chd_textExtraLightColor];
    }
    return _parishLabel;
}

@end
