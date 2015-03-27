//
// Created by Jakob Vinther-Larsen on 27/03/15.
// Copyright (c) 2015 Shape A/S. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSUserDefaults (CHDDefaults)

-(void) chdSetDefaultSiteId: (NSString*) siteId;
-(void) chdSetDefaultGroupId: (NSNumber*) groupId;
-(NSString*) chdDefaultSiteId;
-(NSNumber*) chdDefaultGroupId;

-(void)chdClearDefaults;

@end