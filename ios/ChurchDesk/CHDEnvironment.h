//
//  CHDEnvironment.h
//  ChurchDesk
//
//  Created by Mikkel Selsøe Sørensen on 26/02/15.
//  Copyright (c) 2015 Shape A/S. All rights reserved.
//

#import "CHDManagedModel.h"
#import "CHDEventCategory.h"
#import "CHDResource.h"
#import "CHDGroup.h"
#import "CHDPeerUser.h"

@interface CHDEnvironment : CHDManagedModel

@property (nonatomic, strong) NSArray *eventCategories;
@property (nonatomic, strong) NSArray *resources;
@property (nonatomic, strong) NSArray *groups;
@property (nonatomic, strong) NSArray *users;

- (CHDEventCategory*) eventCategoryWithId: (NSNumber*) eventCategoryId;
- (NSArray*) eventCategoriesWithSiteId: (NSString*) siteId;

- (CHDResource*) resourceWithId: (NSNumber*) resourceId;
- (NSArray*) resourcesWithSiteId: (NSString*) siteId;

- (CHDGroup*) groupWithId: (NSNumber*) groupId;
- (NSArray*) groupsWithSiteId: (NSString*) siteId;

- (CHDPeerUser*) userWithId: (NSNumber*) userId siteId: (NSString*) siteId;
- (NSArray*) usersWithSiteId: (NSString*) siteId;

@end
