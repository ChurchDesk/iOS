//
//  SHPHTTPClient.m
//  SHPNetworking
//
//  Created by Kasper Kronborg on 17/11/12.
//  Copyright (c) 2012 SHAPE A/S. All rights reserved.
//

#import "SHPHTTPClient.h"
#import "SHPNetworkIndicatorManager.h"


@implementation SHPHTTPClient
{
    NSOperationQueue *_requestQueue;
}

- (id)init
{
    if (!(self = [super init])) return nil;
    
    _requestQueue = [[NSOperationQueue alloc] init];
    _requestQueue.name = @"SHPHTTPClient request queue";
    [[SHPNetworkIndicatorManager sharedNetworkIndicatorManager] addNetworkOperationQueue:_requestQueue];
    
    return self;
}

#pragma mark - Dispatching requests

- (void)dispatchRequestToURL:(NSURL *)URL usingBlock:(SHPHTTPRequestBlock)block
{
    /* Initialize a GET request, as the default request.
     */
    SHPHTTPRequest *request = [[SHPHTTPRequest alloc] initWithURL:URL];

    /* Call the request block, so the request can be manipulated further.
     */
    if (block) block(request);

    /* Check if the request has got an completion block, otherwise there are no need
     for sending the request and therefore not even add it to the queue.
     */
    if (request.onCompletionBlock) {

        /* See if the request is depended on other requests in the queue already.
         */
        [self setDependenciesForRequest:request];

        /* Add the request to the queue.
         */
        [_requestQueue addOperation:request];
    }
}

#pragma mark - Helpers

- (void)setDependenciesForRequest:(SHPHTTPRequest *)request
{
    NSMutableArray *mDependencies = [NSMutableArray arrayWithCapacity:[_requestQueue.operations count]];
    for (SHPHTTPRequest *queueRequest in _requestQueue.operations) {
        if ([request isEquivalentToRequest:queueRequest]) {
            [mDependencies addObject:queueRequest];
        }
    }

    for (SHPHTTPRequest *dependedRequest in mDependencies) {
        if (![request.dependencies containsObject:dependedRequest]) {
            [request addDependency:dependedRequest];
        }
    }
}

@end
