//
//  CHDEvent.m
//  ChurchDesk
//
//  Created by Mikkel Selsøe Sørensen on 26/02/15.
//  Copyright (c) 2015 Shape A/S. All rights reserved.
//

#import "CHDEvent.h"

@implementation CHDEvent

- (NSString *)mapPropertyForPropertyWithName:(NSString *)propName {
    if ([propName isEqualToString:@"eventId"]) {
        return @"id";
    }
    if ([propName isEqualToString:@"creationDate"]) {
        return @"created";
    }
    if ([propName isEqualToString:@"allDayEvent"]) {
        return @"allDay";
    }
    if ([propName isEqualToString:@"publicEvent"]) {
        return @"publish";
    }
    if ([propName isEqualToString:@"eventDescription"]) {
        return @"description";
    }
    if ([propName isEqualToString:@"contributor"]) {
        return @"person";
    }
    if ([propName isEqualToString:@"eventResponse"]) {
        return @"attendenceStatus";
    }
    if ([propName isEqualToString:@"resourceIds"]) {
        return @"resources";
    }
    if ([propName isEqualToString:@"userIds"]) {
        return @"users";
    }
    return [super mapPropertyForPropertyWithName:propName];
}

@end
