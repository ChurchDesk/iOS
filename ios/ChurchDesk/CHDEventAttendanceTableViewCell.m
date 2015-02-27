//
//  CHDEventAttendanceTableViewCell.m
//  ChurchDesk
//
//  Created by Mikkel Selsøe Sørensen on 27/02/15.
//  Copyright (c) 2015 Shape A/S. All rights reserved.
//

#import "CHDEventAttendanceTableViewCell.h"

@interface CHDEventAttendanceTableViewCell ()

@property (nonatomic, strong) UILabel *attendanceLabel;
@property (nonatomic, strong) UIImageView *arrowView;

@end

@implementation CHDEventAttendanceTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if ((self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])) {
        self.disclosureArrowHidden = YES;
        self.titleLabel.text = NSLocalizedString(@"Attendance", @"");
        [self setupSubviews];
        [self makeConstraints];
    }
    return self;
}

- (void) setupSubviews {
    [self.contentView addSubview:self.attendanceLabel];
    [self.contentView addSubview:self.arrowView];
}

- (void) makeConstraints {
    [self.attendanceLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.contentView);
        make.right.equalTo(self.arrowView.mas_left).offset(-10);
    }];
    
    [self.arrowView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.contentView);
        make.centerX.equalTo(self.contentView.mas_right).offset(-kSideMargin);
    }];
}

#pragma mark - Lazy Initialization

- (UILabel *)attendanceLabel {
    if (!_attendanceLabel) {
        _attendanceLabel = [UILabel chd_regularLabelWithSize:16];
    }
    return _attendanceLabel;
}

- (UIImageView *)arrowView {
    if (!_arrowView) {
        _arrowView = [[UIImageView alloc] initWithImage:kImgDisclosureArrowDown];
    }
    return _arrowView;
}

@end
