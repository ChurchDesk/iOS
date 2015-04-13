//
//  CHDDashboardMessagesViewController.h
//  ChurchDesk
//
//  Created by Jakob Vinther-Larsen on 17/02/15.
//  Copyright (c) 2015 Shape A/S. All rights reserved.
//

#import "CHDAbstractViewController.h"
#import "CHDDashboardTabBarViewController.h"

typedef NS_ENUM(NSUInteger, CHDMessagesStyle) {
    CHDMessagesStyleAllMessages,
    CHDMessagesStyleUnreadMessages,
    CHDMessagesStyleSearch,
};

@interface CHDDashboardMessagesViewController : CHDAbstractViewController <UITableViewDelegate, UITableViewDataSource, CHDNotificationEventResponder>

- (instancetype)initWithStyle: (CHDMessagesStyle) style;

@end
