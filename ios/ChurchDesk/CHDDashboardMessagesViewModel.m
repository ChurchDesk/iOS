//
//  CHDDashboardMessagesViewModel.m
//  ChurchDesk
//
//  Created by Jakob Vinther-Larsen on 25/02/15.
//  Copyright (c) 2015 Shape A/S. All rights reserved.
//

#import "CHDDashboardMessagesViewModel.h"
#import "CHDAPIClient.h"
#import "CHDEnvironment.h"
#import "CHDPeerUser.h"

@interface CHDDashboardMessagesViewModel ()

@property (nonatomic, strong) NSArray *messages;
@property (nonatomic, strong) CHDEnvironment *environment;

@end

@implementation CHDDashboardMessagesViewModel

- (instancetype)init {
    self = [super init];
    if (self) {
//        RAC(self, messages) = [[[CHDAPIClient sharedInstance] getUnreadMessages] catch:^RACSignal *(NSError *error) {
//            return [RACSignal empty];
//        }];
        
        RAC(self, environment) = [[[CHDAPIClient sharedInstance] getEnvironment] catch:^RACSignal *(NSError *error) {
            return [RACSignal empty];
        }];
    }
    return self;
}

- (NSString*) authorNameWithId: (NSNumber*) authorId {
    CHDPeerUser *user = [self.environment userWithId:authorId];
    return user.name;
}

- (void) fetchMoreMessagesFromDate: (NSDate*) date {
    NSLog(@"Fetch messages from %@", date);
    [self rac_liftSelector:@selector(parseMessages:) withSignals:[[CHDAPIClient sharedInstance] getMessagesFromDate:date limit:50], nil];
}

- (void) parseMessages: (NSArray*) messages {
    self.messages = [(self.messages ?: @[]) arrayByAddingObjectsFromArray:messages];
}

@end
