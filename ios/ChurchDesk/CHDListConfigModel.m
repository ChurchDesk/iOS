//
// Created by Jakob Vinther-Larsen on 03/03/15.
// Copyright (c) 2015 Shape A/S. All rights reserved.
//

#import "CHDListConfigModel.h"


@implementation CHDListConfigModel
-(instancetype)initWithTitle: (NSString*) title color: (UIColor*) color{
    if( (self = [super init])){
        self.dotColor = color;
        self.title = title;
    }
    return self;
}

@end