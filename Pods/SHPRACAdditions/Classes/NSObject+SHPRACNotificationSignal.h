//
// Created by Mikkel Gravgaard Nielsen on 21/01/14.
// Copyright (c) 2014 Betafunk. All rights reserved.
//

#import <Foundation/Foundation.h>

@class RACSignal;

@interface NSObject (SHPRACNotificationSignal)

- (RACSignal *)shprac_notifyUntilDealloc:(NSString *)notificationName;
- (RACSignal *)shprac_notifyUntilDealloc:(NSString *)notificationName object: (id) notificationObject;

@end