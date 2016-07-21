//
// Created by Jakob Vinther-Larsen on 27/02/15.
// Copyright (c) 2015 Shape A/S. All rights reserved.
//

#import "CHDNewMessageTextFieldCell.h"


@interface CHDNewMessageTextFieldCell ()
@property(nonatomic, strong) UITextField *textField;
@end

@implementation CHDNewMessageTextFieldCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if(self){
        self.disclosureArrowHidden = YES;
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        [self makeViews];
        [self makeConstraints];
    }
    return self;
}

- (void)makeConstraints {
    UIView *contentView = self.contentView;
    [self.textField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.equalTo(contentView).offset(14);
        make.bottom.right.equalTo(contentView).offset(-14);
    }];
}

- (void)makeViews {
    UIView *contentView = self.contentView;

    [contentView addSubview:self.textField];

    self.selectedBackgroundView = nil;
}

- (UITextField *)textField {
    if(!_textField){
        _textField = [UITextField new];
        _textField.font = [UIFont chd_fontWithFontWeight:CHDFontWeightRegular size:17];
        _textField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:NSLocalizedString(@"Title", @"") attributes:@{NSForegroundColorAttributeName: [UIColor shpui_colorWithHexValue:0xa8a8a8]}];
        _textField.textColor = [UIColor chd_textDarkColor];
    }
    return _textField;
}

@end