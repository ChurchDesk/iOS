//
//  SHPNetworkingErrors.h
//  SHPNetworking
//
//  Created by Kasper Kronborg on 22/11/12.
//  Copyright (c) 2012 SHAPE A/S. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "NSError+SHPNetworkingAdditions.h"

#ifdef __OBJC__

// SHPParserValidator
static NSInteger const SHPNetworkingErrorValidatingObjectClass = 1000;
static NSInteger const SHPNetworkingErrorInvalidResponseObject = 1001;

// SHPAPIResource
static NSInteger const SHPNetworkingErrorResponseStatusCodeNotAllowed = 2000;
static NSInteger const SHPNetworkingErrorFailedToPopluateModel = 2001;

#endif
