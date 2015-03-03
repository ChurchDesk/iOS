//
// Created by Jakob Vinther-Larsen on 03/03/15.
// Copyright (c) 2015 Shape A/S. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CHDManagedModel.h"

@class CHDSitePermission;

@interface CHDSite : CHDManagedModel
@property (nonatomic, strong) NSNumber *userId;
@property (nonatomic, strong) NSString *siteName;
@property (nonatomic) BOOL attendenceEnabled;
@property (nonatomic, strong) NSString *site;
@property (nonatomic, strong) CHDSitePermission* permission;
@end