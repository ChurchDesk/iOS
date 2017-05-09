//
// Created by Jakob Vinther-Larsen on 17/03/15.
// Copyright (c) 2015 Shape A/S. All rights reserved.
//

#import <Foundation/Foundation.h>

@class CHDNotificationSettings;

@interface CHDSettingsViewModel : NSObject
@property (nonatomic, readonly) CHDNotificationSettings *notificationSettings;
-(RACSignal*) saveSettings;
-(void)setTouchIdDisabled :(BOOL)disabled;
@end
