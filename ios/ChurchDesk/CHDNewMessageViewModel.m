//
// Created by Jakob Vinther-Larsen on 03/03/15.
// Copyright (c) 2015 Shape A/S. All rights reserved.
//

#import "CHDNewMessageViewModel.h"
#import "CHDAPIClient.h"
#import "CHDListSelectorConfigModel.h"
#import "CHDUser.h"
#import "CHDAPICreate.h"

@interface CHDNewMessageViewModel()
@property (nonatomic, assign) CHDEnvironment *environment;

@property (nonatomic) BOOL canSendMessage;

@property (nonatomic, strong) NSArray* selectableGroups;
@property (nonatomic, strong) NSString* selectedGroupName;

@property (nonatomic, strong) NSArray* selectableSites;
@property (nonatomic, strong) NSString* selectedParishName;

@property (nonatomic, assign) CHDUser *user;

@property (nonatomic, strong) CHDAPICreate *createMessageAPIResponse;
@end
@implementation CHDNewMessageViewModel

- (instancetype)init {
    self = [super init];
    if (self) {
        RAC(self, environment) = [[[CHDAPIClient sharedInstance] getEnvironment] catch:^RACSignal *(NSError *error) {
            return [RACSignal empty];
        }];

        RAC(self, user) = [[[CHDAPIClient sharedInstance] getCurrentUser] catch:^RACSignal *(NSError *error) {
            return [RACSignal empty];
        }];

        RAC(self, canSendMessage) = [RACSignal combineLatest:@[RACObserve(self, selectedGroup), RACObserve(self, selectedSite), RACObserve(self, message), RACObserve(self, title)]
                          reduce:^(CHDGroup *group, CHDSite *site, NSString *message, NSString *title){
                              BOOL validTitle = !([title isEqualToString:@""]);
                              BOOL validMessage = !([message isEqualToString:@""]);
                              BOOL validGroup = group != nil;
                              BOOL validSite = site != nil;
                              return @(validTitle && validMessage && validGroup && validSite);

        }];

        [self rac_liftSelector:@selector(selectableGroupsMake:) withSignals:RACObserve(self, environment), nil];
        [self shprac_liftSelector:@selector(didChangeSelectedSite) withSignal:RACObserve(self, selectedSite)];
        [self rac_liftSelector:@selector(selectableSitesMake:) withSignals:RACObserve(self, user), nil];
    }
    return self;
}

-(void) didChangeSelectedSite {
    NSMutableArray *groups = [[NSMutableArray alloc] init];

    if(self.selectedSite) {
        NSArray *filteredGroups = [self.environment groupsWithSiteId:self.selectedSite.siteId];

        CHDGroup *selectedGroup = self.selectedGroup;
        __block CHDGroup *newSelectedGroup = nil;
        
        [filteredGroups enumerateObjectsUsingBlock:^(CHDGroup *group, NSUInteger idx, BOOL *stop) {
            BOOL groupIsSelected = group.groupId == selectedGroup.groupId;
            CHDListSelectorConfigModel *selectable = [[CHDListSelectorConfigModel new] initWithTitle:group.name color:nil selected:groupIsSelected refObject:group];
            [groups addObject:selectable];

            if(groupIsSelected){
                newSelectedGroup = group;
            }
        }];

        self.selectedGroup = newSelectedGroup;

        self.selectableGroups = [groups copy];
    }
}

-(void) selectableGroupsMake: (CHDEnvironment*)environment {
    if(environment != nil) {
        NSMutableArray *groups = [[NSMutableArray alloc] init];

        if(self.selectedSite){
            NSArray *filteredGroups = [environment groupsWithSiteId:self.selectedSite.siteId];

            [filteredGroups enumerateObjectsUsingBlock:^(CHDGroup *group, NSUInteger idx, BOOL *stop) {
                CHDListSelectorConfigModel *selectable = [[CHDListSelectorConfigModel new] initWithTitle:group.name color:nil selected:NO refObject:group];
                [groups addObject:selectable];
            }];
        }else{
            [environment.groups enumerateObjectsUsingBlock:^(CHDGroup *group, NSUInteger idx, BOOL *stop) {
                CHDListSelectorConfigModel *selectable = [[CHDListSelectorConfigModel new] initWithTitle:group.name color:nil selected:NO refObject:group];
                [groups addObject:selectable];
            }];
        }

        self.selectableGroups = [groups copy];
    }
}

-(void) selectableSitesMake: (CHDUser*)user {
    if(user != nil){
        NSMutableArray *sites = [[NSMutableArray alloc] init];
        [user.sites enumerateObjectsUsingBlock:^(CHDSite * site, NSUInteger idx, BOOL *stop) {
            CHDListSelectorConfigModel *selectable = [[CHDListSelectorConfigModel new] initWithTitle:site.name color:nil selected:NO refObject:site];
            [sites addObject:selectable];
        }];
        self.selectableSites = [sites copy];
    }
}

-(NSString*) selectedParishName{
    if(!self.selectedSite){
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        return @"";
    }
    return self.selectedSite.name;
}

-(NSString*) selectedGroupName {
    if(!self.selectedGroup){
        return @"";
    }
    return self.selectedGroup.name;
}

- (void)sendMessage {
    if(!self.canSendMessage){return;}
    RAC(self, createMessageAPIResponse) = [[CHDAPIClient sharedInstance] createMessageWithTitle:self.title message:self.message siteId:self.selectedSite.siteId groupId:self.selectedGroup.groupId];
}


@end