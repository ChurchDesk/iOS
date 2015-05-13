//
//  UIFont+ChurchDesk.m
//  ChurchDesk
//
//  Created by Mikkel Selsøe Sørensen on 19/02/15.
//  Copyright (c) 2015 Shape A/S. All rights reserved.
//

#import "UIFont+ChurchDesk.h"

@implementation UIFont (ChurchDesk)

+ (UIFont*) chd_fontWithFontWeight: (CHDFontWeight) fontWeight size: (CGFloat) size {
    switch (fontWeight) {
        case CHDFontWeightRegular:
            return [UIFont fontWithName:@"MavenProRegular" size:size];
        case CHDFontWeightMedium:
            return [UIFont fontWithName:@"MavenProMedium" size:size];
        case CHDFontWeightBold:
            return [UIFont fontWithName:@"MavenProBold" size:size];
        case CHDFontWeightBlack:
            return [UIFont fontWithName:@"MavenProBlack" size:size];
    }
    return nil;
}

@end
