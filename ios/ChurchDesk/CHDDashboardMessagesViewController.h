//
//  CHDDashboardMessagesViewController.h
//  ChurchDesk
//
//  Created by Jakob Vinther-Larsen on 17/02/15.
//  Copyright (c) 2015 Shape A/S. All rights reserved.
//

#import "CHDAbstractViewController.h"

typedef NS_ENUM(NSUInteger, CHDMessagesFilterType) {
    CHDMessagesFilterTypeAllMessages,
    CHDMessagesFilterTypeUnreadMessages,
};

@interface CHDDashboardMessagesViewController : CHDAbstractViewController <UITableViewDelegate, UITableViewDataSource>

- (instancetype)initWithFilterType: (CHDMessagesFilterType) filterType;

@end
