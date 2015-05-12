//
// Created by Kasper Kronborg on 16/01/14.
// Copyright (c) 2014 SHAPE A/S. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIDevice (SystemAdditions)
- (BOOL)shpui_hasSystemVersionEqualTo:(NSString *)version;
- (BOOL)shpui_hasSystemVersionGreaterThan:(NSString *)version;
- (BOOL)shpui_hasSystemVersionGreaterThanOrEqualTo:(NSString *)version;
- (BOOL)shpui_hasSystemVersionLessThan:(NSString *)version;
- (BOOL)shpui_hasSystemVersionLessThanOrEqualTo:(NSString *)version;
@end
