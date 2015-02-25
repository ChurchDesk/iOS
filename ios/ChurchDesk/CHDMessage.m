//
//  CHDMessage.m
//  ChurchDesk
//
//  Created by Jakob Vinther-Larsen on 24/02/15.
//  Copyright (c) 2015 Shape A/S. All rights reserved.
//

#import "CHDMessage.h"

@implementation CHDMessage
- (NSString *)mapPropertyForPropertyWithName:(NSString *)propName {
    if ([propName isEqualToString:@"messageId"]) {
        return @"id";
    }
    if ([propName isEqualToString:@"messageLine"]) {
        return @"message_line";
    }
    if ([propName isEqualToString:@"changeDate"]) {
        return @"changed";
    }
    if ([propName isEqualToString:@"lastActivityDate"]) {
        return @"last_activity";
    }

    return [super mapPropertyForPropertyWithName:propName];
}
@end
