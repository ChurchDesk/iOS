//
//  CHDInvitationsTableViewCell.m
//  ChurchDesk
//
//  Created by Jakob Vinther-Larsen on 18/02/15.
//  Copyright (c) 2015 Shape A/S. All rights reserved.
//

#import "CHDInvitationsTableViewCell.h"

@interface CHDInvitationsTableViewCell()
@property (nonatomic, strong) UILabel* titleLabel;
@property (nonatomic, strong) UILabel* invitedByLabel;
//The location of the event
@property (nonatomic, strong) UIImageView* locationIconView;
@property (nonatomic, strong) UILabel* locationLabel;
//The time invitation was received
@property (nonatomic, strong) UILabel* receivedTimeLabel;
//Time of the event
@property (nonatomic, strong) UIImageView* eventTimeIconView;
@property (nonatomic, strong) UILabel* eventTimeLabel;
@property (nonatomic, strong) UILabel* parishLabel;
@end

@implementation CHDInvitationsTableViewCell

-(void) makeViews{
    [super makeViews];

    [self.contentView addSubview:self.titleLabel];
    [self.contentView addSubview:self.invitedByLabel];

    [self.contentView addSubview:self.eventTimeIconView];
    [self.contentView addSubview:self.eventTimeLabel];

    [self.contentView addSubview:self.locationIconView];
    [self.contentView addSubview:self.locationLabel];

    [self.contentView addSubview:self.receivedTimeLabel];
    [self.contentView addSubview:self.parishLabel];
}

-(void) makeConstraints{
    [super makeConstraints];

    UIView*contentView = self.contentView;

    //"Lefthand side" of the cell
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make){
        make.top.left.equalTo(contentView).with.offset(15);
    }];

    [self.invitedByLabel mas_makeConstraints:^(MASConstraintMaker *make){
        make.top.equalTo(self.titleLabel.mas_baseline).with.offset(4);
        make.left.equalTo(self.titleLabel);
    }];

    //UPDATE Constraints for Event time
    [self.locationIconView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(contentView).with.offset(-15);
        make.left.equalTo(contentView).with.offset(16);
    }];

    [self.locationLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.locationIconView);
        make.left.equalTo(self.locationIconView.mas_right).with.offset(3);
    }];

    [self.eventTimeIconView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.locationIconView.mas_top).with.offset(-7.5);
        make.left.equalTo(self.locationIconView);
    }];
    [self.eventTimeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.eventTimeIconView);
        make.left.equalTo(self.eventTimeIconView.mas_right).with.offset(3);
    }];

    //"Righthand side" of the cell
    [self.receivedTimeLabel mas_makeConstraints:^(MASConstraintMaker *make){
        make.bottom.equalTo(self.titleLabel);
        make.right.equalTo(contentView).with.offset(-16);
    }];

    [self.parishLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.locationLabel);
        make.right.equalTo(self.receivedTimeLabel);
    }];
}

-(UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [UILabel new];
        _titleLabel.font = [UIFont chd_fontWithFontWeight:CHDFontWeightRegular size:18];
        _titleLabel.textColor = [UIColor chd_textDarkColor];
    }
    return _titleLabel;
}

-(UILabel *)invitedByLabel {
    if (!_invitedByLabel) {
        _invitedByLabel = [UILabel new];
        _invitedByLabel.font = [UIFont chd_fontWithFontWeight:CHDFontWeightRegular size:14];
        _invitedByLabel.textColor = [UIColor chd_textLigthColor];
    }
    return _invitedByLabel;
}


//The location of the event
-(UILabel *)locationLabel {
    if (!_locationLabel) {
        _locationLabel = [UILabel new];
        _locationLabel.font = [UIFont chd_fontWithFontWeight:CHDFontWeightRegular size:14];
        _locationLabel.textColor = [UIColor chd_textLigthColor];
    }
    return _locationLabel;
}
-(UIImageView *) locationIconView{
    if(!_locationIconView){
        _locationIconView = [[UIImageView new] initWithImage:kImgLocationIcon];
    }
    return _locationIconView;
}

//Time of the event
-(UIImageView *) eventTimeIconView{
    if(!_eventTimeIconView){
        _eventTimeIconView = [[UIImageView new] initWithImage:kImgTimeIcon];
    }
    return _eventTimeIconView;
}
-(UILabel *)eventTimeLabel {
    if (!_eventTimeLabel) {
        _eventTimeLabel = [UILabel new];
        _eventTimeLabel.font = [UIFont chd_fontWithFontWeight:CHDFontWeightRegular size:14];
        _eventTimeLabel.textColor = [UIColor chd_textLigthColor];
    }
    return _eventTimeLabel;
}

//The time the invitation was received
-(UILabel *)receivedTimeLabel {
    if (!_receivedTimeLabel) {
        _receivedTimeLabel = [UILabel new];
        _receivedTimeLabel.font = [UIFont chd_fontWithFontWeight:CHDFontWeightRegular size:14];
        _receivedTimeLabel.textColor = [UIColor chd_textDarkColor];
    }
    return _receivedTimeLabel;
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
