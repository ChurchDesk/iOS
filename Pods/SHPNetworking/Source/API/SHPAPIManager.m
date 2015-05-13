//
//  SHPAPIManager.m
//  SHPNetworking
//
//  Created by Kasper Kronborg on 18/11/12.
//  Copyright (c) 2012 SHAPE A/S. All rights reserved.
//

#import "SHPAPIManager.h"

#import "SHPAPIResource.h"
#import "SHPHTTPClient.h"
#import "SHPCache.h"
#import "SHPMultipartElement.h"
#import "SHPAPICachedResponse.h"
#import "SHPHTTPResponse.h"
#import "SHPNetworkingErrors.h"

static NSString *const kMultipartBoundary = @"Lt2TPyKQZjgWkeUH6AMUK8xRXkmQZV9aaqBp";
static NSString *const SHPContentTypeHeaderName = @"Content-Type";

@interface SHPAPIManager ()

@property (nonatomic, strong) NSOperationQueue *deferredCacheRequestQueue;

@end

@implementation SHPAPIManager
{
    SHPHTTPClient *_httpClient;
}

#pragma mark - Convenience initializers

- (id)init
{
    if (!(self = [super init])) return nil;

    _httpClient = [[SHPHTTPClient alloc] init];
    _cache = [[SHPCache alloc] init];
    if (!_cache.diskCacheReady) {
        [self.deferredCacheRequestQueue setSuspended:YES];
        [self.cache addObserver:self forKeyPath:@"diskCacheReady" options:0 context:nil];
    }

    return self;
}

- (void)dealloc {
    @try {
        [self.cache removeObserver:self forKeyPath:@"diskCacheReady"];
    }
    @catch (NSException *exception) {
        // Ignore
    }
}

#pragma mark - Dispatching to resources

- (void)dispatchRequest:(SHPHTTPRequestBlock)requestBlock toResource:(SHPAPIResource *)resource withCompletion:(SHPAPIManagerResourceCompletionBlock)completionBlock
{
    [self dispatchRequest:requestBlock withBodyContent:nil toResource:resource withCompletion:completionBlock];
}

- (void)dispatchRequest:(SHPHTTPRequestBlock)requestBlock withBodyContent:(NSDictionary *)content toResource:(SHPAPIResource *)resource withCompletion:(SHPAPIManagerResourceCompletionBlock)completionBlock {
    [self dispatchRequest:requestBlock withBodyContent:content orMultiparts:nil toResource:resource withCompletion:completionBlock];
}

- (void)dispatchMultipartRequest:(SHPHTTPRequestBlock)requestBlock withParts:(NSArray *)parts toResource:(SHPAPIResource *)resource withCompletion:(SHPAPIManagerResourceCompletionBlock)completionBlock {
    [self dispatchRequest:requestBlock withBodyContent:nil orMultiparts:parts toResource:resource withCompletion:completionBlock];
}

- (void)dispatchRequest:(SHPHTTPRequestBlock)requestBlock withBodyContent:(NSDictionary *)content orMultiparts:(NSArray *)parts toResource:(SHPAPIResource *)resource withCompletion:(SHPAPIManagerResourceCompletionBlock)completionBlock
{
    dispatch_async(dispatch_get_main_queue(), ^{
	    NSAssert(!(content && parts), @"Multipart elements and and content dict not allowed at the same time.");
	    /* Build URL for the resource
	     */
	    NSURL *URL = [self URLForResource:resource];

	    /* Dispatch the request for the resource
	     */
	    [_httpClient dispatchRequestToURL:URL usingBlock:^(SHPHTTPRequest *request) {

	        /* If we have content, attach it to the request after it has been transformed by the resource data transformer
	         */
	        if (content) {
	            NSError *error = nil;
	            NSData *body = [resource.dataTransformer dataWithObject:content error:&error];

	            if (error) {
	                [self callResourceCompletionBlock:completionBlock withResult:nil body:nil headers:nil statusCode:0 error:error];
	                return;
	            }

	            [request setBody:body];
	        } else if (parts) { // add multipart parts
	            NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@", kMultipartBoundary];
	            [request addValue:contentType forHeaderField:SHPContentTypeHeaderName];
	            NSMutableData *body = [NSMutableData data];
	            NSString *separator = [NSString stringWithFormat:@"\r\n--%@\r\n", kMultipartBoundary];
	            for (SHPMultipartElement *part in parts) {
	                [body appendData:[separator dataUsingEncoding:NSUTF8StringEncoding]];
	                NSData *partData = [part dataRepresentation];
	                [body appendData:partData];
	            }

	            NSString *terminationString = [NSString stringWithFormat:@"\r\n--%@--", kMultipartBoundary];
	            [body appendData:[terminationString dataUsingEncoding:NSUTF8StringEncoding]];
	            [request setBody:body];
	        }

	        /* Call the request block so it's possible to modify the request.
	         */
	        if (requestBlock) requestBlock(request);

	        // set Content-Type if we are sending JSON and it has not already been set by the requestBlock
	        if (content && ![request valueForHTTPHeaderField:SHPContentTypeHeaderName].length) {
	            [request setValue:@"application/json" forHTTPHeaderField:SHPContentTypeHeaderName];
	        }

	        /* If we have a GET request, check to see if we have a cached response.
	         */
	        if (request.method == SHPHTTPRequestMethodGET) {

	            /* Check if we have a cache present and return it.
	             */
                
                NSString *cacheKey = [request.URL absoluteString];
                BOOL ignoreCache = request.ignoreCache;
	            {
                    BOOL cacheReady = _cache.diskCacheReady;
                    BOOL useCacheObject = !ignoreCache && [_cache cacheContainsObjectForKey:cacheKey];
                    
                    void (^useCachedResponse)(void) = ^void(void) {
                        SHPAPICachedResponse *cachedResponse = [_cache cachedObjectForKey:cacheKey];
                        if (cachedResponse && !request.finished) {
                            NSLog(@"SHPNetworking: Using cached object for: %@", cacheKey);
                            [self callResourceCompletionBlock:completionBlock withResult:cachedResponse.result body:cachedResponse.body headers:cachedResponse.headers statusCode:cachedResponse.statusCode error:nil];
                        }
                    };
                    if (useCacheObject) {
                        if (cacheReady) {
                            // Cache ready and object available. Return that immediately.
                            useCachedResponse();
                        }
                        else {
                            // Cache not ready but object is available when cache becomes ready.
                            // Defer completion until cache is ready.
                            NSLog(@"SHPNetworking: Waiting for cache to be ready for %@", cacheKey);
                            [self.deferredCacheRequestQueue addOperationWithBlock:useCachedResponse];
                        }
                        
                        // We have found an object in the cache and will use that.
                        // Returning early means that the request completion block will not be set and the request not dispatched.
                        return;
                    }
                    else {
                        if (ignoreCache) {
                            NSLog(@"SHPNetworking: Ignoring cache for: %@", cacheKey);
                        }
                    }
	            }

	            /*
                 Re-check the cache contents when the request is about to be dispatched. The request should be cancelled if we get a cache hit at that time.
	             */
	            [request setShouldDispatchBlock:^(BOOL *cancel) {
	                SHPAPICachedResponse *cachedResponse = [_cache cachedObjectForKey:cacheKey];
	                if (cachedResponse && !ignoreCache) {
	                    *cancel = YES;
	                    [self callResourceCompletionBlock:completionBlock withResult:cachedResponse.result body:cachedResponse.body headers:cachedResponse.headers statusCode:cachedResponse.statusCode error:nil];
	                }
	            }];
	        }

	        /* Weak request.
	         */
	        __weak SHPHTTPRequest *weakRequest = request;

	        /* If we didn't have a cached result we set the completion block
	         */
	        [request setOnCompletionBlock:^(NSURLResponse *response, NSData *body, NSError *error) {

	            NSError *parseError = nil;
	            id bodyObject = nil;
                NSDictionary *headers = nil;
                NSInteger statusCode = 0;

                /* Extract headers and status code
                 */
                if ([response isKindOfClass:[NSHTTPURLResponse class]]) {
                    NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *) response;
                    headers = [httpResponse allHeaderFields];
                    statusCode = httpResponse.statusCode;
                }

                /* Parse response into a native object.
	             * Don't attempt to parse nil or empty data.
	             */
                if ([body length]) {
                    bodyObject = [resource.dataTransformer objectWithData:body error:&parseError];
                }

                /* Handle parse error
	             */
                if (parseError) {
                    [self callResourceCompletionBlock:completionBlock withResult:nil body:nil headers:headers statusCode:statusCode error:parseError];
                    return;
                }

                /* Check for internal errors from NSURLConnection in case we have an unresolved response code (eg. 401)
	             *
	             * We have parsed the potential body data so we send both the parsed data and the error in return
	             */
                if (error || (!bodyObject)) {
                    [self callResourceCompletionBlock:completionBlock withResult:nil body:bodyObject headers:headers statusCode:statusCode error:error];
                    return;
                }

                /* Validate the parsed object from the validators for the resource
                 */
                NSError *validationError = nil;
                [self validateObject:bodyObject forResource:resource error:&validationError];

                /* Handle validation error
                 */
                if (validationError) {
                    [self callResourceCompletionBlock:completionBlock withResult:nil body:bodyObject headers:headers statusCode:statusCode error:validationError];
                    return;
                }

                /* Check if status code is valid
                 */
                if (resource.acceptableStatusCodeRanges) {
                    BOOL acceptableStatusCode = NO;
                    for (NSValue *rangeValue in resource.acceptableStatusCodeRanges) {
                        NSRange range = [rangeValue rangeValue];
                        BOOL contained = NSLocationInRange((NSUInteger) statusCode, range);
                        if (contained) {
                            acceptableStatusCode = YES;
                            break;
                        }
                    }
                    if (!acceptableStatusCode) {
                        NSError *unacceptableStatusCodeError = [NSError errorWithDescription:[NSString stringWithFormat:@"Unacceptable status code %ld not in %@", (long)statusCode, resource.acceptableStatusCodeRanges]
                                                                                        code:SHPNetworkingErrorResponseStatusCodeNotAllowed];

                        /* Populate the error result class with the parsed object
                        */
                        id errorResult = [resource objectOfErrorResultClassPopulatedWithObject:bodyObject error:nil];

                        [self callResourceCompletionBlock:completionBlock withResult:errorResult body:bodyObject headers:headers statusCode:statusCode error:unacceptableStatusCodeError];
                        return;
                    }
                }

	            /* Populate the result class with the parsed object
	             */
	            NSError *populationError = nil;
	            id result = [resource objectOfResultClassPopulatedWithObject:bodyObject error:&populationError];

	            /* Handle population error
	             */
	            if (populationError) {
	                [self callResourceCompletionBlock:completionBlock withResult:nil body:bodyObject headers:headers statusCode:statusCode error:populationError];
	                return;
	            }

	            /* Only cache GET requests
	             */
	            if (weakRequest.method == SHPHTTPRequestMethodGET && resource.cacheInterval) {
	                SHPAPICachedResponse *cachedResponse = [[SHPAPICachedResponse alloc] init];
	                [cachedResponse setResult:result];
	                [cachedResponse setBody:bodyObject];
                    [cachedResponse setHeaders:headers];
                    [cachedResponse setStatusCode:statusCode];

	                [_cache cacheObject:cachedResponse forKey:[weakRequest.URL absoluteString] withInterval:resource.cacheInterval];
	            }

	            /* Success
	             */
	            [self callResourceCompletionBlock:completionBlock withResult:result body:bodyObject headers:headers statusCode:statusCode error:nil];
	            return;
	        }];
	    }];
    });
}

#pragma mark - Helpers

- (void)callResourceCompletionBlock:(SHPAPIManagerResourceCompletionBlock)block withResult:(id)result body:(id)body headers:(NSDictionary *)headers statusCode:(NSInteger)statusCode error:(NSError *)error
{
    if (block) {
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            SHPHTTPResponse *response = [SHPHTTPResponse responseWithResult:result body:body headers:headers statusCode:statusCode];
            block(response, error);
        }];
    }
}

- (NSURL *)URLForResource:(SHPAPIResource *)resource
{
    return [NSURL URLWithString:resource.path relativeToURL:_baseURL];
}

- (void)validateObject:(id)object forResource:(SHPAPIResource *)resource error:(NSError *__autoreleasing *)error
{
    __block NSError *validationError = nil;

    [[resource validators] enumerateObjectsUsingBlock:^(id <SHPValidator> validator, NSUInteger idx, BOOL *stop) {
        if (![validator validate:object error:&validationError]) {
            *stop = YES;
        }
    }];

    *error = validationError;
}

- (NSOperationQueue *)deferredCacheRequestQueue {
    if (!_deferredCacheRequestQueue) {
        _deferredCacheRequestQueue = [NSOperationQueue new];
        _deferredCacheRequestQueue.name = @"SHPNetworking deferred cache requests queue";
        _deferredCacheRequestQueue.maxConcurrentOperationCount = 1;
    }
    return _deferredCacheRequestQueue;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if (object == _cache) {
        if ([keyPath isEqualToString:@"diskCacheReady"]) {
            NSLog(@"SHPNetworking: Disk cache %@ready", _cache.diskCacheReady ? @"" : @"NOT ");
            [_deferredCacheRequestQueue setSuspended:!_cache.diskCacheReady];
        }
    }
}

@end
