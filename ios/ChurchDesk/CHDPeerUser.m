//
//  CHDPeerUser.m
//  ChurchDesk
//
//  Created by Mikkel Selsøe Sørensen on 26/02/15.
//  Copyright (c) 2015 Shape A/S. All rights reserved.
//

#import "CHDPeerUser.h"

@implementation CHDPeerUser

- (NSString *)mapPropertyForPropertyWithName:(NSString *)propName {
    if ([propName isEqualToString:@"userId"]) {
        return @"id";
    }
    if ([propName isEqualToString:@"pictureURL"]) {
        return @"picture";
    }
    if([propName isEqualToString:@"siteId"]) {
        return @"site";
    }
    if([propName isEqualToString:@"groupIds"]){
        return @"groups";
    }
    return [super mapPropertyForPropertyWithName:propName];
}

- (id)transformedValueForPropertyWithName:(NSString *)propName value:(id)value {
    if ([propName isEqualToString:@"pictureURL"]) {
        return [NSURL URLWithString:value];
    }
    else if ([propName isEqualToString:@"groupIds"]) {
        return (NSArray *) [value shp_map:^id(NSString *numberAsString) {
            return @([numberAsString integerValue]);
        }];
    }
    return [super transformedValueForPropertyWithName:propName value:value];
}

@end
