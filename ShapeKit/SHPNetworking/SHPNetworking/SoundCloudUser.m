//
//  SoundCloudUser.m
//  SHPNetworking
//
//  Created by Kasper Kronborg on 28/11/12.
//  Copyright (c) 2012 SHAPE A/S. All rights reserved.
//

#import "SoundCloudUser.h"



@implementation SoundCloudUser

- (NSString *)mapPropertyForPropertyWithName:(NSString *)propName
{
    if ([propName isEqualToString:@"userId"]) {
        return @"id";
    }
    
    return nil;
}

@end
