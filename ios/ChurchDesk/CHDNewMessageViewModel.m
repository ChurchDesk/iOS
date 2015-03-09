//
// Created by Jakob Vinther-Larsen on 03/03/15.
// Copyright (c) 2015 Shape A/S. All rights reserved.
//

#import "CHDNewMessageViewModel.h"
#import "CHDAPIClient.h"
#import "CHDListSelectorConfigModel.h"
#import "CHDUser.h"
#import "CHDAPICreate.h"

static NSString* kDefaultsSiteIdLastUsed = @"messageSiteIdLastUsed";
static NSString* kDefaultsGroupIdLastUsed = @"messageGroupIdLastUsed";

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

        [self shprac_liftSelector:@selector(selectableGroupsMake) withSignal:[RACSignal merge:@[RACObserve(self, environment), RACObserve(self, selectedSite)]]];

        [self rac_liftSelector:@selector(selectableSitesMake:) withSignals:RACObserve(self, user), nil];

        RAC(self, selectedParishName) = [RACObserve(self, selectedSite) map:^id(CHDSite * site) {
            if(site){
                return site.name;
            }
            return @"";
        }];

        RAC(self, selectedGroupName) = [RACObserve(self, selectedGroup) map:^id(CHDGroup * group) {
            if(group){
                return group.name;
            }
            return @"";
        }];
    }
    return self;
}

-(void) selectableGroupsMake {
    if(self.environment != nil) {
        NSMutableArray *groups = [[NSMutableArray alloc] init];

        CHDGroup *selectedGroup = self.selectedGroup;
        __block CHDGroup *newSelectedGroup = nil;

        NSNumber *lastUsedId = nil;

        if(selectedGroup == nil){
            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
            lastUsedId = [[NSNumber alloc] initWithInteger: [defaults integerForKey:kDefaultsGroupIdLastUsed]];
        }

        NSArray *filteredGroups = @[];

        if(self.selectedSite) {
            filteredGroups = [self.environment groupsWithSiteId:self.selectedSite.siteId];
        }else{
            filteredGroups = self.environment.groups;
        }

        [filteredGroups enumerateObjectsUsingBlock:^(CHDGroup *group, NSUInteger idx, BOOL *stop) {
            BOOL groupIsSelected = group.groupId == selectedGroup.groupId || group.groupId == lastUsedId;
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

-(void) selectableSitesMake: (CHDUser*)user {
    if(user != nil){
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        NSString* lastUsedId = [defaults stringForKey:kDefaultsSiteIdLastUsed];

        NSMutableArray *sites = [[NSMutableArray alloc] init];
        [user.sites enumerateObjectsUsingBlock:^(CHDSite * site, NSUInteger idx, BOOL *stop) {
            if(lastUsedId != nil && [site.siteId isEqualToString:lastUsedId]){
                self.selectedSite = site;
            }
            CHDListSelectorConfigModel *selectable = [[CHDListSelectorConfigModel new] initWithTitle:site.name color:nil selected:(lastUsedId != nil && [site.siteId isEqualToString:lastUsedId]) refObject:site];
            [sites addObject:selectable];
        }];
        self.selectableSites = [sites copy];
    }
}

-(void) storeDefaults {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if(self.selectedSite){
        [defaults setObject:self.selectedSite.siteId forKey:kDefaultsSiteIdLastUsed];
    }

    if(self.selectedGroup){
        [defaults setObject:self.selectedGroup.groupId forKey:kDefaultsGroupIdLastUsed];
    }
}

- (void)sendMessage {
    if(!self.canSendMessage){return;}
    [self storeDefaults];
    RAC(self, createMessageAPIResponse) = [[CHDAPIClient sharedInstance] createMessageWithTitle:self.title message:self.message siteId:self.selectedSite.siteId groupId:self.selectedGroup.groupId];
}


@end