//
//  NSError+SHPNetworkingAdditions.h
//  SHPNetworking
//
//  Created by Kasper Kronborg on 22/11/12.
//  Copyright (c) 2012 SHAPE A/S. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "SHPNetworkingErrors.h"



@interface NSError (SHPNetworkingAdditions)

+ (id)errorWithDescription:(NSString *)desc code:(NSInteger)code;

@end
