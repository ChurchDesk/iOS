//
//  SHPJSONTransformer.m
//  SHPNetworking
//
//  Created by Kasper Kronborg on 20/11/12.
//  Copyright (c) 2012 SHAPE A/S. All rights reserved.
//

#import "SHPJSONTransformer.h"

@implementation SHPJSONTransformer

- (id)objectWithData:(NSData *)data error:(NSError *__autoreleasing *)error
{
    return [NSJSONSerialization JSONObjectWithData:data options:0 error:error];
}

- (NSData *)dataWithObject:(id)object error:(NSError *__autoreleasing *)error
{
    return [NSJSONSerialization dataWithJSONObject:object options:0 error:error];
}

@end
