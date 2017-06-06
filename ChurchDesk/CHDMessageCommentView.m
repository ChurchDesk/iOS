//
//  CHDMessageCommentView.m
//  ChurchDesk
//
//  Created by Jakob Vinther-Larsen on 25/02/15.
//  Copyright (c) 2015 Shape A/S. All rights reserved.
//

#import "CHDMessageCommentView.h"
#import "CHDInputAccessoryObserveView.h"

NSInteger const kTextViewVerticalMargin = 16;

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
        make.left.equalTo(self.replyButton.mas_right).offset(-50);
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

    [self shprac_liftSelector:@selector(relayoutTextField) withSignal:[RACObserve(self, textViewMaxHeight) skip:1]];


    [self.replyButton rac_liftSelector:@selector(setTitle:forState:) withSignals:[RACObserve(self, state) map:^id(NSNumber *iState) {
        if(iState.unsignedIntegerValue == CHDCommentViewStateUpdate){
            return NSLocalizedString(@"Update", @"");
        }
        return NSLocalizedString(@"Reply", @"");
    }], [RACSignal return:@(UIControlStateNormal)], nil];
}

-(UIButton*) replyButton{
    if(!_replyButton){
        _replyButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _replyButton.titleLabel.font = [UIFont chd_fontWithFontWeight:CHDFontWeightRegular size:15];
        [_replyButton setTitleColor:[UIColor chd_blueColor] forState:UIControlStateNormal];
        [_replyButton setTitleColor:[UIColor shpui_colorWithHexValue:0xa8a8a8] forState:UIControlStateDisabled];
    }
    return _replyButton;
}

-(UITextView*) replyTextView{
    if(!_replyTextView){
        _replyTextView = [UITextView new];
        _replyTextView.font = [UIFont chd_fontWithFontWeight:CHDFontWeightRegular size:15];
        _replyTextView.layer.borderColor = [UIColor shpui_colorWithHexValue:0xc8c7cc].CGColor;
        _replyTextView.layer.borderWidth = 1.0;
        _replyTextView.layer.cornerRadius = 3.0;
        _replyTextView.delegate = self;
        _replyTextView.scrollEnabled = YES;
        _replyTextView.showsHorizontalScrollIndicator = NO;
        _replyTextView.inputAccessoryView = [CHDInputAccessoryObserveView new];
        _replyTextView.editable = NO;
        _replyTextView.textContainer.maximumNumberOfLines = 150;
        _replyTextView.dataDetectorTypes = UIDataDetectorTypeLink;
        _replyTextView.selectable = YES;
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
    [self relayoutTextField];
}

-(void) relayoutTextField {
    NSString *text = self.replyTextView.text;

    if(![text isEqual:@""]){
        self.placeholder.hidden = YES;
        self.hasText = YES;
    }else{
        self.placeholder.hidden = NO;
        self.hasText = NO;
    }

    //Check whether scroll should enable
    CGFloat textHeight = [self heightForText:text];

    NSInteger maxHeight = self.textViewMaxHeight - kTextViewVerticalMargin;

    maxHeight = maxHeight < 0? 50 : maxHeight;

    if(!self.replyTextView.scrollEnabled && (textHeight + self.replyTextView.font.lineHeight) >= maxHeight) {
        self.replyTextView.scrollEnabled = YES;
        self.replyTextViewHeight.offset(maxHeight);
    }else if(!self.replyTextView.scrollEnabled){
        self.replyTextViewHeight.offset(textHeight);
    }else if(self.replyTextView.scrollEnabled  && (textHeight + self.replyTextView.font.lineHeight) <= maxHeight){
        self.replyTextView.scrollEnabled = NO;
    }
}

-(CGFloat) heightForText: (NSString*)text {
    NSDictionary *attributes = @{
        NSFontAttributeName : [self.replyTextView.font copy]
    };
    NSAttributedString *attrString = [[NSAttributedString alloc] initWithString:text attributes:attributes];

    NSTextStorage *textStorage = [[NSTextStorage alloc] initWithAttributedString:attrString];

    CGFloat width = self.replyTextView.textContainer.size.width;
    NSTextContainer *textContainer = [[NSTextContainer alloc] initWithSize: CGSizeMake(width, FLT_MAX)];

    NSLayoutManager *layoutManager = [[NSLayoutManager alloc] init];
    [layoutManager addTextContainer:textContainer];
    [textStorage addLayoutManager:layoutManager];
    return [layoutManager usedRectForTextContainer:textContainer].size.height;
}
@end
