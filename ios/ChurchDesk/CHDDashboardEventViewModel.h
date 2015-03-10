//
// Created by Jakob Vinther-Larsen on 10/03/15.
// Copyright (c) 2015 Shape A/S. All rights reserved.
//

#import <Foundation/Foundation.h>

@class CHDUser;
@class CHDEvent;
@class CHDEnvironment;


@interface CHDDashboardEventViewModel : NSObject
@property (nonatomic, readonly) CHDUser *user;
@property (nonatomic, readonly) CHDEnvironment *environment;
@property (nonatomic, readonly) NSArray *events;

-(NSString*) formattedTimeForEvent: (CHDEvent*) event;
@end