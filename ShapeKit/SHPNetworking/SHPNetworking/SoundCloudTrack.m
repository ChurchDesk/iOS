//
//  SoundCloudTrack.m
//  SHPNetworking
//
//  Created by Kasper Kronborg on 20/11/12.
//  Copyright (c) 2012 SHAPE A/S. All rights reserved.
//

#import "SoundCloudTrack.h"



@implementation SoundCloudTrack

- (NSString *)mapPropertyForPropertyWithName:(NSString *)propName
{
    if ([propName isEqualToString:@"trackId"]) {
        return @"id";
    }
    
    return nil;
}

@end
