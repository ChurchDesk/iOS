//
//  CHDMessage.m
//  ChurchDesk
//
//  Created by Jakob Vinther-Larsen on 24/02/15.
//  Copyright (c) 2015 Shape A/S. All rights reserved.
//

#import "CHDMessage.h"
#import "CHDComment.h"

@implementation CHDMessage
- (NSString *)mapPropertyForPropertyWithName:(NSString *)propName {
    if ([propName isEqualToString:@"messageId"]) {
        return @"id";
    }
    if ([propName isEqualToString:@"messageLine"]) {
        return @"messageLine";
    }
    if ([propName isEqualToString:@"changeDate"]) {
        return @"changed";
    }
    if ([propName isEqualToString:@"lastActivityDate"]) {
        return @"lastActivity";
    }

    return [super mapPropertyForPropertyWithName:propName];
}
- (Class)nestedClassForArrayPropertyWithName:(NSString *)propName {
    if ([propName isEqualToString:@"comments"]) {
        return [CHDComment class];
    }
    return [super nestedClassForArrayPropertyWithName:propName];
}
@end
