//
//  SHPAPI.h
//  SHPNetworking
//
//  Created by Kasper Kronborg on 04/12/12.
//  Copyright (c) 2012 SHAPE A/S. All rights reserved.
//

#import <Foundation/Foundation.h>


@class SHPAPIManager;

@interface SHPAPI : NSObject

@property (nonatomic, readonly) SHPAPIManager *manager;

+ (instancetype)sharedInstance;
- (void)setBaseURL:(NSURL *)baseURL;

@end
