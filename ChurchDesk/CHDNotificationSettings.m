//
// Created by Jakob Vinther-Larsen on 17/03/15.
// Copyright (c) 2015 Shape A/S. All rights reserved.
//

#import "CHDNotificationSettings.h"


@implementation CHDNotificationSettings

- (NSString *)mapPropertyForPropertyWithName:(NSString *)propName {
    if([propName isEqualToString:@"bookingUpdated"]){
        return @"bookingUpdatedNotifcation";
    }
    if([propName isEqualToString:@"bookingCanceled"]){
        return @"bookingCanceledNotifcation";
    }
    if([propName isEqualToString:@"bookingCreated"]){
        return @"bookingCreatedNotifcation";
    }
    if([propName isEqualToString:@"message"]){
        return @"groupMessageNotifcation";
    }
    return [super mapPropertyForPropertyWithName:propName];
}

- (id)transformedValueForPropertyWithName:(NSString *)propName value:(id)value {
    if ([propName isEqualToString:@"bookingUpdated"] || [propName isEqualToString:@"bookingCanceled"] || [propName isEqualToString:@"bookingCreated"] || [propName isEqualToString:@"message"]) {
        NSDictionary *tempDict = value;
        return [tempDict objectForKey:@"push"];
        tempDict = nil;
    }
    return [super transformedValueForPropertyWithName:propName value:value];
}

@end