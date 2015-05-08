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
        return @"created";
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
        return @"eventCategories";
    }
    if ([propName isEqualToString:@"pictureURL"]) {
        return @"picture";
    }
    if([propName isEqualToString:@"siteId"]) {
        return @"site";
    }
    return [super mapPropertyForPropertyWithName:propName];
}

- (id)transformedValueForPropertyWithName:(NSString *)propName value:(id)value {
    if ([propName isEqualToString:@"pictureURL"]) {
        return [NSURL URLWithString:value];
    }
    if ([propName isEqualToString:@"visibility"]) {
        return [value integerValue] == 2 ? @(CHDEventVisibilityOnlyInGroup) : @(CHDEventVisibilityPublicOnWebsite);
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
    }
    return @"";
}

- (NSDictionary*) dictionaryRepresentation {
    NSMutableDictionary *mDict = [NSMutableDictionary new];
    if (self.siteId) {
        mDict[@"site"] = self.siteId;
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
    if (self.contributor) {
        mDict[@"person"] = self.contributor;
    }
    if (self.eventCategoryIds) {
        mDict[@"eventCategories"] = self.eventCategoryIds;
    }
    if (self.internalNote) {
        mDict[@"internalNote"] = self.internalNote;
    }
    if (self.eventDescription) {
        mDict[@"description"] = self.eventDescription;
    }
    if(self.visibility){
        mDict[@"visibility"] = @(self.visibility);
    }

    mDict[@"allowDoubleBooking"] = @(self.allowDoubleBooking);
    mDict[@"publish"] = @(YES);
    mDict[@"allDay"] = @(self.allDayEvent);
    
    return [mDict copy];
}

- (CHDEventResponse) attendanceStatusForUserWithId: (NSNumber*) userId {
    if (!userId) {
        return CHDEventResponseNone;
    }
    for (NSDictionary *dict in self.attendenceStatus) {
        if ([dict[@"user"] isEqualToNumber:userId]) {
            return [dict[@"status"] unsignedIntegerValue];
        }
    }
    return CHDEventResponseNone;
}

- (BOOL)eventForUserWithId:(NSNumber *)userId {
    __block BOOL foundUser = NO;
    [self.userIds enumerateObjectsUsingBlock:^(NSNumber *eventUserId, NSUInteger idx, BOOL *stop) {
        if([eventUserId isEqualToNumber:userId]){
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
