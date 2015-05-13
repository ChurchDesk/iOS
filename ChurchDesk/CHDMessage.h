//
//  CHDMessage.h
//  ChurchDesk
//
//  Created by Jakob Vinther-Larsen on 24/02/15.
//  Copyright (c) 2015 Shape A/S. All rights reserved.
//

#import "CHDManagedModel.h"


@interface CHDMessage : CHDManagedModel
@property (nonatomic, strong) NSNumber *messageId;

//Site Id is only populated when more than one site is retrieved from the server
@property (nonatomic, strong) NSString *siteId;
@property (nonatomic, strong) NSNumber *authorId;
@property (nonatomic, strong) NSNumber *groupId;
@property (nonatomic, strong) NSDate *changeDate;
@property (nonatomic, strong) NSNumber *lastCommentAuthorId;
@property (nonatomic, strong) NSDate *lastCommentDate;
@property (nonatomic, strong) NSString *title;

// Partly body of the message
@property (nonatomic, strong) NSString *messageLine;

// The complete body of the message
@property (nonatomic, strong) NSString *body;
@property (nonatomic, strong) NSDate *lastActivityDate;
@property (nonatomic, assign) BOOL read;

@property (nonatomic, strong) NSArray *comments;
@end
