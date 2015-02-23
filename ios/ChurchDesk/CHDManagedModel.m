//
//  CHDManagedModel.m
//  ChurchDesk
//
//  Created by Mikkel Selsøe Sørensen on 23/02/15.
//  Copyright (c) 2015 Shape A/S. All rights reserved.
//

#import "CHDManagedModel.h"

@implementation CHDManagedModel

- (NSDateFormatter *)dateFormatterForPropertyWithName:(NSString *)propName {
    static NSDateFormatter *_sharedFormatter = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedFormatter = [NSDateFormatter new];
        [_sharedFormatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"]];
        _sharedFormatter.dateFormat = @"yyyy-MM-dd'T'HH:mm:ss'Z'";
        [_sharedFormatter setTimeZone:[NSTimeZone timeZoneWithName:@"GMT"]];
    });
    return _sharedFormatter;
}

@end
