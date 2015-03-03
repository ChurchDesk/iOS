//
// Created by Jakob Vinther-Larsen on 03/03/15.
// Copyright (c) 2015 Shape A/S. All rights reserved.
//

#import "CHDSite.h"
#import "CHDSitePermission.h"


@implementation CHDSite
- (Class)nestedClassForArrayPropertyWithName:(NSString *)propName {
    if([propName isEqualToString:@"permissions"]){
        return [CHDSitePermission class];
    }

    return [super nestedClassForArrayPropertyWithName:propName];
}

- (NSString *)mapPropertyForPropertyWithName:(NSString *)propName {
    return [super mapPropertyForPropertyWithName:propName];
}
@end