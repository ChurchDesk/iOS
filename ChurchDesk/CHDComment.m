//
// Created by Jakob Vinther-Larsen on 04/03/15.
// Copyright (c) 2015 Shape A/S. All rights reserved.
//

#import "CHDComment.h"


@implementation CHDComment
- (NSString *)mapPropertyForPropertyWithName:(NSString *)propName {
    if([propName isEqualToString:@"body"]){
        return @"Body";
    }
    if([propName isEqualToString:@"commentId"]){
        return @"id";
    }
    if([propName isEqualToString:@"createdDate"]){
        return @"created";
    }
    return [super mapPropertyForPropertyWithName:propName];
}

@end