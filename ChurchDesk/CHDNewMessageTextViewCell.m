//
// Created by Jakob Vinther-Larsen on 27/02/15.
// Copyright (c) 2015 Shape A/S. All rights reserved.
//

#import "CHDNewMessageTextViewCell.h"
static CGFloat kNewMessageMinimumHeight = 240;

@interface CHDNewMessageTextViewCell()
@property (nonatomic, strong) UITextView* textView;
@property (nonatomic, strong) UILabel *placeholder;
@property (nonatomic, strong) MASConstraint *textViewHeight;
@end
float height = 0;
@implementation CHDNewMessageTextViewCell
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if(self){
        self.disclosureArrowHidden = YES;
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        [self makeViews];
        [self makeConstraints];
        [self makeBindings];
    }
    return self;
}


- (void)makeConstraints {
    UIView *contentView = self.contentView;

    [self.textView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.contentView);
        self.textViewHeight = make.height.equalTo(@10).offset(kNewMessageMinimumHeight);
    }];

    [self.placeholder mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(contentView).offset(kSideMargin);
        make.top.equalTo(contentView).offset(14);
    }];
}

- (void)makeViews {
    UIView *contentView = self.contentView;

    [contentView addSubview:self.textView];
    [contentView addSubview:self.placeholder];
}

-(void)makeBindings {
    [self rac_liftSelector:@selector(textDidChange:) withSignals:self.textView.rac_textSignal, nil];
}

- (UITextView *)textView {
    if(!_textView){
        _textView = [UITextView new];
        _textView.layer.backgroundColor = [UIColor whiteColor].CGColor;
        _textView.textColor = [UIColor chd_textDarkColor];
        _textView.scrollEnabled = NO;
        _textView.textContainerInset = UIEdgeInsetsMake(kSideMargin, kSideMargin-2, 0, kSideMargin);
        _textView.delegate = self;
        _textView.font = [UIFont chd_fontWithFontWeight:CHDFontWeightRegular size:17];
        _textView.clipsToBounds = YES;
        _textView.textContainer.widthTracksTextView = YES;
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

- (void)textDidChange:(NSString *)text {

    if(![self.textView.text isEqual:@""]){
        self.placeholder.hidden = YES;
    }else{
        self.placeholder.hidden = NO;
    }
    
    CGSize contentSize = [self.textView sizeThatFits:CGSizeMake(self.textView.frame.size.width, CGFLOAT_MAX)];
    contentSize.height = MAX(kNewMessageMinimumHeight, contentSize.height);
    if (height < contentSize.height) {
        [self.textViewHeight setOffset:contentSize.height + (kSideMargin*2)];
        [self.tableView beginUpdates];
        [self.tableView endUpdates];
        height = contentSize.height;
    }
    
}

@end