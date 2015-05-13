//
//  UIFont+ChurchDesk.h
//  ChurchDesk
//
//  Created by Mikkel Selsøe Sørensen on 19/02/15.
//  Copyright (c) 2015 Shape A/S. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, CHDFontWeight) {
    CHDFontWeightRegular,
    CHDFontWeightMedium,
    CHDFontWeightBold,
    CHDFontWeightBlack,
};

@interface UIFont (ChurchDesk)

+ (UIFont*) chd_fontWithFontWeight: (CHDFontWeight) fontWeight size: (CGFloat) size;

@end
