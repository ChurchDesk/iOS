//
// Created by Jakob Vinther-Larsen on 03/03/15.
// Copyright (c) 2015 Shape A/S. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CHDEnvironment.h"
#import "CHDMessage.h"

@interface CHDNewMessageViewModel : NSObject
@property (nonatomic, assign) CHDMessage* message;
@property (nonatomic, assign) CHDEnvironment *environment;
@property (nonatomic, readonly) NSArray* selectableGroups;
@end