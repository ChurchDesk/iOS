//
//  CHDInvitation.m
//  ChurchDesk
//
//  Created by Mikkel Selsøe Sørensen on 24/02/15.
//  Copyright (c) 2015 Shape A/S. All rights reserved.
//

#import "CHDInvitation.h"

@implementation CHDInvitation

- (NSString *)mapPropertyForPropertyWithName:(NSString *)propName {
    if ([propName isEqualToString:@"invitationId"]) {
        return @"id";
    }
    if ([propName isEqualToString:@"changeDate"]) {
        return @"changed";
    }
    return [super mapPropertyForPropertyWithName: propName];
}

@end
