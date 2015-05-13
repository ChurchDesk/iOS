//
//  CHDAPICreate.m
//  ChurchDesk
//
//  Created by Jakob Vinther-Larsen on 09/03/15.
//  Copyright (c) 2015 Shape A/S. All rights reserved.
//

#import "CHDAPICreate.h"

@implementation CHDAPICreate
- (NSString *)mapPropertyForPropertyWithName:(NSString *)propName {
    if([propName isEqualToString:@"createId"]){
        return @"id";
    }
    if([propName isEqualToString:@"siteId"]){
        return @"site";
    }
    
    return [super mapPropertyForPropertyWithName:propName];
}
@end
