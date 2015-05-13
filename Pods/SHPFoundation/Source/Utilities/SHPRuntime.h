//
// Created by philip on 23/12/14.
//
// Copyright SHAPE A/S
//

#import <Foundation/Foundation.h>

@interface SHPRuntime : NSObject

/// ---------------------------------------------------------------------
/// @name Classes
/// ---------------------------------------------------------------------

/// Returns all classes registered in the runtime
+ (NSArray *)runtimeClasses;

/// Returns all classes registered in the runtime conforming to a certain protocol
+ (NSArray *)runtimeClassesConformingToProtocol:(Protocol *)aProtocol;

@end
