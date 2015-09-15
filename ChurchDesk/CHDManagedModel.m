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
    NSString *colorString;
    if ([propName isEqualToString:@"color"]) {
        if (value != [NSNull null]) {
        switch ([value integerValue]) {
            case 0:
                colorString = @"22A7F0";
                break;
            case 1:
                colorString = @"1F3A93";
                break;
            case 2:
                colorString = @"2ECC71";
                break;
            case 3:
                colorString = @"1E824C";
                break;
            case 4:
                colorString = @"F22613";
                break;
            case 5:
                colorString = @"FFB61E";
                break;
            case 6:
                colorString = @"F9690E";
                break;
            case 7:
                colorString = @"9B59B6";
                break;
            case 8:
                colorString = @"BDC3C7";
                break;
            case 9:
                colorString = @"22313F";
                break;
            default:
                break;
        }
            
        }
        else{
            colorString = @"22A7F0";
        }
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
