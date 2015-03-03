//
// Created by Jakob Vinther-Larsen on 03/03/15.
// Copyright (c) 2015 Shape A/S. All rights reserved.
//

#import "CHDListSelectorConfigModel.h"


@implementation CHDListSelectorConfigModel
-(instancetype)initWithTitle: (NSString*) title color: (UIColor*) color selected: (BOOL) selected refObject: (id) object{
    if( (self = [super init])){
        self.dotColor = color;
        self.title = title;
        self.selected = selected;
        self.refObject = object;
    }
    return self;
}

@end