//
//  CHDEventCategory.m
//  ChurchDesk
//
//  Created by Mikkel Selsøe Sørensen on 26/02/15.
//  Copyright (c) 2015 Shape A/S. All rights reserved.
//

#import "CHDEventCategory.h"
@interface CHDEventCategory ()
@property (nonatomic, strong) UIColor *color;
@end

@implementation CHDEventCategory

- (NSString *)mapPropertyForPropertyWithName:(NSString *)propName {
    if ([propName isEqualToString:@"categoryId"]) {
        return @"id";
    }
    if([propName isEqualToString:@"siteId"]) {
        return @"site";
    }
    if([propName isEqualToString:@"colorString"]){
        return @"color";
    }
    return [super mapPropertyForPropertyWithName:propName];
}

-(UIColor*) color {
    NSString *hexString = [self.colorString stringByReplacingOccurrencesOfString:@"#" withString:@""];
    return [UIColor shpui_colorFromStringWithHexValue:hexString];
}

@end
