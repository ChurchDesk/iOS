//
// Created by philip on 08/12/14.
//
// Copyright SHAPE A/S
//

#import <Foundation/Foundation.h>

#define ANALYTICS_CATEGORY_NEW_MESSAGE @"new_message"
#define ANALYTICS_CATEGORY_MESSAGES @"messages"
#define ANALYTICS_CATEGORY_NEW_EVENT @"new_event"
#define ANALYTICS_CATEGORY_EDIT_EVENT @"edit_event"
#define ANALYTICS_CATEGORY_CALENDAR @"calendar"
#define ANALYTICS_CATEGORY_SETTINGS @"settings"
#define ANALYTICS_CATEGORY_SIGNIN @"sign_in"
#define ANALYTICS_CATEGORY_MAINMENU @"mainmenu_navigation"

// Navigation
#define ANALYTICS_ACTION_NAVIGATE_DASHBOARD_EVENTS @"dashboard_events"
#define ANALYTICS_ACTION_NAVIGATE_DASHBOARD_INVITATIONS @"dashboard_invitations"
#define ANALYTICS_ACTION_NAVIGATE_DASHBOARD_MESSAGES @"dashboard_messages"
#define ANALYTICS_ACTION_NAVIGATE_MESSAGES @"messages"
#define ANALYTICS_ACTION_NAVIGATE_MESSAGES_SEARCH @"messages_search"
#define ANALYTICS_ACTION_NAVIGATE_CALENDAR @"calendar"
#define ANALYTICS_ACTION_NAVIGATE_SETTINGS @"settings"

// Actions
#define ANALYTICS_ACTION_BUTTON @"button_touch"
#define ANALYTICS_ACTION_FILTER @"set_filter"

// Labels
#define ANALYTICS_LABEL_CREATE @"create"
#define ANALYTICS_LABEL_CANCEL @"cancel"
#define ANALYTICS_LABEL_UNREAD @"unread"
#define ANALYTICS_LABEL_ALL @"all"
#define ANALYTICS_LABEL_MYEVENTS @"my_events"
#define ANALYTICS_LABEL_SIGNUOUT @"signout"
#define ANALYTICS_LABEL_LOGIN @"login"
#define ANALYTICS_LABEL_FORGOT_PASSWORD @"forgot_password"

@interface CHDAnalyticsManager: NSObject


+ (CHDAnalyticsManager *)sharedInstance;

- (void)startGoogleAnalytics;
- (void)trackVisitToScreen:(NSString *)screenName;
- (void)trackEventWithCategory:(NSString *)category action:(NSString *)action label:(NSString *)label;
- (void)trackTimingWithCategory:(NSString *)category name:(id)name label:(NSString *)label block:(void (^)())block;
- (void)trackTimedEventWithCategory:(NSString *)category name:(NSString *)name label:(NSString *)label interval:(NSUInteger)executionTimeInMs;

@end
