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
@class CHDMessage;


@interface CHDDashboardMessagesViewModel : NSObject <CHDMessagesViewModelProtocol>

// Subscribe to the isEditing, and filter, to eg. avoid reload of messages while animating tableViews
@property (nonatomic, assign) BOOL isEditingMessages;
@property (nonatomic, readonly) BOOL canFetchNewMessages;
@property (nonatomic, readonly) NSArray *messages;
@property (nonatomic, readonly) CHDEnvironment *environment;
@property (nonatomic, readonly) CHDUser* user;

@property (nonatomic, readonly) RACCommand *getMessagesCommand;

- (NSString*) authorNameWithId: (NSNumber*) authorId authorSiteId: (NSString*) siteId;

- (RACSignal*) setMessageAsRead: (CHDMessage*) message;
- (void) fetchMoreMessages;
- (void) fetchMoreMessagesFromDate: (NSDate*) date;

- (instancetype)initWithUnreadOnly: (BOOL) unreadOnly;
- (BOOL) removeMessageWithIndex: (NSUInteger) idx;

-(void) reloadUnread;
-(void) reloadAll;
@end
