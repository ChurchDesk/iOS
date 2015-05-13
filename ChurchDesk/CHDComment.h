//
// Created by Jakob Vinther-Larsen on 04/03/15.
// Copyright (c) 2015 Shape A/S. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CHDManagedModel.h"


@interface CHDComment : CHDManagedModel
@property (nonatomic, strong) NSNumber *commentId;
@property (nonatomic, strong) NSNumber *authorId;
@property (nonatomic, strong) NSString *authorName;
@property (nonatomic, strong) NSDate *createdDate;
@property (nonatomic, strong) NSNumber *targetId;
@property (nonatomic, strong) NSString *body;
@property (nonatomic) BOOL canEdit;
@property (nonatomic) BOOL canDelete;
@end