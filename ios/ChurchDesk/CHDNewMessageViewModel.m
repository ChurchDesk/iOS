//
// Created by Jakob Vinther-Larsen on 03/03/15.
// Copyright (c) 2015 Shape A/S. All rights reserved.
//

#import "CHDNewMessageViewModel.h"
#import "CHDAPIClient.h"
#import "CHDListSelectorConfigModel.h"
#import "CHDGroup.h"

@interface CHDNewMessageViewModel()
@property (nonatomic, strong) NSArray* selectableGroups;
@end
@implementation CHDNewMessageViewModel

- (instancetype)init {
    self = [super init];
    if (self) {
        RAC(self, environment) = [[[CHDAPIClient sharedInstance] getEnvironment] catch:^RACSignal *(NSError *error) {
            return [RACSignal empty];
        }];

        [self rac_liftSelector:@selector(selectableGroupsMake:) withSignals:RACObserve(self, environment), nil];
    }
    return self;
}

-(void) selectableGroupsMake: (CHDEnvironment*)environment {
    if(environment != nil) {
        NSMutableArray *groups = [[NSMutableArray alloc] init];
        [environment.groups enumerateObjectsUsingBlock:^(CHDGroup *group, NSUInteger idx, BOOL *stop) {
            CHDListSelectorConfigModel *selectable = [[CHDListSelectorConfigModel new] initWithTitle:group.name color:nil selected:(self.message.groupId == group.groupId) refObject:group];
            [groups addObject:selectable];
        }];
        self.selectableGroups = [groups copy];
    }
}

@end