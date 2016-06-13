//
//  CHDTag.m
//  ChurchDesk
//
//  Created by Chirag Sharma on 13/06/16.
//  Copyright © 2016 ChurchDesk ApS. All rights reserved.
//

#import "CHDTag.h"

@implementation CHDTag

- (NSString *)mapPropertyForPropertyWithName:(NSString *)propName {
    if ([propName isEqualToString:@"tagId"]) {
        return @"id";
    }
    return [super mapPropertyForPropertyWithName:propName];
}

@end
