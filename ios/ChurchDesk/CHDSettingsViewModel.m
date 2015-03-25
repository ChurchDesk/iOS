//
// Created by Jakob Vinther-Larsen on 17/03/15.
// Copyright (c) 2015 Shape A/S. All rights reserved.
//

#import "CHDSettingsViewModel.h"
#import "CHDNotificationSettings.h"
#import "CHDAPIClient.h"

@interface CHDSettingsViewModel()
@property (nonatomic, strong) CHDNotificationSettings *notificationSettings;
@property (nonatomic, strong) RACCommand *saveCommand;
@end

@implementation CHDSettingsViewModel

-(instancetype) init {
    self = [super init];
    if(self){
        RAC(self, notificationSettings) = [[[CHDAPIClient sharedInstance] getNotificationSettings] catch:^RACSignal *(NSError *error) {
            return [RACSignal empty];
        }];
    }
    return self;
}

-(RACSignal*) saveSettings {
    CHDNotificationSettings *settings = self.notificationSettings;
    return [self.saveCommand execute:RACTuplePack(settings)];
}

-(RACCommand*) saveCommand {
    if(!_saveCommand){
        _saveCommand = [[RACCommand alloc] initWithSignalBlock:^RACSignal *(RACTuple *tuple) {
            CHDNotificationSettings *settings = tuple.first;

            return [[CHDAPIClient sharedInstance] updateNotificationSettingsWithSettings:settings];
        }];
    }
    return _saveCommand;
}

@end