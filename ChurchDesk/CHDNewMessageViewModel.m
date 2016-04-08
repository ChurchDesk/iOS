//
// Created by Jakob Vinther-Larsen on 03/03/15.
// Copyright (c) 2015 Shape A/S. All rights reserved.
//

#import "CHDNewMessageViewModel.h"
#import "CHDAPIClient.h"
#import "CHDListSelectorConfigModel.h"
#import "CHDUser.h"
#import "CHDAPICreate.h"
#import "CHDSitePermission.h"
#import "NSUserDefaults+CHDDefaults.h"

@interface CHDNewMessageViewModel()
@property (nonatomic, strong) CHDEnvironment *environment;

@property (nonatomic) BOOL canSendMessage;

@property (nonatomic, strong) NSArray* selectableGroups;
@property (nonatomic, strong) NSString* selectedGroupName;
@property (nonatomic, strong) NSNumber *groupIdLastUsed;

@property (nonatomic, strong) NSArray* selectableSites;
@property (nonatomic, strong) NSString* selectedParishName;
@property (nonatomic, strong) NSString *siteIdLastUsed;

@property (nonatomic, assign) CHDUser *user;

@property (nonatomic, strong) RACCommand *saveCommand;
@property (nonatomic) BOOL isSending;

@end
@implementation CHDNewMessageViewModel

- (instancetype)init {
    self = [super init];
    if (self) {
        self.groupIdLastUsed = [[NSUserDefaults standardUserDefaults] chdDefaultGroupId];
        self.siteIdLastUsed = [[NSUserDefaults standardUserDefaults] chdDefaultSiteId];

        RACSignal *getEnvironmentSignal = [[[CHDAPIClient sharedInstance] getEnvironment] catch:^RACSignal *(NSError *error) {
            return [RACSignal empty];
        }];

        //Filter sites so only sites with can create message is shown
        RACSignal *userSignal = [[[[CHDAPIClient sharedInstance] getCurrentUser] catch:^RACSignal *(NSError *error) {
            return [RACSignal empty];
        }] map:^id(CHDUser *user) {
            NSArray *noFilteredSites = [user.sites copy];
            NSMutableArray *filteredSites = [[NSMutableArray alloc] init];

            for(CHDSite *site in noFilteredSites){
                if(site.permissions.canCreateMessage){
                    [filteredSites addObject:site];
                }
            }
            user.sites = filteredSites;
            return user;
        }];

        RAC(self, user) = userSignal;

        RAC(self, environment) = [RACSignal zip:@[getEnvironmentSignal, userSignal] reduce:^id(CHDEnvironment *environment, CHDUser *user) {
            NSArray *sites = user.sites;
            NSArray *nonFilteredGroups = [environment.groups copy];
            NSMutableArray *filteredGroups = [[NSMutableArray alloc] init];

            for(CHDGroup *group in nonFilteredGroups){
                for(CHDSite* site in sites){
                    if([group.siteId isEqualToString:site.siteId]){
                        [filteredGroups addObject:group];
                        break;
                    }
                }
            }
            environment.groups = [filteredGroups copy];
            return environment;
        }];
        
        RAC(self, canSendMessage) = [RACSignal combineLatest:@[RACObserve(self, selectedGroup), RACObserve(self, selectedSite), RACObserve(self, message), RACObserve(self, title)]
                                                      reduce:^(CHDGroup *group, CHDSite *site, NSString *message, NSString *title){
                                                          BOOL validTitle = !([title isEqualToString:@""]);
                                                          BOOL validMessage = !([message isEqualToString:@""]);
                                                          BOOL validGroup = group != nil;
                                                          BOOL validSite = site != nil;
                                                          return @(validTitle && validMessage && validGroup && validSite);
                                                      }];

        [self shprac_liftSelector:@selector(selectableGroupsMake) withSignal:[RACSignal merge:@[[RACSignal zip:@[ [RACObserve(self, environment) ignore:nil], [RACObserve(self, user) ignore:nil] ]], RACObserve(self, selectedSite)]]];

        [self shprac_liftSelector:@selector(selectableSitesMake) withSignal:RACObserve(self, user)];

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

        RAC(self, canSelectGroup) = [RACObserve(self, selectableGroups) map:^id(NSArray *groups) {
            return @(groups.count > 1);
        }];

        RAC(self, canSelectParish) = [RACObserve(self, selectableSites) map:^id(NSArray *users) {
            return @(users.count > 1);
        }];

        [self shprac_liftSelector:@selector(checkSiteForSelectedGroup) withSignal:RACObserve(self, selectedGroup)];
    }
    return self;
}

//Fired when a group is selected
//Checks whether there's already a site selected, if not, a site representing the group is set
//This will allow the user to "just" select the desired group
-(void) checkSiteForSelectedGroup {
    if( !!self.selectedSite || !self.selectedGroup || !self.user || !self.user.sites ){return;}

    NSString *siteId = self.selectedGroup.siteId;
    self.selectedSite = [self.user siteWithId:siteId];
}

#pragma mark - Setup selectable groups/sites

-(void) selectableGroupsMake {
    if(self.environment != nil) {
        NSMutableArray *groups = [[NSMutableArray alloc] init];

        CHDGroup *selectedGroup = self.selectedGroup;
        __block CHDGroup *newSelectedGroup = nil;

        NSNumber *lastUsedId = nil;

        if(selectedGroup == nil){
            lastUsedId = self.groupIdLastUsed;
        }

        NSArray *filteredGroups = nil;

        if(self.selectedSite) {
            filteredGroups = [self.environment groupsWithSiteId:self.selectedSite.siteId groupIds:self.selectedSite.groupIds];
        }else{
            filteredGroups = self.environment.groups;
        }
        
        if(filteredGroups.count == 1){
            self.selectedGroup = filteredGroups[0];
            return;
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

-(void) selectableSitesMake {
    if(self.user != nil){
        //If only a single site is available, skip the selectability
        if(self.user.sites.count == 1){
            self.selectedSite = self.user.sites.firstObject;
            return;
        }

        //set selected site
        if(!self.selectedSite){
            NSString* lastUsedId = self.siteIdLastUsed;
            CHDSite *lastUsed = [self.user siteWithId:lastUsedId];

            if(lastUsed.permissions.canCreateMessage){
                self.selectedSite = lastUsed;
            }else{
                for(CHDSite *site in self.user.sites){
                    if(site.permissions.canCreateMessage){
                        self.selectedSite = site;
                        break;
                    }
                }
            }
        }

        CHDSite *selectedSite = self.selectedSite;

        NSMutableArray *sites = [[NSMutableArray alloc] init];
        [self.user.sites enumerateObjectsUsingBlock:^(CHDSite * site, NSUInteger idx, BOOL *stop) {
            if(site.permissions.canCreateMessage) {
                BOOL siteIsSelected = [selectedSite.siteId isEqualToString:site.siteId];

                CHDListSelectorConfigModel *selectable = [[CHDListSelectorConfigModel new] initWithTitle:site.name color:nil selected:siteIsSelected refObject:site];
                RAC(selectable, selected) = [RACObserve(self, selectedSite) map:^id(CHDSite *observedSite) {
                    return @([observedSite.siteId isEqualToString:site.siteId]);
                }];
                [sites addObject:selectable];
            }
        }];
        self.selectableSites = [sites copy];
    }
}

#pragma mark -

-(void) storeDefaults {
    if(self.selectedSite){
        [[NSUserDefaults standardUserDefaults] chdSetDefaultSiteId:self.selectedSite.siteId];
    }

    if(self.selectedGroup){
        [[NSUserDefaults standardUserDefaults] chdSetDefaultGroupId:self.selectedGroup.groupId];
    }
}

- (RACSignal*)sendMessage {
    if(!self.canSendMessage){return [RACSignal empty];}
    [self storeDefaults];
    self.isSending = YES;
    CHDMessage *message = [CHDMessage new];
    message.body = self.message;
    message.title = self.title;
    message.siteId = self.selectedSite.siteId;
    message.groupId = self.selectedGroup.groupId;

    RACSignal *saveSignal = [self.saveCommand execute:RACTuplePack(message)];
    return saveSignal;
}

-(RACCommand*)saveCommand {
    if(!_saveCommand){
        _saveCommand = [[RACCommand alloc] initWithSignalBlock:^RACSignal *(RACTuple *tuple) {
            CHDMessage *message = tuple.first;

            return [[CHDAPIClient sharedInstance] createMessageWithTitle:message.title message:message.body siteId:message.siteId groupId:message.groupId];
        }];
    }
    return _saveCommand;
}


@end