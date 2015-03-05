//
// Created by Jakob Vinther-Larsen on 03/03/15.
// Copyright (c) 2015 Shape A/S. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CHDManagedModel.h"

@class CHDSite;

@interface CHDUser : CHDManagedModel

@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSURL *pictureURL;
@property (nonatomic, strong) NSArray *sites;

- (CHDSite*) siteWithId: (NSString*) siteId;

@end
