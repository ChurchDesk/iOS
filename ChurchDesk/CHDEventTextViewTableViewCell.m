 //
//  CHDEventTextViewTableViewCell.m
//  ChurchDesk
//
//  Created by Mikkel Selsøe Sørensen on 09/03/15.
//  Copyright (c) 2015 Shape A/S. All rights reserved.
//

#import "CHDEventTextViewTableViewCell.h"

static CGFloat kMinimumHeight = 87;

@interface CHDEventTextViewTableViewCell () <UITextViewDelegate>

@property (nonatomic, strong) UITextView *textView;
@property (nonatomic, strong) UILabel *placeholderLabel;
@property (nonatomic, strong) UILabel *warningLabel;
@property (nonatomic, strong) UIImageView *iconImageView;
@property (nonatomic, strong) MASConstraint *heightConstraint;

@end

@implementation CHDEventTextViewTableViewCell
float height;
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if ((self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.backgroundColor = [UIColor whiteColor];
        height = 0.0;
        [self setupSubviews];
        [self makeConstraints];
        [self setupBindings];
    }
    return self;
}

- (void) setupSubviews {
    [self.contentView addSubview:self.textView];
    [self.contentView addSubview:self.placeholderLabel];
    [self.contentView addSubview:self.iconImageView];
}

- (void) makeConstraints {
    __block MASConstraint *iconLeftConstraint = nil;
    [self.iconImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.placeholderLabel);
        iconLeftConstraint = make.left.equalTo(self.contentView);
    }];
    
    [self.textView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.iconImageView.mas_right).offset(-10);
        make.top.equalTo(self.contentView);
        make.bottom.equalTo(self.contentView);
        make.right.equalTo(self.contentView);
        self.heightConstraint = make.height.equalTo(@0).offset(kMinimumHeight);
    }];
    
    [self.placeholderLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.iconImageView.mas_right).offset(6);
        make.right.lessThanOrEqualTo(self.contentView).offset(-6);
        make.top.equalTo(self.contentView).offset(kSideMargin);
    }];
    
    [self.contentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self);
    }];
    
    RAC(iconLeftConstraint, offset) = [RACObserve(self.iconImageView, image) map:^id(UIImage *image) {
        return @(image == nil ? kSideMargin-6 : kSideMargin);
    }];
}

- (void) setupBindings {
    RACSignal *textSignal = [RACSignal merge:@[self.textView.rac_textSignal, RACObserve(self.textView, text)]];
    
    RAC(self.placeholderLabel, text) = RACObserve(self, placeholder);
    
    RAC(self.placeholderLabel, hidden) = [textSignal map:^id (NSString *text) {
        return @(text.length > 0);
    }];
    [self rac_liftSelector:@selector(textDidChange:) withSignals:self.textView.rac_textSignal, nil];
}

#pragma mark - Actions

- (void)textDidChange:(NSString *)text {
    
    CGSize contentSize = [self.textView sizeThatFits:CGSizeMake(self.textView.frame.size.width, CGFLOAT_MAX)];
    contentSize.height = MAX(kMinimumHeight, contentSize.height);
    
    if (contentSize.height > height) {
        [self.tableView beginUpdates];
        height = contentSize.height;
        [self.heightConstraint setOffset:contentSize.height + (kSideMargin*2)];
        [self.tableView endUpdates];
    }
}

#pragma mark - Lazy Initialization

- (UITextView *)textView {
    if (!_textView) {
        _textView = [UITextView new];
        _textView.scrollEnabled = YES;
        _textView.textContainerInset = UIEdgeInsetsMake(kSideMargin, kSideMargin-2, 0, kSideMargin);
        _textView.delegate = self;
        _textView.font = [UIFont chd_fontWithFontWeight:CHDFontWeightRegular size:17];
        _textView.clipsToBounds = YES;
        _textView.textContainer.widthTracksTextView = YES;
        _textView.userInteractionEnabled = YES;
    }
    return _textView;
}


- (UILabel *)placeholderLabel {
    if (!_placeholderLabel) {
        _placeholderLabel = [UILabel chd_regularLabelWithSize:17];
        _placeholderLabel.textColor = [UIColor chd_textDarkColor];
        _placeholderLabel.backgroundColor = [UIColor clearColor];
    }
    return _placeholderLabel;
}

- (UIImageView *)iconImageView {
    if (!_iconImageView) {
        _iconImageView = [UIImageView new];
    }
    return _iconImageView;
}
@end
