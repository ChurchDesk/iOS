//
// Created by Jakob Vinther-Larsen on 03/03/15.
// Copyright (c) 2015 Shape A/S. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "CHDListSelectorConfigModel.h"

@protocol CHDListSelectorDelegate <NSObject>
-(void) chdListSelectorDidSelect: (CHDListSelectorConfigModel *) selection;
@end