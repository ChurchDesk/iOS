//
//  CHDEnvironment.m
//  ChurchDesk
//
//  Created by Mikkel Selsøe Sørensen on 26/02/15.
//  Copyright (c) 2015 Shape A/S. All rights reserved.
//

#import "CHDEnvironment.h"
#import "CHDEventCategory.h"
#import "CHDAbsenceCategory.h"
#import "CHDResource.h"
#import "CHDGroup.h"
#import "CHDPeerUser.h"
#import "CHDSite.h"

@implementation CHDEnvironment

- (NSString *)mapPropertyForPropertyWithName:(NSString *)propName {
    return [super mapPropertyForPropertyWithName:propName];
}

- (Class)nestedClassForArrayPropertyWithName:(NSString *)propName {
    if ([propName isEqualToString:@"eventCategories"]) {
        return [CHDEventCategory class];
    }
    if ([propName isEqualToString:@"absenceCategories"]) {
        return [CHDAbsenceCategory class];
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

#pragma mark - Event Categories

- (CHDEventCategory*) eventCategoryWithId: (NSNumber*) eventCategoryId siteId: (NSString*) siteId{
    return eventCategoryId ? [self.eventCategories shp_detect:^BOOL(CHDEventCategory *eventCategory) {
        return eventCategory.categoryId.integerValue == eventCategoryId.integerValue;
    }] : nil;
}

- (NSArray*) eventCategoriesWithSiteId: (NSString*) siteId {
    return siteId ? [self.eventCategories shp_filter:^BOOL(CHDEventCategory *eventCategory) {
        return [eventCategory.siteId isEqualToString:siteId];
    }] : nil;
}

#pragma mark - Absence Categories

- (CHDAbsenceCategory*) absenceCategoryWithId: (NSNumber*) absenceCategoryId siteId: (NSString*) siteId{
    return absenceCategoryId ? [self.absenceCategories shp_detect:^BOOL(CHDAbsenceCategory *absenceCategory) {
        return absenceCategory.categoryId.integerValue == absenceCategoryId.integerValue;
    }] : nil;
}

- (NSArray*) absenceCategoriesWithSiteId: (NSString*) siteId {
    return siteId ? [self.absenceCategories shp_filter:^BOOL(CHDAbsenceCategory *absenceCategory) {
        return [absenceCategory.siteId isEqualToString:siteId];
    }] : nil;
}

#pragma mark - Resources

- (CHDResource*) resourceWithId: (NSNumber*) resourceId siteId: (NSString*) siteId{
    return resourceId ? [self.resources shp_detect:^BOOL(CHDResource *resource) {
        return (resource.resourceId.integerValue == resourceId.integerValue) && [resource.siteId isEqualToString:siteId];
    }] : nil;
}

- (NSArray*) resourcesWithSiteId: (NSString*) siteId {
    return siteId ? [self.resources shp_filter:^BOOL(CHDResource *resource) {
        return [resource.siteId isEqualToString:siteId];
    }] : nil;
}

#pragma mark - Groups

- (CHDGroup*) groupWithId: (NSNumber*) groupId siteId: (NSString*) siteId {
    return groupId ? [self.groups shp_detect:^BOOL(CHDGroup *group) {
        return [group.groupId isEqualToNumber:groupId] && [group.siteId isEqualToString:siteId];
    }] : nil;
}

- (NSArray*) groupsWithSiteId: (NSString*) siteId {
    RACSequence *results = [self.groups.rac_sequence filter:^BOOL(CHDGroup * group) {
        return [group.siteId isEqualToString:siteId];
    }];

    return results.array;
}

- (NSArray*) groupsWithSiteId: (NSString*) siteId groupIds: (NSArray*) groupIds {
    RACSequence *results = [self.groups.rac_sequence filter:^BOOL(CHDGroup * group) {
        return [group.siteId isEqualToString:siteId] && [groupIds containsObject:group.groupId];
    }];

    return results.array;
}

#pragma mark - Users

- (CHDPeerUser*) userWithId: (NSNumber*) userId siteId: (NSString*) siteId {
    return userId ? [self.users shp_detect:^BOOL(CHDPeerUser *user) {
        return (user.userId.integerValue == userId.integerValue);
    }] : nil;
}

- (NSArray *)usersWithSiteId:(NSString *)siteId{
    return siteId ? [self.users shp_filter:^BOOL(CHDPeerUser *user) {
        /*if (siteId.integerValue == 245 && user.userId.integerValue == 3215 ) {
            user.siteIds;
        }*/
        for (int numberOfSiteIds = 0; numberOfSiteIds < user.siteIds.count; numberOfSiteIds++) {
            if ([[user.siteIds objectAtIndex:numberOfSiteIds] integerValue] == siteId.integerValue) {
                return YES;
            }
        }
        return NO;
    }] : nil;
}
@end
