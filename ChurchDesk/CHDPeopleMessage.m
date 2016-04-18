//
//  CHDPeopleMessage.m
//  ChurchDesk
//
//  Created by Chirag Sharma on 15/04/16.
//  Copyright © 2016 Shape A/S. All rights reserved.
//

#import "CHDPeopleMessage.h"
#import "CHDPeople.h"

@implementation CHDPeopleMessage

- (NSString *)mapPropertyForPropertyWithName:(NSString *)propName {
    return [super mapPropertyForPropertyWithName:propName];
}

- (NSArray*) toArray: (NSArray*) recepientsArray {
    NSMutableArray *resultsArray = [[NSMutableArray alloc] init];
    NSMutableDictionary *tempDictionary = [[NSMutableDictionary alloc] init];
    [tempDictionary setObject:@"people" forKey:@"group"];
    for (int numberOfRecepients = 0; numberOfRecepients < recepientsArray.count ; numberOfRecepients ++) {
        CHDPeople* people = [recepientsArray objectAtIndex:numberOfRecepients];
        [tempDictionary setObject:people.peopleId forKey:@"id"];
        [resultsArray addObject:tempDictionary];
    }
    
    return [NSArray arrayWithArray:resultsArray];
}

@end
