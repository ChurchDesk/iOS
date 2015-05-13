//
//  Created by Peter Gammelgaard on 20/10/14.
//  Copyright (c) 2014 SHAPE A/S. All rights reserved.
//

#import "SHPCalendarPickerDayCell.h"
#import "SHPCalendarPickerLayouter.h"

@interface SHPCalendarPickerDayCell()
@property (nonatomic, strong) UILabel *dayLabel;
@property (nonatomic, strong) CAShapeLayer *circleShapeLayer;
@end

@implementation SHPCalendarPickerDayCell {

}

+ (void)initialize {
    [super initialize];

    [[SHPCalendarPickerDayCell appearance] setTextDefaultFont:[UIFont systemFontOfSize:14.0]];
    [[SHPCalendarPickerDayCell appearance] setTextDefaultColor:[UIColor blackColor]];
    [[SHPCalendarPickerDayCell appearance] setTextHighlightedColor:[UIColor blackColor]];
    [[SHPCalendarPickerDayCell appearance] setTextSelectedColor:[UIColor whiteColor]];
    [[SHPCalendarPickerDayCell appearance] setTextTodayColor:[UIColor redColor]];
    [[SHPCalendarPickerDayCell appearance] setTextDistantColor:[UIColor lightGrayColor]];

    [[SHPCalendarPickerDayCell appearance] setCircleDefaultColor:[UIColor clearColor]];
    [[SHPCalendarPickerDayCell appearance] setCircleSelectedColor:[UIColor redColor]];
    [[SHPCalendarPickerDayCell appearance] setCircleHighlightedColor:[UIColor clearColor]];
    [[SHPCalendarPickerDayCell appearance] setCircleTodayColor:[UIColor clearColor]];
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.today = NO;
        self.distant = NO;

        [self addSubLayers];
        [self adSubviews];

        self.textDefaultFont = [[SHPCalendarPickerDayCell appearance] textDefaultFont];
        self.textDefaultColor = [[SHPCalendarPickerDayCell appearance] textDefaultColor];
        self.textSelectedColor = [[SHPCalendarPickerDayCell appearance] textSelectedColor];
        self.textHighlightedColor = [[SHPCalendarPickerDayCell appearance] textHighlightedColor];
        self.textTodayColor = [[SHPCalendarPickerDayCell appearance] textTodayColor];
        self.textDistantColor = [[SHPCalendarPickerDayCell appearance] textDistantColor];

        self.circleDefaultColor = [[SHPCalendarPickerDayCell appearance] circleDefaultColor];;
        self.circleSelectedColor = [[SHPCalendarPickerDayCell appearance] circleSelectedColor];;
        self.circleHighlightedColor = [[SHPCalendarPickerDayCell appearance] circleHighlightedColor];;
        self.circleTodayColor = [[SHPCalendarPickerDayCell appearance] circleTodayColor];

        [self updateCircleShapeLayerColorAnimated:NO];
        [self updateTextColor];
        [self updateTextFont];
    }

    return self;
}

- (void)addSubLayers {
    [self.layer addSublayer:self.circleShapeLayer];
}

- (void)setSelected:(BOOL)selected {
    [self setSelected:selected animated:selected]; // Only animate when selecting the cell
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected];

    [self updateCircleShapeLayerColorAnimated:animated];
    [self updateTextColor];
}

- (void)setHighlighted:(BOOL)highlighted {
    [super setHighlighted:highlighted];

    [self updateCircleShapeLayerColorAnimated:NO];
    [self updateTextColor];
}

- (void)setToday:(BOOL)today {
    _today = today;

    [self updateCircleShapeLayerColorAnimated:NO];
    [self updateTextColor];
}

- (void)setDistant:(BOOL)distant {
    _distant = distant;
	
    [self updateCircleShapeLayerColorAnimated:NO];
    [self updateTextColor];
}

- (void)updateCircleShapeLayerColorAnimated:(BOOL)animated {
    UIColor *fillColor = nil;

    if (self.selected) {
        fillColor = [self circleSelectedColor];
    } else if (self.highlighted) {
        fillColor = [self circleHighlightedColor];
    } else if ([self isToday]) {
        fillColor = [self circleTodayColor];
    }  else {
        fillColor = [self circleDefaultColor];
    }

    if (!animated) {
        [CATransaction begin];
        [CATransaction setValue:(id)kCFBooleanTrue forKey:kCATransactionDisableActions];
    }

    self.circleShapeLayer.fillColor = fillColor.CGColor;

    if (!animated) {
        [CATransaction commit];
    }
}

- (void)updateTextFont {
    [self.dayLabel setFont:[self textDefaultFont]];
}

- (void)updateTextColor {
    UIColor *textColor = nil;

    if (self.selected) {
        textColor = [self textSelectedColor];
    } else if (self.highlighted) {
        textColor = [self textHighlightedColor];
    } else if ([self isToday]) {
        textColor = [self textTodayColor];
    } else if ([self isDistant]) {
        textColor = [self textDistantColor];
    } else {
        textColor = [self textDefaultColor];
    }

    self.dayLabel.textColor = textColor;
}

- (void)setFrame:(CGRect)frame {
    [super setFrame:frame];

    [self updateCircleShapeLayerPath];
}

- (void)setBounds:(CGRect)bounds {
    [super setBounds:self.bounds];

    [self updateCircleShapeLayerPath];
}

- (void)updateCircleShapeLayerPath {
    CGFloat fraction = 0.90;
    CGFloat radius = fraction*CGRectGetHeight(self.frame)/2.0f;
    CGFloat offsetX = CGRectGetWidth(self.frame)/2-radius;
    CGFloat offsetY = CGRectGetHeight(self.frame)/2-radius;
    CGRect roundedRect = CGRectMake(offsetX, offsetY, 2.0f * radius, 2.0f * radius);
    UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:roundedRect cornerRadius:radius];

    [self.circleShapeLayer setPath:path.CGPath];
}

- (void)adSubviews {
    [self addSubview:self.dayLabel];
}

- (void)layoutSubviews {
    [super layoutSubviews];

    self.dayLabel.frame = self.bounds;
}

- (void)prepareForReuse
{
    [super prepareForReuse];

    [self updateCircleShapeLayerColorAnimated:NO];
    [self updateTextColor];
    [self.dayLabel setFont:[self textDefaultFont]];
}

#pragma mark - Properties

- (UILabel *)dayLabel {
    if (!_dayLabel) {
        _dayLabel = [UILabel new];
        _dayLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _dayLabel;
}

- (CAShapeLayer *)circleShapeLayer {
    if (!_circleShapeLayer) {
        _circleShapeLayer = [CAShapeLayer new];


    }
    return _circleShapeLayer;
}

#pragma mark - Setters

- (void)setTextDefaultFont:(UIFont *)textDefaultFont {
    _textDefaultFont = textDefaultFont;
    [self updateTextFont];
}

- (void)setTextDefaultColor:(UIColor *)textDefaultColor {
    _textDefaultColor = textDefaultColor;
    [self updateTextColor];
}

- (void)setTextSelectedColor:(UIColor *)textSelectedColor {
    _textSelectedColor = textSelectedColor;
    [self updateTextColor];
}

- (void)setTextHighlightedColor:(UIColor *)textHighlightedColor {
    _textHighlightedColor = textHighlightedColor;
    [self updateTextColor];
}

- (void)setTextTodayColor:(UIColor *)textTodayColor {
    _textTodayColor = textTodayColor;
    [self updateTextColor];
}

- (void)setTextDistantColor:(UIColor *)textDistantColor {
    _textDistantColor = textDistantColor;
    [self updateTextColor];
}

- (void)setCircleSelectedColor:(UIColor *)circleSelectedColor {
    _circleSelectedColor = circleSelectedColor;
    [self updateCircleShapeLayerColorAnimated:NO];
}

- (void)setCircleHighlightedColor:(UIColor *)circleHighlightedColor {
    _circleHighlightedColor = circleHighlightedColor;
    [self updateCircleShapeLayerColorAnimated:NO];
}

- (void)setCircleDefaultColor:(UIColor *)circleDefaultColor {
    _circleDefaultColor = circleDefaultColor;
    [self updateCircleShapeLayerColorAnimated:NO];
}

- (void)setCircleTodayColor:(UIColor *)circleTodayColor {
    _circleTodayColor = circleTodayColor;
    [self updateCircleShapeLayerColorAnimated:NO];
}

@end