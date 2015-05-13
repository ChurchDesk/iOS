//
// Created by Kasper Kronborg on 16/01/14.
// Copyright (c) 2014 SHAPE A/S. All rights reserved.
//

#import "UIDevice+SystemAdditions.h"


@implementation UIDevice (SystemAdditions)

- (BOOL)shpui_hasSystemVersionEqualTo:(NSString *)version
{
    return ([[[UIDevice currentDevice] systemVersion] compare:version options:NSNumericSearch] == NSOrderedSame);
}

- (BOOL)shpui_hasSystemVersionGreaterThan:(NSString *)version
{
    return ([[[UIDevice currentDevice] systemVersion] compare:version options:NSNumericSearch] == NSOrderedDescending);
}

- (BOOL)shpui_hasSystemVersionGreaterThanOrEqualTo:(NSString *)version
{
    return ([[[UIDevice currentDevice] systemVersion] compare:version options:NSNumericSearch] != NSOrderedAscending);
}

- (BOOL)shpui_hasSystemVersionLessThan:(NSString *)version
{
    return ([[[UIDevice currentDevice] systemVersion] compare:version options:NSNumericSearch] == NSOrderedAscending);
}

- (BOOL)shpui_hasSystemVersionLessThanOrEqualTo:(NSString *)version
{
    return ([[[UIDevice currentDevice] systemVersion] compare:version options:NSNumericSearch] != NSOrderedDescending);
}

@end
