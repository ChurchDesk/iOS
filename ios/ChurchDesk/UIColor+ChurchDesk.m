//
//  UIColor+ChurchDesk.m
//  ChurchDesk
//
//  Created by Jakob Vinther-Larsen on 17/02/15.
//  Copyright (c) 2015 Shape A/S. All rights reserved.
//

#import "UIColor+ChurchDesk.h"

@implementation UIColor (ChurchDesk)

#pragma mark - General colors
+ (UIColor*) chd_blueColor {
  return [UIColor shpui_colorFromStringWithHexValue:@"008db6"];
}

+ (UIColor*) chd_greenColor{
  return [UIColor shpui_colorFromStringWithHexValue:@"7ab800"];
}

+ (UIColor*) chd_redColor{
  return [UIColor shpui_colorFromStringWithHexValue:@"e74c3c"];
}

+ (UIColor*) chd_orangeColor{
  return [UIColor shpui_colorFromStringWithHexValue:@"f39c12"];
}
+ (UIColor*) chd_lightGreyColor{
    return [UIColor shpui_colorFromStringWithHexValue:@"e9e9e9"];
}
#pragma mark - Font colors
+ (UIColor*) chd_textDarkColor{
    return [UIColor shpui_colorFromStringWithHexValue:@"000000"];
}
+ (UIColor*) chd_textLigthColor{
    return [UIColor shpui_colorFromStringWithHexValue:@"646464"];
}

+ (UIColor *) chd_textExtraLightColor {
    return [UIColor shpui_colorFromStringWithHexValue:@"c0c0c0"];
}


#pragma mark - Category colors
+ (UIColor*) chd_categoryBlueColor{
  return [UIColor shpui_colorFromStringWithHexValue:@"22a7f0"];
}
+ (UIColor*) chd_categoryDarkBlueColor{
  return [UIColor shpui_colorFromStringWithHexValue:@"1f3a93"];
}
+ (UIColor*) chd_categoryGreenColor{
  return [UIColor shpui_colorFromStringWithHexValue:@"2ecc71"];
}
+ (UIColor*) chd_categoryDarkGreenColor{
  return [UIColor shpui_colorFromStringWithHexValue:@"1e824c"];
}
+ (UIColor*) chd_categoryRedColor{
  return [UIColor shpui_colorFromStringWithHexValue:@"f22613"];
}
+ (UIColor*) chd_categoryOrangeColor{
  return [UIColor shpui_colorFromStringWithHexValue:@"ffb61e"];
}
+ (UIColor*) chd_categoryDarkOrangeColor{
  return [UIColor shpui_colorFromStringWithHexValue:@"f9690e"];
}
+ (UIColor*) chd_categoryPurpleColor{
  return [UIColor shpui_colorFromStringWithHexValue:@"9b59b6"];
}
+ (UIColor*) chd_categoryGreyColor{
  return [UIColor shpui_colorFromStringWithHexValue:@"bdc3c7"];
}
+ (UIColor*) chd_categoryDarkColor{
  return [UIColor shpui_colorFromStringWithHexValue:@"22313f"];
}
@end
