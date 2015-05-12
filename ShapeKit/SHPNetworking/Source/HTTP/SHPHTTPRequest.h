//
//  SHPHTTPRequest.h
//  SHPNetworking
//
//  Created by Kasper Kronborg on 17/11/12.
//  Copyright (c) 2012 SHAPE A/S. All rights reserved.
//

#import <Foundation/Foundation.h>


typedef void(^SHPHTTPRequestShouldDispatch)(BOOL *cancel);
typedef void(^SHPHTTPRequestCompletionBlock)(NSURLResponse *response, NSData *data, NSError *error);
typedef void(^SHPHTTPRequestProgressBlock)(float progress);

typedef enum {
    SHPHTTPRequestMethodGET = 1,
    SHPHTTPRequestMethodPOST,
    SHPHTTPRequestMethodPUT,
    SHPHTTPRequestMethodPATCH,
    SHPHTTPRequestMethodDELETE
} SHPHTTPRequestMethod;

extern NSString * const SHPHTTPRequestHTTPStatusCode;
NSString *SHPRequestStringFromMethod(SHPHTTPRequestMethod method);

@interface SHPHTTPRequest : NSOperation

/* The URL that the request is being dispatched to
 */
@property (nonatomic, strong) NSURL *URL;

/* The cache policy that will be used by the dispatched request
   The default value is NSURLRequestUseProtocolCachePolicy
*/
@property (nonatomic, assign) NSURLRequestCachePolicy cachePolicy;

/* HTTP request method the request is being dispatched with
 */
@property (nonatomic, assign) SHPHTTPRequestMethod method;

/* HTTP request body
 */
@property (nonatomic, copy) NSData *body;

/* Block callback before checking if the request should be dispatched.
 */
@property (nonatomic, strong) SHPHTTPRequestShouldDispatch shouldDispatchBlock;

/* Block callback for a request
 */
@property (nonatomic, strong) SHPHTTPRequestCompletionBlock onCompletionBlock;

@property(nonatomic, assign) BOOL ignoreCache;

/* Allow making requests to backends that use untrusted SSL certificates
 */
@property(nonatomic) BOOL allowUntrustedSSLCertificate;

/* Operation queue to execute the completion block on, which will be used for parsing. Default is main thread
*/
@property (nonatomic, strong) NSOperationQueue *completionOperationQueue;

/* Block callback when new upload progress
 */
@property (nonatomic, strong) SHPHTTPRequestProgressBlock uploadProgressBlock;

/* Block callback when new download progress
 */
@property (nonatomic, strong) SHPHTTPRequestProgressBlock downloadProgressBlock;

/* Convenience initializers
 */
+ (id)requestWithURL:(NSURL *)URL;
- (id)initWithURL:(NSURL *)URL;

/* Sets the value for a given key overwriting values previously added to the key.
 * This method replaces addValue:forQueryParameterKey:
 */
- (void)setValue:(NSString *)value forQueryParameterKey:(NSString *)key;
- (void)addValue:(NSString *)value forQueryParameterKey:(NSString *)key __deprecated;

/* Appends the value to any values previously added to the key.
 */
- (void)appendValue:(NSString *)value forQueryParameterKey:(NSString *)key;

/* Setting and getting header fields
 */
- (void)addValue:(NSString *)value forHeaderField:(NSString *)key;
- (void)setValue:(NSString *)value forHTTPHeaderField:(NSString *)field;
- (NSString *)valueForHTTPHeaderField:(NSString *)field;
- (NSDictionary *)allHTTPHeaderFields;

- (void)setBasicAuthUsername:(NSString *)username password:(NSString *)password;

/// Requests are considered equievalent if the represent the same intent. Specifically, the URL and method on the two requests are equal.
- (BOOL)isEquivalentToRequest:(SHPHTTPRequest*)otherRequest;

@end
