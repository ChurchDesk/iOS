//
//  SHPNetworking.h
//  SHPNetworking
//
//  Created by Kasper Kronborg on 17/11/12.
//  Copyright (c) 2012 SHAPE A/S. All rights reserved.
//

#ifdef __OBJC__

// Categories
#import "NSURL+SHPNetworkingAdditions.h"
#import "SHPManagedModel+PropertiesDictionary.h"
#import "NSError+SHPNetworkingAdditions.h"
#import "NSString+SHPNetworkingAdditions.h"

// API
#import "SHPAPI.h"
#import "SHPAPIManager.h"
#import "SHPAPIResource.h"

// Data Transformers
#import "SHPDataTransformer.h"
#import "SHPJSONTransformer.h"

// Validators
#import "SHPValidator.h"
#import "SHPBlockValidator.h"

// Cache
#import "SHPCache.h"

// HTTP
#import "SHPHTTPClient.h"
#import "SHPHTTPRequest.h"
#import "SHPHTTPResponse.h"

// Model
#import "SHPManagedModel.h"

#import "SHPNetworkIndicatorManager.h"

#ifdef USE_REACTIVE_EXTENSION
#import "SHPAPIManager+ReactiveExtension.h"
#endif

#endif