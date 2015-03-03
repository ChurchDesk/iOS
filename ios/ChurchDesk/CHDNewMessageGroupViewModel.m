//
// Created by Jakob Vinther-Larsen on 03/03/15.
// Copyright (c) 2015 Shape A/S. All rights reserved.
//

#import "CHDNewMessageGroupViewModel.h"

@interface CHDNewMessageGroupViewModel()
@property (nonatomic, strong) CHDGroup *group;
@end

@implementation CHDNewMessageGroupViewModel


- (UIColor *)dotColor {
    return nil;
}

- (NSString *)title {
    return self.group.name;
}

-(instancetype)initWithGroup: (CHDGroup*) group {
    if( (self = [super init])){
        self.group = group;
    }
    return self;
}

@end