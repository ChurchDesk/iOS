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
    if([propName isEqualToString:@"siteIds"]){
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
    if ([propName isEqualToString:@"siteIds"] && value != [NSNull null]) {
        NSMutableArray *tempSiteIdsArray = [[NSMutableArray alloc] init];
        for (int numberOfSites = 0; numberOfSites < [value count]; numberOfSites++) {
            [tempSiteIdsArray addObject:[[value objectAtIndex:numberOfSites] valueForKey:@"organizationId"]];
        }
        return tempSiteIdsArray;
    }
    return [super transformedValueForPropertyWithName:propName value:value];
}

@end
