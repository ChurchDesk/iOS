//
//  SHPHTTPRequest.m
//  SHPNetworking
//
//  Created by Kasper Kronborg on 17/11/12.
//  Copyright (c) 2012 SHAPE A/S. All rights reserved.
//

#import "SHPHTTPRequest.h"
#import "NSURL+SHPNetworkingAdditions.h"
#import "SHPNetworkingErrors.h"
#import "SHPNetworkBase64.h"

NSString * const SHPHTTPRequestHTTPStatusCode = @"http_status_code";

NSString *SHPRequestStringFromMethod(SHPHTTPRequestMethod method)
{
    switch (method) {
        case SHPHTTPRequestMethodPOST:
        {
            return @"POST";
        }
        case SHPHTTPRequestMethodPUT:
        {
            return @"PUT";
        }
        case SHPHTTPRequestMethodDELETE:
        {
            return @"DELETE";
        }
        case SHPHTTPRequestMethodPATCH:
        {
            return @"PATCH";
        }
        case SHPHTTPRequestMethodGET:
        default:
        {
            return @"GET";
        }
    }
}


@interface SHPHTTPRequest () <NSURLConnectionDelegate, NSURLConnectionDataDelegate>

/* Instance variables for book-keeping the KVO-compliant properties of an NSOperation
 */
@property (nonatomic, assign, getter=isExecuting) BOOL executing;
@property (nonatomic, assign, getter=isConcurrent) BOOL concurrent;
@property (nonatomic, assign, getter=isFinished) BOOL finished;
@property (nonatomic, assign) long long int expectedContentLength;

@end

@implementation SHPHTTPRequest
{
    NSMutableURLRequest *_URLRequest;
    NSURLResponse *_URLResponse;
    NSURLConnection *_URLConnection;
    NSMutableData *_responseData;
    NSURL *_baseURL;
    NSMutableDictionary *_queryParameters;
}

// Needed when compiling using iOS 8 SDK, but gives warning on iOS 7 :(
@synthesize executing = _executing;
@synthesize finished = _finished;
@synthesize concurrent = _concurrent;

#pragma mark - Convenience initializers

+ (id)requestWithURL:(NSURL *)URL
{
    return [[SHPHTTPRequest alloc] initWithURL:URL];
}

- (id)initWithURL:(NSURL *)URL
{
    if (!(self = [super init])) return nil;

    _baseURL = URL;
    [self setURL:URL];

    /* Defaults
     */
    [self setMethod:SHPHTTPRequestMethodGET];
    self.cachePolicy = NSURLRequestUseProtocolCachePolicy;

    _URLRequest = [[NSMutableURLRequest alloc] init];
    _completionOperationQueue = [NSOperationQueue mainQueue];

    return self;
}

#pragma mark - Accessers

- (void)setMethod:(SHPHTTPRequestMethod)method
{
    if (_method != method) {
        [_URLRequest setHTTPMethod:SHPRequestStringFromMethod(method)];
        _method = method;
    }
}

- (void)setBody:(NSData *)body
{
    [_URLRequest setHTTPBody:body];
}

- (NSData *)body
{
    return [_URLRequest HTTPBody];
}

- (void)setExecuting:(BOOL)executing
{
	[self willChangeValueForKey:@"isExecuting"];
	_executing = executing;
	[self didChangeValueForKey:@"isExecuting"];
}

- (void)setConcurrent:(BOOL)concurrent
{
	[self willChangeValueForKey:@"isConcurrent"];
	_concurrent = concurrent;
	[self didChangeValueForKey:@"isConcurrent"];
}

- (void)setFinished:(BOOL)finished
{
	[self willChangeValueForKey:@"isFinished"];
	_finished = finished;
	[self didChangeValueForKey:@"isFinished"];
}


#pragma mark - Overwritten methods

- (void)start
{
    [self setConcurrent:YES]; // TODO: Should this be NO if the maxConcurrentOperations is 1?
    [self setExecuting:YES];

    if (![self shouldDispatch]) {
        [self setFinished:YES];
        return;
    }

    [_URLRequest setURL:self.URL];
    _URLRequest.cachePolicy = self.cachePolicy;

    _responseData = [NSMutableData dataWithCapacity: 0];

    _URLConnection = [[NSURLConnection alloc] initWithRequest:_URLRequest delegate:self startImmediately:NO];
    [_URLConnection scheduleInRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
    [_URLConnection start];
}

- (BOOL)isExecuting
{
    return _executing;
}

- (BOOL)isFinished
{
    return _finished;
}

- (BOOL)isConcurrent
{
    return _concurrent;
}

- (BOOL)isEquivalentToRequest:(SHPHTTPRequest*)otherRequest
{
    /* If the method and the absolute URL are equal we consider the requests to be equivalent.
     */
    if ([[self.URL absoluteString] isEqualToString:[otherRequest.URL absoluteString]] && self.method == otherRequest.method) {
        return YES;
    }

    return NO;
}

#pragma mark - Query Parameters

- (void)appendValue:(NSString *)value forQueryParameterKey:(NSString *)key
{
    [self addValue:value forQueryParameterKey:key overwriteExisting:NO];
}

- (void)addValue:(NSString *)value forQueryParameterKey:(NSString *)key
{
    [self setValue:value forQueryParameterKey:key];
}

- (void)setValue:(NSString *)value forQueryParameterKey:(NSString *)key
{
    [self addValue:value forQueryParameterKey:key overwriteExisting:YES];
}

- (void)addValue:(NSString *)value forQueryParameterKey:(NSString *)key overwriteExisting:(BOOL)overwriteExisting
{
    if (!_queryParameters) {
        _queryParameters = [[NSMutableDictionary alloc] init];
    }

    NSArray *values;

    if (overwriteExisting) {
        values = @[value];
    }
    else {
        values = [_queryParameters[key] ?: @[] arrayByAddingObject:value];
    }

    _queryParameters[key] = values;

    [self resetAndUpdateRequestURL];
}

#pragma mark - Header fields

- (void)addValue:(NSString *)value forHeaderField:(NSString *)key
{
    [_URLRequest addValue:value forHTTPHeaderField:key];
}

- (void)setValue:(NSString *)value forHTTPHeaderField:(NSString *)field {
    [_URLRequest setValue:value forHTTPHeaderField:field];
}

- (NSString *)valueForHTTPHeaderField:(NSString *)field {
    return [_URLRequest valueForHTTPHeaderField:field];
}

- (NSDictionary *)allHTTPHeaderFields {
    return [_URLRequest allHTTPHeaderFields];
}

- (void)setBasicAuthUsername:(NSString *)username password:(NSString *)password
{
    if ([username rangeOfString:@":"].location != NSNotFound)
        NSLog(@"Warning! Username %@ contains illegal : character", username);
    NSString *credentials = [NSString stringWithFormat:@"%@:%@", username, password];
//    NSString *encodedCredentials = [credentials shp_stringByBase64Encoding];
    NSString *encodedCredentials = [SHPNetworkBase64 stringByBase64EncodingString:credentials];
    NSString *authString = [NSString stringWithFormat:@"Basic %@", encodedCredentials];
    [self addValue:authString forHeaderField:@"Authorization"];
}

#pragma mark - NSURLConnectionDelegate

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    // This method is called when the server has determined that it
    // has enough information to create the NSURLResponse object.

    // It can be called multiple times, for example in the case of a
    // redirect, so each time we reset the data.

    // receivedData is an instance variable declared elsewhere.
    [_responseData setLength:0];

    _URLResponse = response;

    self.expectedContentLength = [response expectedContentLength];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    // Append the new data to receivedData.
    // receivedData is an instance variable declared elsewhere.
    [_responseData appendData:data];

    if (self.downloadProgressBlock) {
        CGFloat progress = self.expectedContentLength != 0 ? ((CGFloat)[_responseData length] / self.expectedContentLength) : 0;
        self.downloadProgressBlock(progress);
    }
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    [self finishWithResponse:_URLResponse data:_responseData error:nil];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    [self finishWithResponse:_URLResponse data:_responseData error:error];
}

- (BOOL)connectionShouldUseCredentialStorage:(NSURLConnection *)connection {
    return NO;
}

- (BOOL)connection:(NSURLConnection *)connection canAuthenticateAgainstProtectionSpace:(NSURLProtectionSpace *)protectionSpace {
    if (self.allowUntrustedSSLCertificate) {
        return [protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust];
    }

    return !([protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust] || [protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodClientCertificate]);
}

- (void)connection:(NSURLConnection *)connection didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge {
    if (self.allowUntrustedSSLCertificate) {
        if ([challenge.protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust]) {
            [challenge.sender useCredential:[NSURLCredential credentialForTrust:challenge.protectionSpace.serverTrust] forAuthenticationChallenge:challenge];
        }
    }
    
    [challenge.sender continueWithoutCredentialForAuthenticationChallenge:challenge];
}

- (void)connection:(NSURLConnection *)connection didSendBodyData:(NSInteger)bytesWritten totalBytesWritten:(NSInteger)totalBytesWritten totalBytesExpectedToWrite:(NSInteger)totalBytesExpectedToWrite {
    if (self.uploadProgressBlock) {
        CGFloat progress = totalBytesExpectedToWrite != 0 ? ((CGFloat)totalBytesWritten / totalBytesExpectedToWrite) : 0;
        self.uploadProgressBlock(progress);
    }
}

#pragma mark - Helpers

- (BOOL)shouldDispatch
{
    if (self.shouldDispatchBlock) {
        BOOL cancel = NO;
        self.shouldDispatchBlock(&cancel);
        return !cancel;
    }

    return YES;
}

- (void)finishWithResponse:(NSURLResponse *)response data:(NSData *)data error:(NSError *)error
{
    if (self.onCompletionBlock) {
        [self.completionOperationQueue addOperationWithBlock:^{
            self.onCompletionBlock(response, data, error);

//            [self setExecuting:NO]; // TODO: Should this be set to NO?
            [self setFinished:YES];
        }];
    }
    else {
//        [self setExecuting:NO]; // TODO: Should this be set to NO?
        [self setFinished:YES];
    }
}

- (void)resetAndUpdateRequestURL
{
    self.URL = [_baseURL URLByAppendingQueryParameters:_queryParameters];
}

@end
