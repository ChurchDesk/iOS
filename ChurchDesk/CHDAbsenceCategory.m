//
//  CHDAbsenceCategory.m
//  ChurchDesk
//
//  Created by Chirag Sharma on 21/12/15.
//  Copyright © 2015 Shape A/S. All rights reserved.
//

#import "CHDAbsenceCategory.h"

@implementation CHDAbsenceCategory

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
