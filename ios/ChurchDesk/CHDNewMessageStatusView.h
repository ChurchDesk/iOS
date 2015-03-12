//
// Created by Jakob Vinther-Larsen on 11/03/15.
// Copyright (c) 2015 Shape A/S. All rights reserved.
//

#import <Foundation/Foundation.h>

@class CHDAPICreate;


@interface CHDNewMessageStatusView : UIView
@property (nonatomic) BOOL isSending;
@property (nonatomic, strong) CHDAPICreate *apiResponse;
- (instancetype)initWithParentView: (UIView*) parentView;
@end