//
// Created by Jakob Vinther-Larsen on 04/03/15.
// Copyright (c) 2015 Shape A/S. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CHDMessage.h"

@interface CHDMessageViewModel : NSObject
- (instancetype)initWithMessageId: (NSNumber*)messageId site: (NSString*) site;

@property (nonatomic, assign) BOOL hasMessage;
@property (nonatomic, assign) BOOL showAllComments;
@property (nonatomic, readonly) NSArray *comments;
@property (nonatomic, readonly) NSInteger commentCount;
@property (nonatomic, strong) CHDMessage *message;
@end