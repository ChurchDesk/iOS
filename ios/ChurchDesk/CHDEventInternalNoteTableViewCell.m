//
//  CHDEventInternalNoteTableViewCell.m
//  ChurchDesk
//
//  Created by Mikkel Selsøe Sørensen on 02/03/15.
//  Copyright (c) 2015 Shape A/S. All rights reserved.
//

#import "CHDEventInternalNoteTableViewCell.h"

@interface CHDEventInternalNoteTableViewCell ()

@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *noteLabel;

@end

@implementation CHDEventInternalNoteTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if ((self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])) {
        self.titleLabel.text = NSLocalizedString(@"Internal Note", @"");
        
        [self setupSubviews];
        [self makeConstraints];
    }
    return self;
}

- (void) setupSubviews {
    [self.contentView addSubview:self.titleLabel];
    [self.contentView addSubview:self.noteLabel];
}

- (void) makeConstraints {
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.equalTo(self.contentView).offset(kSideMargin);
    }];
    
    [self.noteLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView).offset(kSideMargin);
        make.top.equalTo(self.titleLabel.mas_bottom).offset(10);
        make.right.equalTo(self.contentView).offset(-30);
        make.bottom.equalTo(self.contentView).offset(-kSideMargin);
    }];
}

#pragma mark - Lazy Initialization

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [UILabel chd_regularLabelWithSize:17];
    }
    return _titleLabel;
}

- (UILabel *)noteLabel {
    if (!_noteLabel) {
        _noteLabel = [UILabel chd_regularLabelWithSize:15];
        _noteLabel.textColor = [UIColor chd_textLightColor];
        _noteLabel.numberOfLines = 3;
    }
    return _noteLabel;
}

@end
