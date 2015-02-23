//
//  UILabel+ChurchDesk.h
//  ChurchDesk
//
//  Created by Mikkel Selsøe Sørensen on 23/02/15.
//  Copyright (c) 2015 Shape A/S. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UILabel (ChurchDesk)

+ (instancetype) chd_regularLabelWithSize: (CGFloat) size;
+ (instancetype) chd_boldLabelWithSize: (CGFloat) size;

@end
