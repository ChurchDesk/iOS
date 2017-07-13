//
//  CHDEventTextFieldCell.m
//  ChurchDesk
//
//  Created by Mikkel Selsøe Sørensen on 06/03/15.
//  Copyright (c) 2015 Shape A/S. All rights reserved.
//

#import "CHDEventTextFieldCell.h"

@interface CHDEventTextFieldCell () <UITextFieldDelegate>

@property (nonatomic, strong) UITextField *textField;

@end

@implementation CHDEventTextFieldCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if ((self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])) {
        self.selectionStyle = UITableViewCellSeparatorStyleNone;
        self.disclosureArrowHidden = YES;
        
        [self setupSubviews];
        [self makeConstraints];
    }
    return self;
}

- (void) setupSubviews {
    [self.contentView addSubview:self.textField];
}

- (void) makeConstraints {
    [self.textField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.titleLabel);
        make.right.equalTo(self.contentView).offset(kSideMargin);
        make.top.bottom.equalTo(self.contentView);
        make.height.equalTo(@49);
    }];
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    NSString *newString = [textField.text stringByReplacingCharactersInRange:range withString:string];
    return !([newString length] > self.textFieldMaxLength && self.textFieldMaxLength != 0);
}

#pragma mark - Lazy Initialization

- (UITextField *)textField {
    if (!_textField) {
        _textField = [UITextField new];
        _textField.font = [UIFont chd_fontWithFontWeight:CHDFontWeightRegular size:17];
        _textField.textColor = [UIColor chd_textDarkColor];
        _textField.returnKeyType = UIReturnKeyDone;
        _textField.delegate = self;
    }
    return _textField;
}

@end
