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
#import "CHDUser.h"
#import "CHDMessage.h"

@interface CHDDashboardMessagesViewModel ()
@property (nonatomic) BOOL canFetchNewMessages;
@property (nonatomic, strong) NSArray *messages;
@property (nonatomic, strong) CHDEnvironment *environment;
@property (nonatomic, strong) CHDUser* user;

@property (nonatomic) BOOL unreadOnly;

@property (nonatomic, strong) RACCommand *readCommand;
@property (nonatomic, strong) RACCommand *getMessagesCommand;
@end

@implementation CHDDashboardMessagesViewModel

- (instancetype)initWithUnreadOnly: (BOOL) unreadOnly {
    self = [super init];
    if (self) {
        self.unreadOnly = unreadOnly;
        self.canFetchNewMessages = YES;
        if(unreadOnly) {
            //Inital model signal
            RACSignal *initialModelSignal = [[[CHDAPIClient sharedInstance] getUnreadMessages] catch:^RACSignal *(NSError *error) {
                return [RACSignal empty];
            }];

            //Update signal
            CHDAPIClient *apiClient = [CHDAPIClient sharedInstance];
            RACSignal *updateTriggerSignal = [[apiClient.manager.cache rac_signalForSelector:@selector(invalidateObjectsMatchingRegex:)] filter:^BOOL(RACTuple *tuple) {
                NSString *regex = tuple.first;
                NSString *resourcePath = [apiClient resourcePathForGetUnreadMessages];
                return [regex rangeOfString:resourcePath].location != NSNotFound;
            }];

            RACSignal *updateSignal = [updateTriggerSignal flattenMap:^RACStream *(id value) {
                return [[[CHDAPIClient sharedInstance] getUnreadMessages] catch:^RACSignal *(NSError *error) {
                    return [RACSignal empty];
                }];
            }];

            [self rac_liftSelector:@selector(parseMessages:) withSignals:[RACSignal merge:@[initialModelSignal, updateSignal]], nil];
        }else{
            [self fetchMoreMessages];
        }

        RAC(self, user) = [[[CHDAPIClient sharedInstance] getCurrentUser] catch:^RACSignal *(NSError *error) {
            return [RACSignal empty];
        }];

        RAC(self, environment) = [[[CHDAPIClient sharedInstance] getEnvironment] catch:^RACSignal *(NSError *error) {
            return [RACSignal empty];
        }];
    }
    return self;
}

- (BOOL)removeMessageWithIndex:(NSUInteger)idx {
    if(self.messages.count < idx){return NO;}

    NSMutableArray *messages = [[NSMutableArray alloc] initWithArray:self.messages];
    [messages removeObjectAtIndex:idx];

    self.messages = [messages copy];
    return YES;
}


-(RACSignal*) setMessageAsRead:(CHDMessage *)message {
    message.read = YES;
    return [self.readCommand execute:RACTuplePack(message)];
}

-(RACCommand*)readCommand{
    if(!_readCommand){
        _readCommand = [[RACCommand alloc] initWithSignalBlock:^RACSignal *(RACTuple *tuple) {
            CHDMessage *message = tuple.first;

            return [[[CHDAPIClient sharedInstance] setMessageAsRead:message.messageId siteId:message.siteId] catch:^RACSignal *(NSError *error) {
                return [RACSignal empty];
            }];
        }];
    }
    return _readCommand;
}


- (NSString*) authorNameWithId: (NSNumber*) authorId authorSiteId: (NSString*) siteId {
    CHDPeerUser *user = [self.environment userWithId:authorId siteId:siteId];
    return user.name;
}

- (RACCommand*) getMessagesCommand {
    if(!_getMessagesCommand){
        _getMessagesCommand = [[RACCommand alloc] initWithSignalBlock:^RACSignal *(RACTuple *tuple) {
            NSDate *date = tuple.first;

            return [[[CHDAPIClient sharedInstance] getMessagesFromDate:date limit:50] catch:^RACSignal *(NSError *error) {
                return [RACSignal empty];
            }];
        }];
    }
    return _getMessagesCommand;
}

-(void) fetchMoreMessages {
    CHDMessage *message = self.messages.lastObject;
    if(message != nil) {
        [self fetchMoreMessagesFromDate:[message.lastActivityDate dateByAddingTimeInterval:0.01]];
    }else{
        [self fetchMoreMessagesFromDate:[NSDate date]];
    }
}

- (void) fetchMoreMessagesFromDate: (NSDate*) date {
    if(self.unreadOnly || !self.canFetchNewMessages){return;}
    NSLog(@"Fetch messages from %@", date);
    [self rac_liftSelector:@selector(parseMessages:) withSignals:[self.getMessagesCommand execute:RACTuplePack(date)], nil];
}

- (void) parseMessages: (NSArray*) messages {
    NSLog(@"Parsing messages %i", (uint) messages.count);
    self.canFetchNewMessages = messages.count > 0;

    NSArray *sortedMessages = [messages sortedArrayUsingComparator:^NSComparisonResult(CHDMessage *message1, CHDMessage *message2) {
        return [message2.lastActivityDate compare:message1.lastActivityDate];
    }];

    if(self.unreadOnly){
        self.messages = sortedMessages;
        return;
    }

    self.messages = [(self.messages ?: @[]) arrayByAddingObjectsFromArray:sortedMessages];
}

- (void) reloadUnread {
    CHDAPIClient *apiClient = [CHDAPIClient sharedInstance];
    NSString *resoursePath = [apiClient resourcePathForGetUnreadMessages];
    [[[apiClient manager] cache] invalidateObjectsMatchingRegex:resoursePath];
}

-(void) reloadAll {
    CHDAPIClient *apiClient = [CHDAPIClient sharedInstance];
    NSString *resoursePath = [apiClient resourcePathForGetMessagesFromDate];
    [[[apiClient manager] cache] invalidateObjectsMatchingRegex:resoursePath];

    [self rac_liftSelector:@selector(setMessages:) withSignals:[[[self.getMessagesCommand execute:RACTuplePack([NSDate date])] filter:^BOOL(NSArray *messages) {
        return messages.count > 0;
    }] map:^id(NSArray *messages) {
        NSArray *sortedMessages = [messages sortedArrayUsingComparator:^NSComparisonResult(CHDMessage *message1, CHDMessage *message2) {
            return [message2.lastActivityDate compare:message1.lastActivityDate];
        }];
        return sortedMessages;
    }], nil];
}

@end
