//
//  CHDUserAttendanceTableViewCell.m
//  ChurchDesk
//
//  Created by Mikkel Selsøe Sørensen on 26/03/15.
//  Copyright (c) 2015 Shape A/S. All rights reserved.
//

#import "CHDUserAttendanceTableViewCell.h"

static CGFloat kImageSize = 28.0f;

@interface CHDUserAttendanceTableViewCell ()

@property (nonatomic, strong) UIImageView *userImageView;
@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UIImageView *statusImageView;

@property (nonatomic, strong) UIView *topLine;
@property (nonatomic, strong) UIView *bottomLine;
@property (nonatomic, strong) UIView *bottomFullLine;

@end

@implementation CHDUserAttendanceTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if ((self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.backgroundColor = [UIColor whiteColor];
        
        [self setupSubviews];
        [self makeConstraints];
        [self setupBindings];
    }
    return self;
}

- (void) setupSubviews {
    [self.contentView addSubview:self.userImageView];
    [self.contentView addSubview:self.nameLabel];
    [self.contentView addSubview:self.statusImageView];
    [self addSubview:self.topLine];
    [self addSubview:self.bottomFullLine];
    [self addSubview:self.bottomLine];
}

- (void) makeConstraints {
    [self.userImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView).offset(15);
        make.top.equalTo(self.contentView).offset(7);
        make.bottom.equalTo(self.contentView).offset(-8);
        make.width.height.equalTo(@(kImageSize));
    }];
    
    [self.nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.contentView);
        make.left.equalTo(self.contentView).offset(52);
        make.right.lessThanOrEqualTo(self.statusImageView.mas_left).offset(-10);
    }];
    
    [self.statusImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.contentView);
        make.right.equalTo(self.contentView).offset(-15);
    }];
    
    [self.topLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.equalTo(self);
        make.height.equalTo(@1);
    }];
    
    [self.bottomFullLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.equalTo(self);
        make.height.equalTo(@1);
    }];
    
    [self.bottomLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self).offset(52);
        make.bottom.right.equalTo(self);
        make.height.equalTo(@1);
    }];
}

- (void) setupBindings {
    RAC(self.statusImageView, image) = [RACObserve(self, status) map:^id(NSNumber *nStatus) {
        CHDEventResponse response = nStatus.unsignedIntegerValue;
        switch (response) {
            case CHDEventResponseGoing:
                return kImgEventAttendanceGoing;
            case CHDEventResponseNotGoing:
                return kImgEventAttendanceDeclined;
            case CHDEventResponseMaybe:
                return kImgEventAttendanceMaybe;
            case CHDEventResponseNone:
                return kImgEventAttendanceNoreply;
            default:
                return kImgEventAttendanceNoreply;
        }
    }];
    
    RAC(self.topLine, hidden) = RACObserve(self, topLineHidden);
    RAC(self.bottomFullLine, hidden) = [RACObserve(self, bottomLineFull) not];
}

#pragma mark - Lazy Initialization

- (UIImageView *)userImageView {
    if (!_userImageView) {
        _userImageView = [UIImageView new];
        _userImageView.layer.cornerRadius = kImageSize/2;
        _userImageView.layer.backgroundColor = [UIColor chd_lightGreyColor].CGColor;
        _userImageView.clipsToBounds = YES;
    }
    return _userImageView;
}

- (UILabel *)nameLabel {
    if (!_nameLabel) {
        _nameLabel = [UILabel chd_regularLabelWithSize:17];
    }
    return _nameLabel;
}

- (UIImageView *)statusImageView {
    if (!_statusImageView) {
        _statusImageView = [[UIImageView alloc] init];
    }
    return _statusImageView;
}

- (UIView *)topLine {
    if (!_topLine) {
        _topLine = [UIView new];
        _topLine.backgroundColor = [UIColor chd_cellDividerColor];
    }
    return _topLine;
}

- (UIView *)bottomLine {
    if (!_bottomLine) {
        _bottomLine = [UIView new];
        _bottomLine.backgroundColor = [UIColor chd_cellDividerColor];
    }
    return _bottomLine;
}

- (UIView *)bottomFullLine {
    if (!_bottomFullLine) {
        _bottomFullLine = [UIView new];
        _bottomFullLine.backgroundColor = [UIColor chd_cellDividerColor];
    }
    return _bottomFullLine;
}
@end
