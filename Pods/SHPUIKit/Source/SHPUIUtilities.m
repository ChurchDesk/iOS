//
// Created by philip on 06/09/12.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import "SHPUIUtilities.h"

CGFloat RoundToPixel(CGFloat f) {
    CGFloat scale = [[UIScreen mainScreen] scale];
    return roundf(scale * f) / scale;
}

CGFloat FloorToPixel(CGFloat f) {
    CGFloat scale = [[UIScreen mainScreen] scale];
    return floorf(scale * f) / scale;
}

CGFloat CeilToPixel(CGFloat f) {
    CGFloat scale = [[UIScreen mainScreen] scale];
    return ceilf(scale * f) / scale;
}

BOOL OSVersionGreaterThanOrEqualTo(NSString* systemVersion) {
    return ([[[UIDevice currentDevice] systemVersion] compare:systemVersion options:NSNumericSearch] != NSOrderedAscending);
}

BOOL OSVersionLessThanOrEqualTo(NSString* systemVersion) {
    return ([[[UIDevice currentDevice] systemVersion] compare:systemVersion options:NSNumericSearch] != NSOrderedDescending);
}