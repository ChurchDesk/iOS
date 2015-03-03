//
// Created by Jakob Vinther-Larsen on 03/03/15.
// Copyright (c) 2015 Shape A/S. All rights reserved.
//

#import "CHDNewMessageGroupsViewModel.h"
#import "CHDAPIClient.h"
#import "CHDEnvironment.h"
#import "CHDGroup.h"
#import "CHDNewMessageGroupViewModel.h"

@interface CHDNewMessageGroupsViewModel()
@property (nonatomic, strong) NSArray *groups;
@property (nonatomic, strong) CHDEnvironment *environment;
@end

@implementation CHDNewMessageGroupsViewModel
- (instancetype)init {
    self = [super init];
    if (self) {
        RAC(self, environment) = [[[CHDAPIClient sharedInstance] getEnvironment] catch:^RACSignal *(NSError *error) {
            return [RACSignal empty];
        }];

        [self rac_liftSelector:@selector(selectableGroups:) withSignals:RACObserve(self, environment), nil];
    }
    return self;
}

-(void) selectableGroups: (CHDEnvironment*)environment {
        if(environment != nil) {
            NSMutableArray *groupViewModels = [[NSMutableArray alloc] init];
            [environment.groups enumerateObjectsUsingBlock:^(CHDGroup *group, NSUInteger idx, BOOL *stop) {
                //Pack the group inside a CHDNewMessageGroupViewModel
                CHDNewMessageGroupViewModel *groupViewModel = [[CHDNewMessageGroupViewModel new] initWithGroup:group];
                [groupViewModels addObject:groupViewModel];
            }];
            self.groups = [groupViewModels copy];
        }
}

@end