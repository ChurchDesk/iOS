//
//  UIView+SHPAdditions.m
//  ShapeKit
//
//  Created by Ole Poulsen on 24/07/11.
//  Copyright 2011 Shape ApS. All rights reserved.
//

#import "UIView+SHPAdditions.h"

@implementation UIView (SHPAdditions)

#pragma mark - Relative positioning methods

- (void)shpui_centerVerticallyAvoidHalfPoints:(BOOL)avoidHalfPoints {
    if (!self.superview) return;
    CGFloat centerY = self.superview.bounds.size.height / 2.0f;
    self.center = CGPointMake(self.center.x, centerY);
    if (avoidHalfPoints) {
        CGRect newFrame = self.frame;
        newFrame.origin.y = (int) self.frame.origin.y; // round down
        self.frame = newFrame;
    }
}

- (void)shpui_centerHorizontallyAvoidHalfPoints:(BOOL)avoidHalfPoints {
	if (!self.superview) return;
	CGFloat centerX = self.superview.bounds.size.width/2.0f;
	self.center = CGPointMake(centerX, self.center.y);
	if (avoidHalfPoints) {
        CGRect newFrame = self.frame;
        newFrame.origin.x = (int) self.frame.origin.x; // round down
        self.frame = newFrame;
    }
}

#pragma mark - Frame-accessing properties

- (void)shpui_adjustSizeToRightOriginX:(CGFloat)rightOriginX {
    CGFloat currentRightOriginX = self.superview.frame.size.width - (self.frame.origin.x + self.frame.size.width);
    CGFloat widthAdjustment = currentRightOriginX - rightOriginX;

    CGRect newFrame = self.frame;
    newFrame.size.width = self.frame.size.width + widthAdjustment;
    self.frame = newFrame;
}

@end
