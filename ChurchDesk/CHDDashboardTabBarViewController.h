//
//  CHDDashboardTabBarViewController.h
//  ChurchDesk
//
//  Created by Jakob Vinther-Larsen on 17/02/15.
//  Copyright (c) 2015 Shape A/S. All rights reserved.
//

#import "CHDAbstractViewController.h"

@protocol CHDNotificationEventResponder <NSObject>

- (BOOL) canHandleEventWithUserInfo: (NSDictionary*) userInfo;
- (void) handleEventWithUserInfo: (NSDictionary*) userInfo;

@end

@interface CHDDashboardTabBarViewController : CHDAbstractViewController
+ (instancetype) dashboardTabBarViewController;

-(instancetype) initWithTabItems: (NSArray*) items;
- (void) notificationsForIndex: (NSUInteger) idx show: (BOOL) show;

- (BOOL) handleNotificationEventWithUserInfo: (NSDictionary*) userInfo;

@end
