//
//  CHDEventAttendanceTableViewCell.m
//  ChurchDesk
//
//  Created by Mikkel Selsøe Sørensen on 27/02/15.
//  Copyright (c) 2015 Shape A/S. All rights reserved.
//

#import "CHDEventAttendanceTableViewCell.h"

@interface CHDEventAttendanceTableViewCell ()

@property (nonatomic, strong) UIButton *attendanceButton;
@property (nonatomic, strong) UIImageView *arrowView;

@end

@implementation CHDEventAttendanceTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if ((self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])) {
        self.disclosureArrowHidden = YES;
        self.titleLabel.text = NSLocalizedString(@"Attendance", @"");
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        [self setupSubviews];
        [self makeConstraints];
    }
    return self;
}

- (void) setupSubviews {
    [self.contentView addSubview:self.attendanceButton];
    [self.contentView addSubview:self.arrowView];
}

- (void) makeConstraints {
    [self.attendanceButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.bottom.equalTo(self.contentView);
        make.right.equalTo(self.arrowView.mas_left).offset(-10);
    }];
    
    [self.arrowView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.contentView);
        make.centerX.equalTo(self.contentView.mas_right).offset(-kSideMargin);
    }];
}

#pragma mark - Lazy Initialization

- (UIButton *)attendanceButton {
    if (!_attendanceButton) {
        _attendanceButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _attendanceButton.titleLabel.font = [UIFont chd_fontWithFontWeight:CHDFontWeightRegular size:16];
    }
    return _attendanceButton;
}

- (UIImageView *)arrowView {
    if (!_arrowView) {
        _arrowView = [[UIImageView alloc] initWithImage:kImgDisclosureArrowDown];
    }
    return _arrowView;
}

@end
