//
// Created by Jakob Vinther-Larsen on 03/03/15.
// Copyright (c) 2015 Shape A/S. All rights reserved.
//

#import "CHDUser.h"
#import "CHDSite.h"


@implementation CHDUser

- (Class)nestedClassForArrayPropertyWithName:(NSString *)propName {
    if([propName isEqualToString:@"sites"]){
        return [CHDSite class];
    }

    return [super nestedClassForArrayPropertyWithName:propName];
}

- (NSString *)mapPropertyForPropertyWithName:(NSString *)propName {
    if ([propName isEqualToString:@"pictureURL"]) {
        return @"picture";
    }
    return [super mapPropertyForPropertyWithName:propName];
}
@end