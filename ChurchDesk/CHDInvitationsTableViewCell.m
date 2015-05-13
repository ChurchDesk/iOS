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

//Accessory buttons
@property (nonatomic, strong) UIButton* acceptButton;
@property (nonatomic, strong) UIButton* maybeButton;
@property (nonatomic, strong) UIButton* declineButton;
@end

@implementation CHDInvitationsTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if ((self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])) {

        NSArray* buttonTitles = @[NSLocalizedString(@"Confirm", @""), NSLocalizedString(@"Maybe", @""), NSLocalizedString(@"Decline", @"")];
        NSArray* buttonColors = @[[UIColor shpui_colorWithHexValue:0x62d963], [UIColor shpui_colorWithHexValue:0xc7c7cc], [UIColor shpui_colorWithHexValue:0xff3b30]];
        [self setAccessoryWithTitles:buttonTitles backgroundColors:buttonColors buttonWidth:80];

        RAC(self.locationIconView, hidden) = [RACObserve(self.locationLabel, text) map:^id(NSString *text) {
            return @(text.length == 0);
        }];
    }

    return self;
}

-(void) makeViews{
    [super makeViews];

    UIView *contentView = self.scrollContentView;

    [contentView addSubview:self.titleLabel];
    [contentView addSubview:self.invitedByLabel];

    [contentView addSubview:self.eventTimeIconView];
    [contentView addSubview:self.eventTimeLabel];

    [contentView addSubview:self.locationIconView];
    [contentView addSubview:self.locationLabel];

    [contentView addSubview:self.receivedTimeLabel];
    [contentView addSubview:self.parishLabel];
}

-(void) makeConstraints{
    [super makeConstraints];

    UIView*contentView = self.scrollContentView;

    //"Lefthand side" of the cell
    [self.titleLabel setContentCompressionResistancePriority:UILayoutPriorityDefaultLow forAxis:UILayoutConstraintAxisHorizontal];
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make){
        make.top.left.equalTo(contentView).with.offset(15);
        make.right.lessThanOrEqualTo(self.receivedTimeLabel.mas_left).offset(-10);
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

    [self.locationLabel setContentCompressionResistancePriority:UILayoutPriorityDefaultLow forAxis:UILayoutConstraintAxisHorizontal];
    [self.locationLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.locationIconView);
        make.left.equalTo(self.locationIconView.mas_right).with.offset(3);
        make.right.lessThanOrEqualTo(self.parishLabel.mas_left).offset(-10);
    }];

    [self.eventTimeIconView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.locationIconView.mas_top).with.offset(-7.5);
        make.left.equalTo(self.locationIconView);
    }];
    [self.eventTimeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.eventTimeIconView);
        make.left.equalTo(self.eventTimeIconView.mas_right).with.offset(3);
        make.right.lessThanOrEqualTo(contentView).offset(-10);
    }];

    //"Righthand side" of the cell
    [self.receivedTimeLabel setContentCompressionResistancePriority:UILayoutPriorityDefaultHigh forAxis:UILayoutConstraintAxisHorizontal];
    [self.receivedTimeLabel mas_makeConstraints:^(MASConstraintMaker *make){
        make.bottom.equalTo(self.titleLabel);
        make.right.equalTo(contentView).with.offset(-16);
    }];
    [self.parishLabel setContentCompressionResistancePriority:UILayoutPriorityDefaultHigh forAxis:UILayoutConstraintAxisHorizontal];
    [self.parishLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.locationLabel);
        make.right.equalTo(contentView).with.offset(-16);
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
        _invitedByLabel.textColor = [UIColor chd_textLightColor];
    }
    return _invitedByLabel;
}


//The location of the event
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

//Time of the event
-(UIImageView *) eventTimeIconView{
    if(!_eventTimeIconView){
        _eventTimeIconView = [[UIImageView new] initWithImage:kImgCalendarTime];
    }
    return _eventTimeIconView;
}
-(UILabel *)eventTimeLabel {
    if (!_eventTimeLabel) {
        _eventTimeLabel = [UILabel new];
        _eventTimeLabel.font = [UIFont chd_fontWithFontWeight:CHDFontWeightRegular size:14];
        _eventTimeLabel.textColor = [UIColor chd_textLightColor];
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

//Accessory buttons
-(UIButton*)acceptButton {
    return self.accessoryButtons.count >= 1? self.accessoryButtons[0] : nil;
}

-(UIButton*)maybeButton {
    return self.accessoryButtons.count >= 2? self.accessoryButtons[1] : nil;
}

-(UIButton*)declineButton {
    return self.accessoryButtons.count >= 3? self.accessoryButtons[2] : nil;
}

@end
