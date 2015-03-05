//
// Created by Jakob Vinther-Larsen on 04/03/15.
// Copyright (c) 2015 Shape A/S. All rights reserved.
//

#import <Foundation/Foundation.h>

@class CHDMessage;
@class CHDEnvironment;
@class CHDComment;

@interface CHDMessageViewModel : NSObject
- (instancetype)initWithMessageId: (NSNumber*)messageId site: (NSString*) site;

@property (nonatomic, assign) BOOL hasMessage;
@property (nonatomic, assign) BOOL showAllComments;
@property (nonatomic, readonly) CHDComment *latestComment;
@property (nonatomic, readonly) NSArray *allComments;
@property (nonatomic, readonly) NSInteger commentCount;
@property (nonatomic, strong) CHDMessage *message;
@property (nonatomic, strong) CHDEnvironment *environment;

@end