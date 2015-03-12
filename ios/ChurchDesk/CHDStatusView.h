//
// Created by Jakob Vinther-Larsen on 11/03/15.
// Copyright (c) 2015 Shape A/S. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, CHDStatusViewStatus) {
    CHDStatusViewHidden,
    CHDStatusViewProcessing,
    CHDStatusViewError,
    CHDStatusViewSuccess,
};

@interface CHDStatusView : UIView

@property (nonatomic) CHDStatusViewStatus currentStatus;
@property (nonatomic) BOOL show;
@property (nonatomic) NSTimeInterval autoHideOnSuccessAfterTime;
@property (nonatomic) NSTimeInterval autoHideOnErrorAfterTime;

@property (nonatomic, strong) NSString *processingText;
@property (nonatomic, strong) NSString *errorText;
@property (nonatomic, strong) NSString *successText;

- (instancetype)initWithStatus: (CHDStatusViewStatus) status;
@end