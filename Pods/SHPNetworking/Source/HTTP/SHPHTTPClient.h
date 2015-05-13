//
//  SHPHTTPClient.h
//  SHPNetworking
//
//  Created by Kasper Kronborg on 17/11/12.
//  Copyright (c) 2012 SHAPE A/S. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SHPHTTPRequest.h"



@class SHPHTTPRequest;

typedef void(^SHPHTTPRequestBlock)(SHPHTTPRequest *request);

@interface SHPHTTPClient : NSObject
- (void)dispatchRequestToURL:(NSURL *)URL usingBlock:(SHPHTTPRequestBlock)block;
@end
