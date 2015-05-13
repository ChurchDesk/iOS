//
// Created by Jakob Vinther-Larsen on 23/03/15.
// Copyright (c) 2015 Shape A/S. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, CHDEventAlertStatus) {
    CHDEventAlertStatusNone,
    CHDEventAlertStatusAllowDoubleBooking,
    CHDEventAlertStatusCancel,
};

@interface CHDEventAlertView : UIView
@property (nonatomic, readonly) CHDEventAlertStatus status;
@property (nonatomic, readonly) BOOL isShown;
@property (nonatomic, assign) BOOL show;

-(instancetype) initWithHtml: (NSString*) htmlError;
-(void) showAlertView;
-(void) hideAlertView;
@end