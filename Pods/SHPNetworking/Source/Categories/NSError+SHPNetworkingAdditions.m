//
//  NSError+SHPNetworkingAdditions.m
//  SHPNetworking
//
//  Created by Kasper Kronborg on 22/11/12.
//  Copyright (c) 2012 SHAPE A/S. All rights reserved.
//

#import "NSError+SHPNetworkingAdditions.h"



@implementation NSError (SHPNetworkingAdditions)

+ (id)errorWithDescription:(NSString *)desc code:(NSInteger)code
{
    NSDictionary *userInfo = @{ NSLocalizedDescriptionKey: desc };
    
    return [NSError errorWithDomain:@"dk.shape.pod.SHPNetworking" code:code userInfo:userInfo];
}

@end
