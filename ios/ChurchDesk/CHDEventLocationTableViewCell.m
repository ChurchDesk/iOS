//
//  CHDEventLocationTableViewCell.m
//  ChurchDesk
//
//  Created by Mikkel Selsøe Sørensen on 26/02/15.
//  Copyright (c) 2015 Shape A/S. All rights reserved.
//

#import "CHDEventLocationTableViewCell.h"

@interface CHDEventLocationTableViewCell ()

@property (nonatomic, strong) UIImageView *directionsImageView;

@end

@implementation CHDEventLocationTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if ((self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])) {
        self.iconImageView.image = kImgEventGroup;
        self.disclosureArrowHidden = YES;
        
        [self setupSubviews];
        [self makeConstraints];
    }
    return self;
}

- (void) setupSubviews {
    [self.contentView addSubview:self.directionsImageView];
}

- (void) makeConstraints {
    [self.directionsImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.contentView);
        make.right.equalTo(self.contentView).offset(-kSideMargin);
    }];
}

#pragma mark - Lazy Initialization

- (UIImageView *)directionsImageView {
    if (!_directionsImageView) {
        _directionsImageView = [[UIImageView alloc] initWithImage:kImgMapNavigationArrow];
    }
    return _directionsImageView;
}

@end
