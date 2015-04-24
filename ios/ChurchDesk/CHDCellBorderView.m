//
// Created by Jakob Vinther-Larsen on 24/04/15.
// Copyright (c) 2015 Shape A/S. All rights reserved.
//

#import "CHDCellBorderView.h"
@interface CHDCellBorderView()
@property (nonatomic, assign) CGFloat marginLeft;
@end

@implementation CHDCellBorderView

- (void)setLeftMargin:(CGFloat)leftMargin {
    self.marginLeft = leftMargin;
}


- (void)drawRect:(CGRect)rect {
    CGContextRef context = UIGraphicsGetCurrentContext();
    float borderSize = 1.0f;
    CGContextSetFillColorWithColor(context, [UIColor chd_cellDividerColor].CGColor);
    CGContextFillRect(context, CGRectMake(self.marginLeft, self.frame.size.height - borderSize, self.frame.size.width - self.marginLeft, borderSize));
}
@end