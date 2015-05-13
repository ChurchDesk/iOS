//
//  NSURL+SHPNetworkingAdditions.h
//  SHPNetworking
//
//  Created by Kasper Kronborg on 19/11/12.
//  Copyright (c) 2012 SHAPE A/S. All rights reserved.
//

#import <Foundation/Foundation.h>



@interface NSURL (SHPNetworkingAdditions)

- (NSURL *)URLByAppendingQueryParameters:(NSDictionary *)params;

@end
