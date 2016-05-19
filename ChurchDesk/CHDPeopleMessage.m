//
//  CHDPeopleMessage.m
//  ChurchDesk
//
//  Created by Chirag Sharma on 15/04/16.
//  Copyright © 2016 Shape A/S. All rights reserved.
//

#import "CHDPeopleMessage.h"
#import "CHDPeople.h"
#import "CHDSegment.h"

@implementation CHDPeopleMessage

- (NSString *)mapPropertyForPropertyWithName:(NSString *)propName {
    return [super mapPropertyForPropertyWithName:propName];
}

- (NSArray*) toArray: (NSArray*) recepientsArray isSegment: (BOOL)isSegment {
    NSMutableArray *resultsArray = [[NSMutableArray alloc] init];
    
    for (int numberOfRecepients = 0; numberOfRecepients < recepientsArray.count ; numberOfRecepients ++) {
        NSMutableDictionary *tempDictionary = [[NSMutableDictionary alloc] init];
        if (isSegment) {
            [tempDictionary setObject:@"segment" forKey:@"group"];
            CHDSegment* segment = [recepientsArray objectAtIndex:numberOfRecepients];
            [tempDictionary setObject:segment.segmentId forKey:@"id"];
        }
        else{
            [tempDictionary setObject:@"people" forKey:@"group"];
            CHDPeople* people = [recepientsArray objectAtIndex:numberOfRecepients];
            [tempDictionary setObject:people.peopleId forKey:@"id"];
        }
        
        [resultsArray addObject:tempDictionary];
        tempDictionary = nil;
    }
    NSLog(@"result array %@", resultsArray);
    return resultsArray;
}

@end
