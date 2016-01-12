//
// Created by Jakob Vinther-Larsen on 03/03/15.
// Copyright (c) 2015 Shape A/S. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CHDManagedModel.h"


@interface CHDSitePermission : CHDManagedModel
@property (nonatomic) BOOL canCreateEvent;
@property (nonatomic) BOOL canCreateMessage;
@property (nonatomic) BOOL canDoubleBook;
@property (nonatomic) BOOL canCreateAbsence;
@property (nonatomic) BOOL canCreateAbsenceAndBook;
@end