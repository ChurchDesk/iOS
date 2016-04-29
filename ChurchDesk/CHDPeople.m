//
//  CHDPeople.m
//  ChurchDesk
//
//  Created by Chirag Sharma on 01/04/16.
//  Copyright © 2016 Shape A/S. All rights reserved.
//

#import "CHDPeople.h"
#import "CHDSegment.h"

@implementation CHDPeople

- (Class)nestedClassForArrayPropertyWithName:(NSString *)propName {
    if([propName isEqualToString:@"segment"]){
        return [CHDSegment class];
    }
    
    return [super nestedClassForArrayPropertyWithName:propName];
}

- (NSString *)mapPropertyForPropertyWithName:(NSString *)propName {
    if ([propName isEqualToString:@"peopleId"]) {
        return @"id";
    }
    return [super mapPropertyForPropertyWithName:propName];
}
@end
