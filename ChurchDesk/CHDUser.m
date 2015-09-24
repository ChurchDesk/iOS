//
// Created by Jakob Vinther-Larsen on 03/03/15.
// Copyright (c) 2015 Shape A/S. All rights reserved.
//

#import "CHDUser.h"
#import "CHDSite.h"


@implementation CHDUser

- (Class)nestedClassForArrayPropertyWithName:(NSString *)propName {
    if([propName isEqualToString:@"sites"]){
        return [CHDSite class];
    }

    return [super nestedClassForArrayPropertyWithName:propName];
}

- (NSString *)mapPropertyForPropertyWithName:(NSString *)propName {
    if ([propName isEqualToString:@"pictureURL"]) {
        return @"picture";
    }
    if([propName isEqualToString:@"groupIds"]){
        return @"groups";
    }
    if([propName isEqualToString:@"name"]){
        return @"fullName";
    }
    if([propName isEqualToString:@"sites"]){
        return @"organizations";
    }
    if([propName isEqualToString:@"userId"]){
        return @"id";
    }
    if([propName isEqualToString:@"country"]) {
        return @"locale";
    }
    return [super mapPropertyForPropertyWithName:propName];
}

- (CHDSite*) siteWithId: (NSString*) siteId {
    return siteId ? [self.sites shp_detect:^BOOL(CHDSite *site) {
        return site.siteId.integerValue == siteId.integerValue;
    }] : nil;
}


- (id)transformedValueForPropertyWithName:(NSString *)propName value:(id)value {
    if ([propName isEqualToString:@"pictureURL"]) {
        if ([value objectForKey:@"url"] != [NSNull null]) {
            return [NSURL URLWithString:value];
        }
        else
        return [NSURL URLWithString:@""];
    }
    if ([propName isEqualToString:@"country"]) {
        NSDictionary *tempDict = value;
        //NSLog(@"value returned %@", [tempDict objectForKey:@"country"]);
        [[NSUserDefaults standardUserDefaults] setObject:[tempDict objectForKey:@"country"] forKey:@"country"];
        return [tempDict objectForKey:@"country"];
        tempDict = nil;
    }

    return [super transformedValueForPropertyWithName:propName value:value];
}


@end
