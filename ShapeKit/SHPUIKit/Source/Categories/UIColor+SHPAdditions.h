//  Created by Philip Bruce on 22/07/11.
//  Copyright 2011 Shape ApS. All rights reserved.

/**
 Utility methods for UIColor
*/

#import <UIKit/UIKit.h>

@interface UIColor(SHPAdditions)

/**
 Create a UIColor from a hex value as often used in image editors like photoshop. The alpha value is set to 1.0f
*/
+ (UIColor *)shpui_colorWithHexValue:(uint32_t )hexValue;

/**
 Create a UIColor from a hex value as often used in image editors like photoshop and specify an alpha value between 0.0f and 1.0f
*/
+ (UIColor *)shpui_colorWithHexValue:(uint32_t)hexValue alpha:(float)alpha;

/**
 Create a UIColor from a hex value in a NSString object eg. @"FF00F0"
*/
+ (UIColor *)shpui_colorFromStringWithHexValue:(NSString *)hexString;

/**
 Create a UIColor from a hex value in a NSString object eg. @"FF00F0" and specify an alpha value between 0.0f and 1.0f
*/
+ (UIColor *)shpui_colorFromStringWithHexValue:(NSString *)hexString alpha:(float)alpha;

@end
