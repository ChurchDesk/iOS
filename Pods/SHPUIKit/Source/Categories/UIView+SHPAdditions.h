//
//  UIView+SHPAdditions.h
//  ShapeKit
//
//  Created by Ole Poulsen on 24/07/11.
//  Copyright 2011 Shape ApS. All rights reserved.
//

#import <UIKit/UIKit.h>

///  Additions to UIView that makes it easier to manipulate the views frame. Like changing origin, size, etc.

@interface UIView (SHPAdditions)

/// ---------------------------------------------------------------------
/// @name Centering views
/// ---------------------------------------------------------------------

/// Centers a view vertically in it's superview.
/// @param avoidHalfPoints If YES the calculated center y point will be rounded to avoid half points that would make it look blurry on non-retina devices.
- (void)shpui_centerVerticallyAvoidHalfPoints:(BOOL)avoidHalfPoints;
/// Centers a view horizontally in it's superview.
/// @param avoidHalfPoints If YES the calculated center x point will be rounded to avoid half points that would make it look blurry on non-retina devices.
- (void)shpui_centerHorizontallyAvoidHalfPoints:(BOOL)avoidHalfPoints;

/// Adjusts the size so that the distance from the rightmost point to the rightmost point of the superview fits with the rightOriginX argument
- (void)shpui_adjustSizeToRightOriginX:(CGFloat)rightOriginX;

@end
