//
//  CHDPeerUser.m
//  ChurchDesk
//
//  Created by Mikkel Selsøe Sørensen on 26/02/15.
//  Copyright (c) 2015 Shape A/S. All rights reserved.
//

#import "CHDPeerUser.h"
#import "CHDSite.h"

@implementation CHDPeerUser

- (NSString *)mapPropertyForPropertyWithName:(NSString *)propName {
    if ([propName isEqualToString:@"userId"]) {
        return @"id";
    }
    if ([propName isEqualToString:@"pictureURL"]) {
        return @"picture";
    }
    if([propName isEqualToString:@"siteId"]){
        return @"organizations";
    }
    if([propName isEqualToString:@"groupIds"]){
        return @"groups";
    }
    return [super mapPropertyForPropertyWithName:propName];
}

- (id)transformedValueForPropertyWithName:(NSString *)propName value:(id)value {
    if ([propName isEqualToString:@"pictureURL"] && value != [NSNull null]) {
        return [NSURL URLWithString:value];
    }
    if ([propName isEqualToString:@"siteId"] && value != [NSNull null]) {
        return [[value objectAtIndex:0] valueForKey:@"organizationId"];
    }
    return [super transformedValueForPropertyWithName:propName value:value];
}

@end
