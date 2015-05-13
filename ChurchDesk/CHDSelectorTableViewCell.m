//
//  CHDSelectorTableViewCell.m
//  ChurchDesk
//
//  Created by Jakob Vinther-Larsen on 02/03/15.
//  Copyright (c) 2015 Shape A/S. All rights reserved.
//

#import "CHDSelectorTableViewCell.h"
#import "CHDDotView.h"

@interface CHDSelectorTableViewCell()
@property (nonatomic, strong) CHDDotView *dotView;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UIImageView* checkMark;
@property (nonatomic, strong) MASConstraint *titleLabelLeftConstraint;
@end

CGFloat const kTitleLabelOffsetNoColor = 14.0f;
CGFloat const kTitleLabelOffsetWithColor = 31.0f;

@implementation CHDSelectorTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if ((self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])) {
        self.disclosureArrowHidden = YES;
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        [self makeViews];
        [self makeConstraints];
        [self makeBindings];
    }
    return self;
}

-(void) makeViews {
    UIView *contentView = self.contentView;
    [contentView addSubview:self.dotView];
    [contentView addSubview:self.titleLabel];
    [contentView addSubview:self.checkMark];
}

-(void) makeConstraints {
    UIView *contentView = self.contentView;

    [self.dotView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.height.equalTo(@8);
        make.left.equalTo(contentView).offset(14);
        make.centerY.equalTo(contentView);
    }];

    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        self.titleLabelLeftConstraint = make.left.equalTo(contentView).offset(kTitleLabelOffsetNoColor);
        make.centerY.equalTo(contentView);
    }];

    [self.checkMark mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(contentView);
        make.right.equalTo(contentView).offset(-11);
    }];
}

-(void) makeBindings {

    //Set the left hand offset of the title
    RAC(self.titleLabelLeftConstraint, offset) = [RACObserve(self, dotColor) map:
        ^id(UIColor *color) {
            if([color isEqual:[UIColor clearColor]] || color == nil){
                return @(kTitleLabelOffsetNoColor);
            }
            return @(kTitleLabelOffsetWithColor);
        }];

    RAC(self.dotView, dotColor) = RACObserve(self, dotColor);

    RAC(self.checkMark, hidden) = [RACObserve(self, selected) map:^id(NSNumber * value) {
        return @(!value.boolValue);
    }];

    RAC(self.titleLabel, textColor) = [RACObserve(self, selected) map: ^id(NSNumber * value) {
        return value.boolValue? [UIColor chd_textDarkColor] : [UIColor chd_textLightColor];
    }];
}

-(UIImageView*) checkMark {
    if(!_checkMark){
        _checkMark = [[UIImageView alloc] initWithImage:kImgCheckmark];
    }
    return _checkMark;
}

-(CHDDotView*) dotView {
    if(!_dotView){
        _dotView = [CHDDotView new];
    }
    return _dotView;
}

-(UILabel*) titleLabel {
    if(!_titleLabel){
        _titleLabel = [UILabel new];
        _titleLabel.font = [UIFont chd_fontWithFontWeight:CHDFontWeightRegular size:17];
    }
    return _titleLabel;
}

@end
