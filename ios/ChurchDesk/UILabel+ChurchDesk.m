//
//  UILabel+ChurchDesk.m
//  ChurchDesk
//
//  Created by Mikkel Selsøe Sørensen on 23/02/15.
//  Copyright (c) 2015 Shape A/S. All rights reserved.
//

#import "UILabel+ChurchDesk.h"

@implementation UILabel (ChurchDesk)

+ (instancetype) chd_regularLabelWithSize: (CGFloat) size {
    UILabel *label = [UILabel new];
    label.font = [UIFont chd_fontWithFontWeight:CHDFontWeightRegular size:size];
    label.textColor = [UIColor chd_textDarkColor];
    return label;
}

+ (instancetype) chd_boldLabelWithSize: (CGFloat) size {
    UILabel *label = [UILabel new];
    label.font = [UIFont chd_fontWithFontWeight:CHDFontWeightBold size:size];
    label.textColor = [UIColor chd_textDarkColor];
    return label;
}

+ (instancetype) chd_mediumLabelWithSize: (CGFloat) size {
    UILabel *label = [UILabel new];
    label.font = [UIFont chd_fontWithFontWeight:CHDFontWeightMedium size:size];
    label.textColor = [UIColor chd_textDarkColor];
    return label;
}


@end
