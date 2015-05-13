//
//  UIButton+ChurchDesk.m
//  ChurchDesk
//
//  Created by Mikkel Selsøe Sørensen on 02/03/15.
//  Copyright (c) 2015 Shape A/S. All rights reserved.
//

#import "UIButton+ChurchDesk.h"

@implementation UIButton (ChurchDesk)

+ (UIButton*) chd_roundedBlueButton {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.layer.cornerRadius = 2.0f;
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    button.titleLabel.font = [UIFont chd_fontWithFontWeight:CHDFontWeightRegular size:18];
    
    [button chd_setupRoundedBlueBindings];
    
    return button;
}

- (void) chd_setupRoundedBlueBindings {
    RAC(self, backgroundColor) = [RACObserve(self, highlighted) map:^id(NSNumber *nHighlighted) {
        return nHighlighted.boolValue ? [UIColor chd_blueColor] : [UIColor shpui_colorWithHexValue:0x0f5469];
    }];
}

@end
