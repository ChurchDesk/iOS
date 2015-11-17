//
//  CHDEvent.m
//  ChurchDesk
//
//  Created by Mikkel Selsøe Sørensen on 26/02/15.
//  Copyright (c) 2015 Shape A/S. All rights reserved.
//

#import "CHDEvent.h"
#import "Autocoding.h"
#import "NSDateFormatter+ChurchDesk.h"

@interface CHDEvent ()

@property (nonatomic, strong) NSDateFormatter *dateFormatter;

@end

@implementation CHDEvent

- (NSString *)mapPropertyForPropertyWithName:(NSString *)propName {
    if ([propName isEqualToString:@"eventId"]) {
        return @"id";
    }
    if ([propName isEqualToString:@"creationDate"]) {
        return @"createdAt";
    }
    if ([propName isEqualToString:@"allDayEvent"]) {
        return @"allDay";
    }
    if ([propName isEqualToString:@"eventDescription"]) {
        return @"description";
    }
    if ([propName isEqualToString:@"contributor"]) {
        return @"person";
    }
    if ([propName isEqualToString:@"resourceIds"]) {
        return @"resources";
    }
    if ([propName isEqualToString:@"userIds"]) {
        return @"users";
    }
    if ([propName isEqualToString:@"eventCategoryIds"]) {
        return @"taxonomies";
    }
    if ([propName isEqualToString:@"pictureURL"]) {
        return @"picture";
    }
    if([propName isEqualToString:@"siteId"]) {
        return @"organizationId";
    }
    if ([propName isEqualToString:@"attendenceStatus"]) {
        return @"users";
    }
    return [super mapPropertyForPropertyWithName:propName];
}

- (id)transformedValueForPropertyWithName:(NSString *)propName value:(id)value {
    if ([propName isEqualToString:@"pictureURL"]) {
        return [NSURL URLWithString:value];
    }
    if ([propName isEqualToString:@"visibility"]) {
        if ([value isEqualToString:@"group"])
            return @(CHDEventVisibilityOnlyInGroup);
        else if ([value isEqualToString:@"draft"])
            return @(CHDEventVisibilityDraft);
        else
            return @(CHDEventVisibilityPublicOnWebsite);
    }
    if ([propName isEqualToString:@"eventCategoryIds"] || [propName isEqualToString:@"userIds"] || [propName isEqualToString:@"resourceIds"]) {
        NSDictionary *tempDict = value;
        return tempDict.allKeys;
        tempDict = nil;
    }
    if ([propName isEqualToString:@"attendenceStatus"]) {
        NSDictionary *tempDict = value;
        NSMutableArray *attendanceArray = [[NSMutableArray alloc] init];
        for (int i = 0; i < tempDict.allKeys.count; i++) {
            NSString *userId = [tempDict.allKeys objectAtIndex:i];
            NSDictionary *attendanceDict = @{@"user" : userId,
                                             @"status": [[tempDict objectForKey:userId] valueForKey:@"attending"]};
            [attendanceArray addObject:attendanceDict];
        }
        return attendanceArray;
    }
    return [super transformedValueForPropertyWithName:propName value:value];
}

- (NSString *)localizedVisibilityString {
    return [self localizedVisibilityStringForVisibility:self.visibility];
}

- (NSString *)localizedVisibilityStringForVisibility:(CHDEventVisibility) visibility {
    switch (visibility) {
        case CHDEventVisibilityPublicOnWebsite:
            return NSLocalizedString(@"Visible on website", @"");
        case CHDEventVisibilityOnlyInGroup:
            return NSLocalizedString(@"Visible only in group", @"");
        case CHDEventVisibilityDraft:
            return NSLocalizedString(@"Visible only in draft", @"");
    }
    return @"";
}

- (NSDictionary*) dictionaryRepresentation {
    NSMutableDictionary *mDict = [NSMutableDictionary new];
    if (self.siteId) {
        mDict[@"organizationId"] = self.siteId;
    }
    if (self.groupId) {
        mDict[@"groupId"] = self.groupId;
    }
    if (self.title) {
        mDict[@"title"] = self.title;
    }
    if (self.startDate) {
        mDict[@"startDate"] = [self.dateFormatter stringFromDate:self.startDate];
    }
    if (self.endDate) {
        mDict[@"endDate"] = [self.dateFormatter stringFromDate:self.endDate];
    }
    if (self.resourceIds) {
        mDict[@"resources"] = self.resourceIds;
    }
    if (self.userIds) {
        mDict[@"users"] = self.userIds;
    }
    if (self.location) {
        mDict[@"location"] = self.location;
    }
    if (self.price) {
        mDict[@"price"] = self.price;
    }
//    if (self.contributor) {
//        mDict[@"person"] = self.contributor;
//    }
    if (self.eventCategoryIds) {
        mDict[@"taxonomies"] = self.eventCategoryIds;
    }
    if (self.internalNote) {
        mDict[@"internalNote"] = self.internalNote;
    }
    if (self.eventDescription) {
        mDict[@"description"] = self.eventDescription;
    }
    if(self.visibility){
        switch (self.visibility) {
            case CHDEventVisibilityPublicOnWebsite:
                mDict[@"visibility"] = @"web";
                break;
            case CHDEventVisibilityOnlyInGroup:
                mDict[@"visibility"] = @"group";
                break;
            case CHDEventVisibilityDraft:
                mDict[@"visibility"] = @"draft";
                break;
        }
        //@(self.visibility);
    }

    mDict[@"mainCategory"] = self.eventCategoryIds[0];
    mDict[@"allowDoubleBooking"] = @(self.allowDoubleBooking);
    mDict[@"publish"] = @(YES);
    mDict[@"allDay"] = @(self.allDayEvent);
    mDict[@"type"] = @"event";
    return [mDict copy];
}

- (NSString *) attendanceStatusForUserWithId: (NSNumber*) userId {
    if (!userId) {
        return CHDInvitationNoAnswer;
    }
    for (NSDictionary *dict in self.attendenceStatus) {
        NSString *userIdFromDict = dict[@"user"];
        if (userIdFromDict.intValue == userId.intValue) {
            return dict[@"status"];
        }
    }
    return CHDInvitationNoAnswer;
}

- (BOOL)eventForUserWithId:(NSNumber *)userId {
    __block BOOL foundUser = NO;
    [self.userIds enumerateObjectsUsingBlock:^(NSNumber *eventUserId, NSUInteger idx, BOOL *stop) {
        if(eventUserId.integerValue == userId.integerValue){
            foundUser = YES;
        }
    }];
    return foundUser;
}

#pragma mark - NSObject

- (id)copyWithZone:(id)zone
{
    id copy = [[[self class] alloc] init];
    for (NSString *key in [self codableProperties])
    {
        [copy setValue:[self valueForKey:key] forKey:key];
    }
    return copy;
}

- (NSUInteger)hash {
    return self.eventId.hash;
}

- (BOOL)isEqual:(CHDEvent*)object {
    return self.eventId ? [object.eventId isEqualToNumber:self.eventId] : NO;
}

#pragma mark - Lazy Initialization

- (NSDateFormatter *)dateFormatter {
    if (!_dateFormatter) {
        _dateFormatter = [NSDateFormatter chd_apiDateFormatter];
    }
    return _dateFormatter;
}

@end
