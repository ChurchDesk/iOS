//
//  SHPCacheObject.h
//  SHPNetworking
//
//  Created by Kasper Kronborg on 06/12/12.
//  Copyright (c) 2012 SHAPE A/S. All rights reserved.
//

#import <Foundation/Foundation.h>



@interface SHPCacheObject : NSObject <NSCoding>

/* 
 */
@property (nonatomic, copy) NSString *key;

/* The date for when the object was cached
 */
@property (nonatomic, strong) NSDate *date;

/* How long should the result be cached for
 */
@property (nonatomic, assign) NSTimeInterval interval;

/* Content in the cache
 */
@property (nonatomic, retain) id content;
// Please add any new properties to the NSCoding methods in the implementation file

- (BOOL)isExpired;

@end
