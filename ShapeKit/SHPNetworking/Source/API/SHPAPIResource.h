//
//  SHPAPIResource.h
//  SHPNetworking
//
//  Created by Kasper Kronborg on 18/11/12.
//  Copyright (c) 2012 SHAPE A/S. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SHPDataTransformer.h"
#import "SHPValidator.h"



@interface SHPAPIResource : NSObject

/* Path for the resource, must be unique.
 */
@property (nonatomic, copy) NSString *path;

/* Set the data transformer to be used when transforming the request and response
 from and to the API. Default value if not set is SHPJSONTransformer.
 */
@property (nonatomic, strong) id <SHPDataTransformer> dataTransformer;

/* The result key path for the result we want to populate our managed model.
 If not set, we use the root object. If this is set, the object being used for 
 populating should be of type NSDictionary or an error will occur during population
 */
@property (nonatomic, copy) NSString *resultKeyPath;

/* The result key path for the error we want to populate our managed model.
 If not set, we use the root object. If this is set, the object being used for
 populating should be of type NSDictionary or an error will occur during population
 */
@property (nonatomic, copy) NSString *errorResultKeyPath;

/* The class of the instance that should be populated by the resource. 
 Should be a subclass of SHPManagedModel or one of the following native
 types: NSArray, NSDictionary or NSString
 */
@property (nonatomic, assign) Class resultObjectClass;

/* The class of the error that should be populated by the resource.
 Should be a subclass of SHPManagedModel or one of the following native
 types: NSArray, NSDictionary or NSString
 */
@property (nonatomic, assign) Class errorResultObjectClass;

/* The cache interval is how long the resource should be cached. Only resources
 dispatched with a GET request is cached.
 */
@property (nonatomic, assign) NSTimeInterval cacheInterval;

/* Array of ranges with acceptable status code.
 The default value is @[ <200-299> ]
 You can extend the default value with a new range like this:
 ```
 NSValue *extraRangeValue = [NSValue valueWithRange:NSMakeRange(500, 2)]; // allow status codes 500 and 501
 resource.acceptableStatusCodeRanges = [resource.acceptableStatusCodeRanges arrayByAddingObject:extraRangeValue];
 ```
 Note that some status codes are handled at the NSURLConnection level and will result in cocoa errors (e.g. 401).
 */
@property(nonatomic, strong) NSArray *acceptableStatusCodeRanges;

/* Convenience initializers
 */
- (id)initWithPath:(NSString *)path;

/* Set validators. Resets validators.
 */
- (void)setValidators:(NSArray *)validators;

/* Add a validator
 */
- (void)addValidator:(id <SHPValidator>)validator;

/* Resources validators is for validating the response negotiated with the API.
 The object being validated is after data transformation has happend.
 */
- (NSArray *)validators;

/* Returns an object with the result class popluated with the data in object.
 */
- (id)objectOfResultClassPopulatedWithObject:(id)object error:(NSError **)error;

/* Returns an object with the error result class popluated with the data in object.
 */
- (id)objectOfErrorResultClassPopulatedWithObject:(id)object error:(NSError *__autoreleasing *)error;

@end
