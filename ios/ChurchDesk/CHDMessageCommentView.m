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
    }
    return self;
}

#pragma mark - Lazy initialization

-(void) makeViews {
    [self addSubview:self.replyButton];
    [self addSubview:self.replyTextView];
}

-(void) makeConstraints{
    [self.replyButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self).offset(-10);
        make.right.equalTo(self).offset(-15);
        make.top.greaterThanOrEqualTo(self).offset(10);
    }];

    [self.replyTextView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.replyButton.mas_left).offset(-15);
        make.left.equalTo(self).offset(8);
        make.bottom.equalTo(self).offset(-8);
        make.top.equalTo(self).offset(8);
        self.replyTextViewHeight = make.height.greaterThanOrEqualTo(@10);
    }];
}

-(UIButton*) replyButton{
    if(!_replyButton){
        _replyButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _replyButton.titleLabel.font = [UIFont chd_fontWithFontWeight:CHDFontWeightRegular size:15];
        [_replyButton setTitle:NSLocalizedString(@"Reply", @"") forState:UIControlStateNormal];
        [_replyButton setTitleColor:[UIColor shpui_colorWithHexValue:0xa8a8a8] forState:UIControlStateNormal];
    }
    return _replyButton;
}

-(UITextView*) replyTextView{
    if(!_replyTextView){
        _replyTextView = [UITextView new];
        _replyTextView.font = [UIFont chd_fontWithFontWeight:CHDFontWeightRegular size:15];
        _replyTextView.textColor = [UIColor shpui_colorWithHexValue:0xa8a8a8];
        _replyTextView.layer.borderColor = [UIColor shpui_colorWithHexValue:0xc8c7cc].CGColor;
        _replyTextView.layer.borderWidth = 1.0;
        _replyTextView.layer.cornerRadius = 3.0;
        _replyTextView.delegate = self;
        _replyTextView.scrollEnabled = YES;
        _replyTextView.inputAccessoryView = [CHDInputAccessoryObserveView new];
    }
    return _replyTextView;
}

- (CGSize)intrinsicContentSize {
    return CGSizeMake(0, 50);
}

#pragma mark - TextView delegate

- (void)textViewDidChange:(UITextView *)textView {
    CGSize size = textView.contentSize;
    if(size.height > 150){
        self.replyTextViewHeight.offset(150);
    }else {
        self.replyTextViewHeight.offset(size.height);
    }
}



@end
