//
//  CHDGroup.m
//  ChurchDesk
//
//  Created by Mikkel Selsøe Sørensen on 26/02/15.
//  Copyright (c) 2015 Shape A/S. All rights reserved.
//

#import "CHDGroup.h"

@implementation CHDGroup

- (NSString *)mapPropertyForPropertyWithName:(NSString *)propName {
    if ([propName isEqualToString:@"groupId"]) {
        return @"id";
    }
    return [super mapPropertyForPropertyWithName:propName];
}

@end
