//
//  SHPAPIManager.h
//  SHPNetworking
//
//  Created by Kasper Kronborg on 18/11/12.
//  Copyright (c) 2012 SHAPE A/S. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SHPHTTPClient.h"


@class SHPAPIResource, SHPCache, SHPHTTPResponse;

typedef void(^SHPAPIManagerResourceCompletionBlock)(SHPHTTPResponse *response, NSError *error);

@interface SHPAPIManager : NSObject

/* The base URL for the API
 */
@property (nonatomic, strong) NSURL *baseURL;

/* API Cache
 */
@property (nonatomic, readonly) SHPCache *cache;

/* Dispatch to a resource where you will be using GET request
 */
- (void)dispatchRequest:(SHPHTTPRequestBlock)requestBlock toResource:(SHPAPIResource *)resource withCompletion:(SHPAPIManagerResourceCompletionBlock)completionBlock;

/* Dispatch a request to a resource where the content is the HTTP body of the request. Used in eg. POST requests.
 */
- (void)dispatchRequest:(SHPHTTPRequestBlock)requestBlock withBodyContent:(NSDictionary *)content toResource:(SHPAPIResource *)resource withCompletion:(SHPAPIManagerResourceCompletionBlock)completionBlock;

// parts is an array of SHPFormMultipartElement
- (void)dispatchMultipartRequest:(SHPHTTPRequestBlock)requestBlock withParts:(NSArray *)parts toResource:(SHPAPIResource *)resource withCompletion:(SHPAPIManagerResourceCompletionBlock)completionBlock;

- (void)dispatchRequest:(SHPHTTPRequestBlock)requestBlock withBodyContent:(NSDictionary *)content orMultiparts:(NSArray *)parts toResource:(SHPAPIResource *)resource withCompletion:(SHPAPIManagerResourceCompletionBlock)completionBlock;

- (NSURL *)URLForResource:(SHPAPIResource *)resource;

@end
