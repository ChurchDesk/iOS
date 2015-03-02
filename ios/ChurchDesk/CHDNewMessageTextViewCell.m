//
// Created by Jakob Vinther-Larsen on 27/02/15.
// Copyright (c) 2015 Shape A/S. All rights reserved.
//

#import "CHDNewMessageTextViewCell.h"

@interface CHDNewMessageTextViewCell()
@property (nonatomic, strong) UITextView* textView;
@property (nonatomic, strong) UILabel *placeholder;
@property (nonatomic, strong) MASConstraint *textViewHeight;
@end

@implementation CHDNewMessageTextViewCell
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if(self){
        self.disclosureArrowHidden = YES;
        self.selectionStyle = UITableViewCellStyleDefault;
        [self makeViews];
        [self makeConstraints];

    }
    return self;
}


- (void)makeConstraints {
    UIView *contentView = self.contentView;

    [self.textView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.equalTo(contentView).offset(8);
        make.right.equalTo(contentView).offset(-8);
        make.bottom.equalTo(contentView).offset(-20);
    }];

    [self.placeholder mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(contentView).offset(14);
        make.top.equalTo(contentView).offset(14);
    }];
}

- (void)makeViews {
    UIView *contentView = self.contentView;

    [contentView addSubview:self.textView];
    [contentView addSubview:self.placeholder];
}

- (UITextView *)textView {
    if(!_textView){
        _textView = [UITextView new];
        _textView.delegate = self;
        _textView.scrollEnabled = NO;
        _textView.layer.backgroundColor = [UIColor whiteColor].CGColor;
        _textView.font = [UIFont chd_fontWithFontWeight:CHDFontWeightRegular size:17];
        _textView.textColor = [UIColor chd_textDarkColor];
    }
    return _textView;
}
-(UILabel*) placeholder {
    if(!_placeholder){
        _placeholder = [UILabel new];
        _placeholder.text = NSLocalizedString(@"Write your message here...", @"");
        _placeholder.font = [UIFont chd_fontWithFontWeight:CHDFontWeightRegular size:17];
        _placeholder.textColor = [UIColor shpui_colorWithHexValue:0xa8a8a8];
    }
    return _placeholder;
}

- (CGSize)intrinsicContentSize {
    return CGSizeMake(0, 52);
}

- (void)textViewDidChange:(UITextView *)textView {

    if(![textView.text isEqual:@""]){
        self.placeholder.hidden = YES;
    }else{
        self.placeholder.hidden = NO;
    }

    CGFloat lineHeight = self.textView.font.lineHeight;

    CGRect sizeToFit = [[textView layoutManager] usedRectForTextContainer:textView.textContainer];
    CGFloat numberOfLines = ceil(sizeToFit.size.height / lineHeight);

    CGRect frame = textView.frame;
    frame.size.height = numberOfLines * lineHeight;

    textView.frame = frame;

    [self.tableView beginUpdates];
    [self.tableView endUpdates];
}

/*- (CGPoint) cursorPositionForTextView: (UITextView *)textView {
    CGRect cursorPosition = [textView caretRectForPosition:textView.selectedTextRange.start];
    return cursorPosition.origin;
}*/
@end