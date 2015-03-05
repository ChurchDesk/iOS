//
//  CHDResource.m
//  ChurchDesk
//
//  Created by Mikkel Selsøe Sørensen on 26/02/15.
//  Copyright (c) 2015 Shape A/S. All rights reserved.
//

#import "CHDResource.h"

@implementation CHDResource

- (NSString *)mapPropertyForPropertyWithName:(NSString *)propName {
    if ([propName isEqualToString:@"resourceId"]) {
        return @"id";
    }
    if([propName isEqualToString:@"siteId"]) {
        return @"site";
    }
    return [super mapPropertyForPropertyWithName:propName];
}

@end
