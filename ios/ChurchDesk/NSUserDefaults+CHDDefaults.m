//
// Created by Jakob Vinther-Larsen on 27/03/15.
// Copyright (c) 2015 Shape A/S. All rights reserved.
//

#import "NSUserDefaults+CHDDefaults.h"

NSString *const kDefaultsLastUsedSiteId = @"lastUsedSiteId";
NSString *const kDefaultsLastUsedGroupId = @"lastUsedGroupId";

@implementation NSUserDefaults (CHDDefaults)

- (void)chdSetDefaultSiteId:(NSString *)siteId {
    [self setObject:siteId forKey:kDefaultsLastUsedSiteId];
}

- (void)chdSetDefaultGroupId:(NSNumber *)groupId {
    [self setObject:groupId forKey:kDefaultsLastUsedGroupId];
}

- (NSString *)chdDefaultSiteId {
    return [self stringForKey:kDefaultsLastUsedSiteId];
}

- (NSNumber *)chdDefaultGroupId {
    return [[NSNumber alloc] initWithInteger: [self integerForKey:kDefaultsLastUsedGroupId]];
}

- (void)chdClearDefaults {
    [self removeObjectForKey:kDefaultsLastUsedSiteId];
    [self removeObjectForKey:kDefaultsLastUsedGroupId];
}
@end