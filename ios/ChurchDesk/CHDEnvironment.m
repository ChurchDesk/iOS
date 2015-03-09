//
//  CHDEnvironment.m
//  ChurchDesk
//
//  Created by Mikkel Selsøe Sørensen on 26/02/15.
//  Copyright (c) 2015 Shape A/S. All rights reserved.
//

#import "CHDEnvironment.h"
#import "CHDEventCategory.h"
#import "CHDResource.h"
#import "CHDGroup.h"
#import "CHDPeerUser.h"

@implementation CHDEnvironment

- (NSString *)mapPropertyForPropertyWithName:(NSString *)propName {
    if ([propName isEqualToString:@"eventCategories"]) {
        return @"categories";
    }
    if ([propName isEqualToString:@"resources"]) {
        return @"resource";
    }
    return [super mapPropertyForPropertyWithName:propName];
}

- (Class)nestedClassForArrayPropertyWithName:(NSString *)propName {
    if ([propName isEqualToString:@"eventCategories"]) {
        return [CHDEventCategory class];
    }
    if ([propName isEqualToString:@"resources"]) {
        return [CHDResource class];
    }

    if ([propName isEqualToString:@"groups"]) {
        return [CHDGroup class];
    }

    if ([propName isEqualToString:@"users"]) {
        return [CHDPeerUser class];
    }
    return [super nestedClassForArrayPropertyWithName:propName];
}

- (CHDEventCategory*) eventCategoryWithId: (NSNumber*) eventCategoryId {
    return eventCategoryId ? [self.eventCategories shp_detect:^BOOL(CHDEventCategory *eventCategory) {
        return [eventCategory.categoryId isEqualToNumber:eventCategoryId];
    }] : nil;
}

- (CHDResource*) resourceWithId: (NSNumber*) resourceId {
    return resourceId ? [self.resources shp_detect:^BOOL(CHDResource *resource) {
        return [resource.resourceId isEqualToNumber:resourceId];
    }] : nil;
}

- (CHDGroup*) groupWithId: (NSNumber*) groupId {
    return groupId ? [self.groups shp_detect:^BOOL(CHDGroup *group) {
        return [group.groupId isEqualToNumber:groupId];
    }] : nil;
}

- (CHDPeerUser*) userWithId: (NSNumber*) userId {
    return userId ? [self.users shp_detect:^BOOL(CHDPeerUser *user) {
        return [user.userId isEqualToNumber:userId];
    }] : nil;
}

@end
