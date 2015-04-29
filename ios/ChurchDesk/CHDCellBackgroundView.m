//
//  CHDCellBackgroundView.m
//  ChurchDesk
//
//  Created by Jonas Lysgaard-Hansen on 10/04/15.
//  Copyright (c) 2015 Shape A/S. All rights reserved.
//

#import "CHDCellBackgroundView.h"

@implementation CHDCellBackgroundView

- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetBlendMode(context, kCGBlendModeMultiply);
    [self.borderColor setFill];
    CGContextFillRect(context, CGRectMake(0.0f, 0.0f, 3.5f, self.frame.size.height));
    float borderSize = 1.0f;
    CGContextSetFillColorWithColor(context, [UIColor chd_categoryGreyColor].CGColor);
    CGContextFillRect(context, CGRectMake(0.0f, self.frame.size.height - borderSize *2, self.frame.size.width, borderSize));
}

- (void)setBorderColor:(UIColor *)borderColor
{
    _borderColor = borderColor;
    [self setNeedsDisplay];
}

@end
