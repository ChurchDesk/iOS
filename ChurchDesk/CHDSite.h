//
// Created by Jakob Vinther-Larsen on 03/03/15.
// Copyright (c) 2015 Shape A/S. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CHDManagedModel.h"

@class CHDSitePermission;

@interface CHDSite : CHDManagedModel
@property (nonatomic, strong) NSString *siteId;
@property (nonatomic, strong) NSNumber *userId;
@property (nonatomic, strong) NSString *name;
@property (nonatomic) BOOL attendenceEnabled;
@property (nonatomic, strong) CHDSitePermission *permissions;
@property (nonatomic, strong) NSDictionary *packages;
@property (nonatomic, strong) NSArray *groupIds;
@end
