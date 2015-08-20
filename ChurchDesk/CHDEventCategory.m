//
//  CHDEventCategory.m
//  ChurchDesk
//
//  Created by Mikkel Selsøe Sørensen on 26/02/15.
//  Copyright (c) 2015 Shape A/S. All rights reserved.
//

#import "CHDEventCategory.h"

@implementation CHDEventCategory

- (NSString *)mapPropertyForPropertyWithName:(NSString *)propName {
    if ([propName isEqualToString:@"categoryId"]) {
        return @"id";
    }
    if([propName isEqualToString:@"siteId"]) {
        return @"organizationId";
    }
    return [super mapPropertyForPropertyWithName:propName];
}

@end
