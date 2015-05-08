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
    if([propName isEqualToString:@"groupIds"]){
        return @"groups";
    }
    return [super mapPropertyForPropertyWithName:propName];
}

- (CHDSite*) siteWithId: (NSString*) siteId {
    return siteId ? [self.sites shp_detect:^BOOL(CHDSite *site) {
        return [site.siteId isEqualToString:siteId];
    }] : nil;
}

- (NSNumber *)userIdForSiteId:(NSString *)siteId {
    CHDSite *site = [self siteWithId:siteId];
    return site.userId;
}

- (id)transformedValueForPropertyWithName:(NSString *)propName value:(id)value {
    if ([propName isEqualToString:@"pictureURL"]) {
        return [NSURL URLWithString:value];
    }
    return [super transformedValueForPropertyWithName:propName value:value];
}


@end
