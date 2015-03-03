//
// Created by Jakob Vinther-Larsen on 03/03/15.
// Copyright (c) 2015 Shape A/S. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface CHDListSelectorConfigModel : NSObject
@property (nonatomic) BOOL selected;
@property (nonatomic, assign) UIColor* dotColor;
@property (nonatomic, assign) NSString* title;
@property (nonatomic, assign) id refObject;
-(instancetype)initWithTitle: (NSString*) title color: (UIColor*) color selected: (BOOL) selected refObject: (id) object;
@end