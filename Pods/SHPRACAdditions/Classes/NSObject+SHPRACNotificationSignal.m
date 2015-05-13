//
// Created by Mikkel Gravgaard Nielsen on 21/01/14.
// Copyright (c) 2014 Betafunk. All rights reserved.
//

#import "NSObject+SHPRACNotificationSignal.h"
#import "ReactiveCocoa.h"

@implementation NSObject (SHPRACNotificationSignal)

- (RACSignal *)shprac_notifyUntilDealloc:(NSString *)notificationName {
    return [self shprac_notifyUntilDealloc:notificationName object:nil];
}

- (RACSignal *)shprac_notifyUntilDealloc:(NSString *)notificationName object: (id) notificationObject {
    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
    return [[notificationCenter rac_addObserverForName:notificationName object:notificationObject] takeUntil:[self rac_willDeallocSignal]];
}

@end