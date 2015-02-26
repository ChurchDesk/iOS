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
