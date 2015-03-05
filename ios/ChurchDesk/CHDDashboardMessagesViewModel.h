//
//  CHDDashboardMessagesViewModel.h
//  ChurchDesk
//
//  Created by Jakob Vinther-Larsen on 25/02/15.
//  Copyright (c) 2015 Shape A/S. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CHDMessagesViewModelProtocol.h"

@class CHDEnvironment;
@class CHDUser;

@interface CHDDashboardMessagesViewModel : NSObject <CHDMessagesViewModelProtocol>

@property (nonatomic, readonly) NSArray *messages;
@property (nonatomic, readonly) CHDEnvironment *environment;
@property (nonatomic, readonly) CHDUser* user;

- (NSString*) authorNameWithId: (NSNumber*) authorId;

- (void) fetchMoreMessagesFromDate: (NSDate*) date;

- (instancetype)initWithUnreadOnly: (BOOL) unreadOnly;

@end
