//
// Created by Jakob Vinther-Larsen on 17/03/15.
// Copyright (c) 2015 Shape A/S. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CHDManagedModel.h"


@interface CHDNotificationSettings : CHDManagedModel
@property (nonatomic) BOOL bookingUpdated;
@property (nonatomic) BOOL bookingCanceled;
@property (nonatomic) BOOL bookingCreated;
@property (nonatomic) BOOL message;
@end
