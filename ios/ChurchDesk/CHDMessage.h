//
//  CHDMessage.h
//  ChurchDesk
//
//  Created by Jakob Vinther-Larsen on 24/02/15.
//  Copyright (c) 2015 Shape A/S. All rights reserved.
//

#import "CHDManagedModel.h"
/*
 "id": 6,
 "site": "http://vesterbro.kw01.net",
 "authorId": 7,
 "groupId": 5,
 "changed": "2014-08-16T15:52:01+0000",
 "lastCommentAuthorId": 7,
 "lastCommentDate": "2014-08-15T15:52:01+0000",
 "title": "Christams dinner",
 "message_line": "you are all invited to dinner at Jens's place",
 "last_activity": "2014-08-16T15:52:01+0000",
 "read": false
 */
@interface CHDMessage : CHDManagedModel
@property (nonatomic, strong) NSNumber *messageId;
@property (nonatomic, strong) NSString *site;
@property (nonatomic, strong) NSNumber *authorId;
@property (nonatomic, strong) NSNumber *groupId;
@property (nonatomic, strong) NSDate *changeDate;
@property (nonatomic, strong) NSNumber *lastCommentAuthorId;
@property (nonatomic, strong) NSDate *lastCommentDate;
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *messageLine;
@property (nonatomic, strong) NSDate *lastActivityDate;
@property (nonatomic, assign) BOOL read;
@end
