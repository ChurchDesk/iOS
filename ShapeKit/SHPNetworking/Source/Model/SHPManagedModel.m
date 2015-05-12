//
//  SHPManagedModel.m
//  SHPNetworking
//
//  Created by Kasper Kronborg on 21/11/12.
//  Copyright (c) 2012 SHAPE A/S. All rights reserved.
//

#import "SHPManagedModel.h"
#import "SHPManagedModel+PropertiesDictionary.h"



@implementation SHPManagedModel

- (id)initWithDictionary:(NSDictionary *)dict
{
    if (!(self = [super init])) return nil;
    
    _initializedDictionary = dict;
    
    [self setPropertiesWithDictionary:dict];
    
    return self;
}

@end
