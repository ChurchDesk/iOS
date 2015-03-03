//
// Created by Jakob Vinther-Larsen on 03/03/15.
// Copyright (c) 2015 Shape A/S. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CHDListSelectableProtocol.h"
#import "CHDGroup.h"

@interface CHDNewMessageGroupViewModel : NSObject <CHDListSelectableProtocol>
@property (nonatomic) BOOL selected;
@property (nonatomic, assign) UIColor* dotColor;
@property (nonatomic, assign) NSString* title;

@property (nonatomic, readonly) CHDGroup* group;

-(instancetype)initWithGroup: (CHDGroup*) group;
@end