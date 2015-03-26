//
//  CHDMessageCommentView.m
//  ChurchDesk
//
//  Created by Jakob Vinther-Larsen on 25/02/15.
//  Copyright (c) 2015 Shape A/S. All rights reserved.
//

#import "CHDMessageCommentView.h"
#import "CHDInputAccessoryObserveView.h"

@interface CHDMessageCommentView()
@property (nonatomic, strong) UIButton* replyButton;
@property (nonatomic, strong) UITextView *replyTextView;
@property (nonatomic) BOOL hasText;

@property (nonatomic, strong) UILabel *placeholder;

@property (nonatomic, strong) MASConstraint *replyTextViewHeight;
@end

@implementation CHDMessageCommentView

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.backgroundColor = [UIColor shpui_colorWithHexValue:0xf7f7f7];
        [self makeViews];
        [self makeConstraints];
        [self makeBindings];
    }
    return self;
}

#pragma mark - Lazy initialization

-(void) makeViews {
    [self addSubview:self.replyButton];
    [self addSubview:self.replyTextView];
    [self addSubview:self.placeholder];
}

-(void) makeConstraints{
    [self.replyButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self).offset(-10);
        make.right.equalTo(self).offset(-15);
        make.top.greaterThanOrEqualTo(self).offset(10);
    }];

    CGFloat lineHeight = self.replyTextView.font.lineHeight;
    [self.replyTextView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.replyButton.mas_left).offset(-15);
        make.left.equalTo(self).offset(8);
        make.bottom.equalTo(self).offset(-8);
        make.top.equalTo(self).offset(8);
        self.replyTextViewHeight = make.height.greaterThanOrEqualTo(@(lineHeight));
    }];

    [self.placeholder mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.replyTextView).offset(8);
        make.centerY.equalTo(self.replyTextView);
    }];
}

-(void) makeBindings {
    [self rac_liftSelector:@selector(textDidChange:) withSignals:[self.replyTextView rac_textSignal], nil];

    RAC(self.replyTextView, backgroundColor) = [RACObserve(self.replyTextView, editable) map:^id(NSNumber * iEnabled) {
        return iEnabled.boolValue? [UIColor whiteColor] : [UIColor chd_lightGreyColor];
    }];
}

-(UIButton*) replyButton{
    if(!_replyButton){
        _replyButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _replyButton.titleLabel.font = [UIFont chd_fontWithFontWeight:CHDFontWeightRegular size:15];
        [_replyButton setTitle:NSLocalizedString(@"Reply", @"") forState:UIControlStateNormal];
        [_replyButton setTitleColor:[UIColor chd_textDarkColor] forState:UIControlStateNormal];
        [_replyButton setTitleColor:[UIColor shpui_colorWithHexValue:0xa8a8a8] forState:UIControlStateDisabled];
    }
    return _replyButton;
}

-(UITextView*) replyTextView{
    if(!_replyTextView){
        _replyTextView = [UITextView new];
        _replyTextView.font = [UIFont chd_fontWithFontWeight:CHDFontWeightRegular size:15];
        //_replyTextView.textColor = [UIColor shpui_colorWithHexValue:0xa8a8a8];
        _replyTextView.layer.borderColor = [UIColor shpui_colorWithHexValue:0xc8c7cc].CGColor;
        _replyTextView.layer.borderWidth = 1.0;
        _replyTextView.layer.cornerRadius = 3.0;
        _replyTextView.delegate = self;
        _replyTextView.scrollEnabled = NO;
        _replyTextView.inputAccessoryView = [CHDInputAccessoryObserveView new];
    }
    return _replyTextView;
}

-(UILabel*) placeholder {
    if(!_placeholder){
        _placeholder = [UILabel new];
        _placeholder.text = NSLocalizedString(@"Write a comment", @"");
        _placeholder.font = [UIFont chd_fontWithFontWeight:CHDFontWeightRegular size:15];
        _placeholder.textColor = [UIColor shpui_colorWithHexValue:0xa8a8a8];
    }
    return _placeholder;
}

- (CGSize)intrinsicContentSize {
    return CGSizeMake(0, 50);
}

- (void) clearTextInput {
    [self setTextInput:@""];
}

- (void) setTextInput: (NSString*) text {
    [self.replyTextView setText:text];
    [self textDidChange:text];
}

#pragma mark - TextView
- (void)textDidChange:(NSString *)text {

    if(![self.replyTextView.text isEqual:@""]){
        self.placeholder.hidden = YES;
        self.hasText = YES;
    }else{
        self.placeholder.hidden = NO;
        self.hasText = NO;
    }

    if(![self doesFit:self.replyTextView]){
        self.replyTextView.scrollEnabled = YES;
    }else{
        self.replyTextView.scrollEnabled = NO;
    }

    CGFloat lineHeight = self.replyTextView.font.lineHeight;

    CGRect sizeToFit = [[self.replyTextView layoutManager] usedRectForTextContainer:self.replyTextView.textContainer];
    CGFloat numberOfLines = (sizeToFit.size.height / lineHeight);

    CGFloat newHeight = numberOfLines * lineHeight;

    self.replyTextViewHeight.offset(newHeight);
}

- (BOOL)doesFit:(UITextView*)textView {
    // Get the textView frame
    CGFloat viewHeight = textView.frame.size.height;
    CGFloat width = textView.textContainer.size.width;

    NSMutableAttributedString *atrs = [[NSMutableAttributedString alloc] initWithAttributedString: textView.textStorage];

    NSTextStorage *textStorage = [[NSTextStorage alloc] initWithAttributedString:atrs];
    NSTextContainer *textContainer = [[NSTextContainer alloc] initWithSize: CGSizeMake(width, FLT_MAX)];
    NSLayoutManager *layoutManager = [[NSLayoutManager alloc] init];

    [layoutManager addTextContainer:textContainer];
    [textStorage addLayoutManager:layoutManager];
    CGFloat textHeight = [layoutManager usedRectForTextContainer:textContainer].size.height;

    return !(textHeight > (viewHeight + 2));

}
@end
