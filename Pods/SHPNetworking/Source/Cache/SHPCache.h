//
//  SHPCache.h
//  SHPNetworking
//
//  Created by Kasper Kronborg on 06/12/12.
//  Copyright (c) 2012 SHAPE A/S. All rights reserved.
//

#import <Foundation/Foundation.h>



@interface SHPCache : NSObject

/**
 diskCacheReady is NO until the entire disk cache is loaded from disk (KVO compliant).
 @see cacheContainsObjectForKey:
 */
@property (nonatomic, readonly) BOOL diskCacheReady;

/**
 Sets the maximum age limit of items in the disk cache.
 Default value is 0, meaning there is no expiration date on disk cache items.
 */
@property (nonatomic, assign) NSTimeInterval diskCacheAgeLimit;

- (void)cacheObject:(id)object forKey:(NSString *)key withInterval:(NSTimeInterval)interval;
- (id)cachedObjectForKey:(NSString *)key;

/**
 Query the cache before it is ready.
 @return Returns YES if the cache contains an object for key when cache is ready.
 */
- (BOOL) cacheContainsObjectForKey: (NSString*) key;

- (NSArray *)allKeys;
- (NSArray *)keysMatchingRegex:(NSString *)regexPattern;

- (void)invalidateAllObjects;
- (void)invalidateObjectsMatchingRegex:(NSString *)regex;

/**
 Caches all keys matching the provided regular expression patterns to disk.
 Matching objects must implement the NSCoding protocol.
 To disable disk cache, send an empty array.
 @warning All cached objects MUST conform to NSCoding. Expect crashes if they do not.
 */
- (void) setEnableDiskCacheForKeysMatchingRegexes: (NSArray*) regexes;

@end
