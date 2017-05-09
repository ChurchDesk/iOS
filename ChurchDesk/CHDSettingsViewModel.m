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

        [self shprac_liftSelector:@selector(didLoadModel:) withSignal:RACObserve(self, notificationSettings)];
    }
    return self;
}

-(void) didLoadModel: (CHDNotificationSettings*) model {
    if(model) {
        [self shprac_liftSelector:@selector(saveSettings) withSignal:[RACSignal merge:@[RACObserve(self.notificationSettings, bookingCreated), RACObserve(self.notificationSettings, bookingCanceled), RACObserve(self.notificationSettings, bookingUpdated), RACObserve(self.notificationSettings, message)]]];
    }
}

-(void)setTouchIdDisabled :(BOOL)disabled{
    [[NSUserDefaults standardUserDefaults] setBool:!disabled forKey:kloginwithTouchIdDisabled];
}

-(RACSignal*) saveSettings {
    CHDNotificationSettings *settings = self.notificationSettings;
    return [self.saveCommand execute:RACTuplePack(settings)];
}

-(RACCommand*) saveCommand {
    [Heap track:@"Notification settings changed"];
    if(!_saveCommand){
        _saveCommand = [[RACCommand alloc] initWithSignalBlock:^RACSignal *(RACTuple *tuple) {
            CHDNotificationSettings *settings = tuple.first;

            return [[CHDAPIClient sharedInstance] updateNotificationSettingsWithSettings:settings];
        }];
    }
    return _saveCommand;
}

@end
