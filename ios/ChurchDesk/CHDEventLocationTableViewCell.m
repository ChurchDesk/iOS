//
//  CHDEventLocationTableViewCell.m
//  ChurchDesk
//
//  Created by Mikkel Selsøe Sørensen on 26/02/15.
//  Copyright (c) 2015 Shape A/S. All rights reserved.
//

#import "CHDEventLocationTableViewCell.h"

@interface CHDEventLocationTableViewCell ()

@property (nonatomic, strong) UIButton *directionsButton;

@end

@implementation CHDEventLocationTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if ((self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])) {
        self.iconImageView.image = kImgEventLocation;
        self.disclosureArrowHidden = YES;
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        [self setupSubviews];
        [self makeConstraints];
    }
    return self;
}

- (void) setupSubviews {
    [self.contentView addSubview:self.directionsButton];
}

- (void) makeConstraints {
    [self.directionsButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.contentView);
        make.right.equalTo(self.contentView);
        make.size.equalTo([NSValue valueWithCGSize:CGSizeMake(44, 44)]);
    }];
    
    [self.titleLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.contentView).offset(kSideMargin);
        make.left.equalTo(self.iconImageView.mas_right).offset(6);
        make.right.lessThanOrEqualTo(self.directionsButton.mas_left).offset(-6);
        make.bottom.equalTo(self.contentView).offset(-kSideMargin);
    }];
}

#pragma mark - Lazy Initialization

- (UIButton *)directionsButton {
    if (!_directionsButton) {
        _directionsButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_directionsButton setImage:kImgMapNavigationArrow forState:UIControlStateNormal];
    }
    return _directionsButton;
}

@end
