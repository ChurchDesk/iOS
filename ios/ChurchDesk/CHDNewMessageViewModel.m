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

        [self rac_liftSelector:@selector(selectableSitesMake:) withSignals:RACObserve(self, user), nil];
    }
    return self;
}

-(void) selectableGroupsMake: (CHDEnvironment*)environment {
    if(environment != nil) {
        NSMutableArray *groups = [[NSMutableArray alloc] init];
        [environment.groups enumerateObjectsUsingBlock:^(CHDGroup *group, NSUInteger idx, BOOL *stop) {
            CHDListSelectorConfigModel *selectable = [[CHDListSelectorConfigModel new] initWithTitle:group.name color:nil selected:NO refObject:group];
            [groups addObject:selectable];
        }];
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
        return NSLocalizedString(@"Last used", @"");
    }
    return self.selectedSite.name;
}

-(NSString*) selectedGroupName {
    if(!self.selectedGroup){
        return NSLocalizedString(@"Last used", @"");
    }
    return self.selectedGroup.name;
}

- (void)sendMessage {
    if(!self.canSendMessage){return;}
    RAC(self, createMessageAPIResponse) = [[CHDAPIClient sharedInstance] createMessageWithTitle:self.title message:self.message siteId:self.selectedSite.siteId groupId:self.selectedGroup.groupId];
}


@end