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
        make.top.left.equalTo(contentView);
        make.bottom.right.equalTo(contentView);
        //self.textViewHeight = make.height.equalTo(@30);
    }];

    [self.placeholder mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.textView).offset(14);
        make.top.equalTo(self.textView).offset(14);
    }];

    /*[self.contentView mas_makeConstraints:^(MASConstraintMaker *make) {
        self.textViewHeight = make.height.equalTo(@50);
    }];*/
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
        _textView.scrollEnabled = YES;
        _textView.layer.backgroundColor = [UIColor whiteColor].CGColor;
        _textView.contentInset = UIEdgeInsetsMake(8, 8, -8, -8);
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

/*- (CGSize)intrinsicContentSize {
    return CGSizeMake(0, 50);
}*/

- (void)textViewDidChange:(UITextView *)textView {
    CGSize contentSize = textView.contentSize;
    if(![textView.text isEqual:@""]){
        //[self.placeholder removeFromSuperview];
        self.placeholder.hidden = YES;
    }else{
        //[self.contentView addSubview:self.placeholder];
        self.placeholder.hidden = NO;
    }

    CGFloat lineHeight = self.textView.font.lineHeight;
    double numberOfLines = ceil(contentSize.height / lineHeight);

    //Get offset
    UIEdgeInsets contentInset = self.textView.contentInset;

    if(self.textViewHeight == nil) {
        CGFloat baseHeight = -contentInset.bottom + contentInset.top;
        //create constraint 
        [self.textView mas_makeConstraints:^(MASConstraintMaker *make) {
            self.textViewHeight = make.height.equalTo(@(baseHeight));
        }];
    }

    self.textViewHeight.offset(numberOfLines * lineHeight);

    [self.tableView beginUpdates];
    [self.tableView endUpdates];
}
@end