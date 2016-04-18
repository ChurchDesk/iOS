//
//  CHDSegment.m
//  ChurchDesk
//
//  Created by Chirag Sharma on 18/04/16.
//  Copyright © 2016 Shape A/S. All rights reserved.
//

#import "CHDSegment.h"

@implementation CHDSegment

- (NSString *)mapPropertyForPropertyWithName:(NSString *)propName {
    if ([propName isEqualToString:@"segmentId"]) {
        return @"id";
    }
    return [super mapPropertyForPropertyWithName:propName];
}

@end
