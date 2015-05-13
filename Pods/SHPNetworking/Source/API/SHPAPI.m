//
//  SHPAPI.m
//  SHPNetworking
//
//  Created by Kasper Kronborg on 04/12/12.
//  Copyright (c) 2012 SHAPE A/S. All rights reserved.
//

#import "SHPAPI.h"

#import "SHPAPIManager.h"



@implementation SHPAPI

#pragma mark - Singleton

+ (instancetype)sharedInstance
{
    __strong static id sharedObject = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedObject = [[self alloc] init];
    });
    
    return sharedObject;
}

#pragma mark - Initializers

- (id)init
{
    if (!(self = [super init])) return nil;
    
    _manager = [[SHPAPIManager alloc] init];
    
    return self;
}

#pragma mark - Setters

- (void)setBaseURL:(NSURL *)baseURL
{
    [_manager setBaseURL:baseURL];
}

@end
