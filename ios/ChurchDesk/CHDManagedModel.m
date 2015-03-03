//
//  CHDManagedModel.m
//  ChurchDesk
//
//  Created by Mikkel Selsøe Sørensen on 23/02/15.
//  Copyright (c) 2015 Shape A/S. All rights reserved.
//

#import "CHDManagedModel.h"
#import "NSDateFormatter+ChurchDesk.h"

@implementation CHDManagedModel

- (id)transformedValueForPropertyWithName:(NSString *)propName value:(id)value {
    if ([propName isEqualToString:@"color"] && [value isKindOfClass:[NSString class]] && [value length] == 7 && [value hasPrefix:@"#"]) {
        NSString *colorString = [value stringByReplacingOccurrencesOfString:@"#" withString:@""];
        return [UIColor shpui_colorFromStringWithHexValue:colorString];
    }
    return [super transformedValueForPropertyWithName:propName value:value];
}

- (NSDateFormatter *)dateFormatterForPropertyWithName:(NSString *)propName {
    static NSDateFormatter *_sharedFormatter = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedFormatter = [NSDateFormatter chd_apiDateFormatter];
    });
    return _sharedFormatter;
}

@end
