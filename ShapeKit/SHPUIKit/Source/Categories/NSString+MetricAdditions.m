//
// Created by Kasper Kronborg on 16/01/14.
// Copyright (c) 2014 SHAPE A/S. All rights reserved.
//

#import "NSString+MetricAdditions.h"
#import "UIDevice+SystemAdditions.h"


@implementation NSString (MetricAdditions)

- (CGSize)shpui_sizeWithAttributes:(NSDictionary *)attributes constrainedToSize:(CGSize)constrainedSize
{
    return [self shpui_sizeWithAttributes:attributes constrainedToSize:constrainedSize options:NSStringDrawingUsesLineFragmentOrigin];
}

- (CGSize)shpui_sizeWithAttributes:(NSDictionary *)attributes constrainedToSize:(CGSize)constrainedSize options:(NSStringDrawingOptions)options
{
    CGSize size = CGSizeZero;

    if ([[UIDevice currentDevice] shpui_hasSystemVersionGreaterThanOrEqualTo:@"7.0"]) {
        // This method returns fractional sizes (in the size component of the returned CGRect); to use a returned size to size views,
        // you must use raise its value to the nearest higher integer using the ceil function.
        CGRect rect = [self boundingRectWithSize:constrainedSize options:options attributes:attributes context:nil];

        size = (CGSize){ceilf(rect.size.width), ceilf(rect.size.height)};
    }
    else {
        UIFont *font = [attributes objectForKey:NSFontAttributeName];

        size = [self sizeWithFont:font constrainedToSize:constrainedSize];
    }

    return size;
}


@end
