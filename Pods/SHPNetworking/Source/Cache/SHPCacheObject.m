//
//  SHPCacheObject.m
//  SHPNetworking
//
//  Created by Kasper Kronborg on 06/12/12.
//  Copyright (c) 2012 SHAPE A/S. All rights reserved.
//

#import "SHPCacheObject.h"



@implementation SHPCacheObject

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    if (self) {
        self->_key = [aDecoder decodeObjectForKey:@"key"];
        self->_date = [aDecoder decodeObjectForKey:@"date"];
        self->_interval = [aDecoder decodeDoubleForKey:@"interval"];
        self->_content = [aDecoder decodeObjectForKey:@"content"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:_key forKey:@"key"];
    [aCoder encodeObject:_date forKey:@"date"];
    [aCoder encodeDouble:_interval forKey:@"interval"];
    [aCoder encodeObject:_content forKey:@"content"];
}

- (BOOL)isExpired {
	NSTimeInterval secondsOld = -[self.date timeIntervalSinceNow];
	if (secondsOld < self.interval) {
		return NO;
	}
	return YES;
}

@end
