//
//  CHDEvent.m
//  ChurchDesk
//
//  Created by Mikkel Selsøe Sørensen on 26/02/15.
//  Copyright (c) 2015 Shape A/S. All rights reserved.
//

#import "CHDEvent.h"
#import "Autocoding.h"

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
    if ([propName isEqualToString:@"eventResponse"]) {
        return @"attendenceStatus";
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

@end
