//
// Created by Jakob Vinther-Larsen on 04/03/15.
// Copyright (c) 2015 Shape A/S. All rights reserved.
//

#import <Foundation/Foundation.h>

@class CHDMessage;
@class CHDEnvironment;
@class CHDComment;
@class CHDUser;

@interface CHDMessageViewModel : NSObject
- (instancetype)initWithMessageId:(NSNumber *)messageId siteId: (NSString*)siteId;

@property (nonatomic, readonly) BOOL hasMessage;
@property (nonatomic, assign) BOOL showAllComments;
@property (nonatomic, readonly) BOOL canSendComment;

@property (nonatomic, strong) NSString *comment;

@property (nonatomic, readonly) CHDComment *latestComment;
@property (nonatomic, readonly) NSArray *allComments;
@property (nonatomic, readonly) NSInteger commentCount;
@property (nonatomic, readonly) CHDMessage *message;
@property (nonatomic, readonly) CHDEnvironment *environment;
@property (nonatomic, readonly) CHDUser *user;

-(void) sendComment;

@end