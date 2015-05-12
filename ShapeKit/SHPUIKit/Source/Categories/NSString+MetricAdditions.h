//
// Created by Kasper Kronborg on 16/01/14.
// Copyright (c) 2014 SHAPE A/S. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NSString (MetricAdditions)
- (CGSize)shpui_sizeWithAttributes:(NSDictionary *)attributes constrainedToSize:(CGSize)constrainedSize;
- (CGSize)shpui_sizeWithAttributes:(NSDictionary *)attributes constrainedToSize:(CGSize)constrainedSize options:(NSStringDrawingOptions)options;
@end
