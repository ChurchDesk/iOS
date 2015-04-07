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

#pragma mark - Categories

- (CHDEventCategory*) eventCategoryWithId: (NSNumber*) eventCategoryId siteId: (NSString*) siteId{
    return eventCategoryId ? [self.eventCategories shp_detect:^BOOL(CHDEventCategory *eventCategory) {
        return [eventCategory.categoryId isEqualToNumber:eventCategoryId] && [eventCategory.siteId isEqualToString:siteId];
    }] : nil;
}

- (NSArray*) eventCategoriesWithSiteId: (NSString*) siteId {
    return siteId ? [self.eventCategories shp_filter:^BOOL(CHDEventCategory *eventCategory) {
        return [eventCategory.siteId isEqualToString:siteId];
    }] : nil;
}

#pragma mark - Resources

- (CHDResource*) resourceWithId: (NSNumber*) resourceId siteId: (NSString*) siteId{
    return resourceId ? [self.resources shp_detect:^BOOL(CHDResource *resource) {
        return [resource.resourceId isEqualToNumber:resourceId] && [resource.siteId isEqualToString:siteId];
    }] : nil;
}

- (NSArray*) resourcesWithSiteId: (NSString*) siteId {
    return siteId ? [self.resources shp_filter:^BOOL(CHDResource *resource) {
        return [resource.siteId isEqualToString:siteId];
    }] : nil;
}

#pragma mark - Groups

- (CHDGroup*) groupWithId: (NSNumber*) groupId {
    return groupId ? [self.groups shp_detect:^BOOL(CHDGroup *group) {
        return [group.groupId isEqualToNumber:groupId];
    }] : nil;
}

- (NSArray*) groupsWithSiteId: (NSString*) siteId {
    RACSequence *results = [self.groups.rac_sequence filter:^BOOL(CHDGroup * group) {
        return [group.siteId isEqualToString:siteId];
    }];

    return results.array;
}

#pragma mark - Users

- (CHDPeerUser*) userWithId: (NSNumber*) userId siteId: (NSString*) siteId {
    return userId ? [self.users shp_detect:^BOOL(CHDPeerUser *user) {
        return [user.userId isEqualToNumber:userId] && [user.siteId isEqualToString:siteId];
    }] : nil;
}

- (NSArray*) usersWithSiteId: (NSString*) siteId {
    return siteId ? [self.users shp_filter:^BOOL(CHDPeerUser *user) {
        return [user.siteId isEqualToString:siteId];
    }] : nil;
}

@end
