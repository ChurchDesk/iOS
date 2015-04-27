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
#import "CHDAuthenticationManager.h"

@interface CHDDashboardMessagesViewModel ()
@property (nonatomic) BOOL canFetchMoreMessages;
@property (nonatomic, strong) NSArray *messages;
@property (nonatomic, strong) CHDEnvironment *environment;
@property (nonatomic, strong) CHDUser* user;

@property (nonatomic, strong) RACCommand *readCommand;
@property (nonatomic, strong) RACCommand *getMessagesCommand;
@end

@implementation CHDDashboardMessagesViewModel

- (instancetype)initWaitForSearch: (BOOL) waitForSearch {
    _waitForSearch = waitForSearch;
    return [self initWithUnreadOnly:NO];
}

- (instancetype)initWithUnreadOnly: (BOOL) unreadOnly {
    self = [super init];
    if (self) {
        self.unreadOnly = unreadOnly;
        self.canFetchMoreMessages = YES;
        CHDAPIClient *apiClient = [CHDAPIClient sharedInstance];

        [self shprac_liftSelector:@selector(setMessages:) withSignal:[RACObserve(self, unreadOnly) map:^id(id value) {
            return nil;
        }]];

        //Inital model signal
        RACSignal *initialModelSignal = [[RACObserve(self, unreadOnly) filter:^BOOL(NSNumber *iUnreadnly) {
            return iUnreadnly.boolValue;
        }] flattenMap:^RACStream *(id value) {
            return [[apiClient getUnreadMessages] catch:^RACSignal *(NSError *error) {
                return [RACSignal empty];
            }];
        }];

        [self rac_liftSelector:@selector(setCanFetchMoreMessages:) withSignals:[RACObserve(self, unreadOnly) map:^id(id value) {
            return @(YES);
        }], nil];

        //Update signal
        RACSignal *updateSignal = [[[RACObserve(self, unreadOnly) filter:^BOOL(NSNumber *iUnreadnly) {
            return iUnreadnly.boolValue;
        }] flattenMap:^RACStream *(id value) {
            return [[apiClient.manager.cache rac_signalForSelector:@selector(invalidateObjectsMatchingRegex:)] filter:^BOOL(RACTuple *tuple) {
                NSString *regex = tuple.first;
                NSString *resourcePath = [apiClient resourcePathForGetUnreadMessages];
                return [regex rangeOfString:resourcePath].location != NSNotFound;
            }];
        }] flattenMap:^RACStream *(id value) {
            return [[apiClient getUnreadMessages] catch:^RACSignal *(NSError *error) {
                return [RACSignal empty];
            }];
        }];
        
        RACSignal *fetchAllMessagesSignal = [RACObserve(self, unreadOnly) filter:^BOOL(NSNumber *nUnreadOnly) {
            return !nUnreadOnly.boolValue;
        }];
        if (self.waitForSearch) {
            [self rac_liftSelector:@selector(fetchMoreMessagesWithQuery:continuePagination:) withSignals:[fetchAllMessagesSignal flattenMap:^RACStream *(id value) {
                return [RACObserve(self, searchQuery) filter:^BOOL(NSString *searchQuery) {
                    return searchQuery.length > 0;
                }];
            }], [RACSignal return:@NO], nil];
        }
        else {
            [self shprac_liftSelector:@selector(filterChangedToAllMessages) withSignal:fetchAllMessagesSignal];
        }
        
        [self rac_liftSelector:@selector(parseMessages:append:) withSignals:[RACSignal merge:@[initialModelSignal, updateSignal]], [RACSignal return:@NO], nil];

        RACSignal *authenticationTokenSignal = [RACObserve([CHDAuthenticationManager sharedInstance], authenticationToken) ignore:nil];
        
        [self shprac_liftSelector:@selector(setEnvironment:) withSignal:[authenticationTokenSignal flattenMap:^RACStream *(id value) {
            return [[[CHDAPIClient sharedInstance] getEnvironment] catch:^RACSignal *(NSError *error) {
                return [RACSignal empty];
            }];
        }]];
        
        [self shprac_liftSelector:@selector(setUser:) withSignal:[authenticationTokenSignal flattenMap:^RACStream *(id value) {
            return [[[CHDAPIClient sharedInstance] getCurrentUser] catch:^RACSignal *(NSError *error) {
                return [RACSignal empty];
            }];
        }]];

        if(!self.waitForSearch) {
            if (self.unreadOnly) {
                [self shprac_liftSelector:@selector(reloadUnread) withSignal:authenticationTokenSignal];
            } else {
                [self shprac_liftSelector:@selector(reloadAll) withSignal:authenticationTokenSignal];
            }
        }
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
            NSString *query = tuple.second;

            return [[[CHDAPIClient sharedInstance] getMessagesFromDate:date limit:50 query:query] catch:^RACSignal *(NSError *error) {
                return [RACSignal empty];
            }];
        }];
    }
    return _getMessagesCommand;
}

-(void) filterChangedToAllMessages {
    self.canFetchMoreMessages = YES;
    [self fetchMoreMessagesWithQuery:nil continuePagination:NO];
}

- (void) fetchMoreMessages {
    [self fetchMoreMessagesWithQuery:self.searchQuery continuePagination:NO];
}

- (void) fetchMoreMessagesWithQuery: (NSString*) query continuePagination: (BOOL) continuePagination {
    CHDMessage *message = continuePagination ? self.messages.lastObject : nil;
    [self fetchMoreMessagesFromDate: message != nil ? [message.lastActivityDate dateByAddingTimeInterval:-1.0] : [NSDate date] withQuery:query continuePagination:continuePagination];
}

- (void) fetchMoreMessagesFromDate: (NSDate*) date {
    [self fetchMoreMessagesFromDate:date withQuery:nil continuePagination:YES];
}

- (void) fetchMoreMessagesFromDate: (NSDate*) date withQuery: (NSString*) query continuePagination: (BOOL) continuePagination {
    if(self.unreadOnly || !self.canFetchMoreMessages){return;}
    NSLog(@"Fetch messages from %@", date);
    [self rac_liftSelector:@selector(parseMessages:append:) withSignals:[self.getMessagesCommand execute:RACTuplePack(date, query)], [RACSignal return:@(continuePagination)], nil];
}

- (void) parseMessages: (NSArray*) messages append: (BOOL) append {
    NSLog(@"Parsing messages %i", (uint) messages.count);
    //If 0 messages is returned, set the flag to false (to block recursive call for additional messages)
    self.canFetchMoreMessages = messages.count > 0;

    NSArray *sortedMessages = [messages sortedArrayUsingComparator:^NSComparisonResult(CHDMessage *message1, CHDMessage *message2) {
        return [message2.lastActivityDate compare:message1.lastActivityDate];
    }];

    if (self.unreadOnly || !append){
        self.messages = sortedMessages;
    }
    else {
        self.messages = [(self.messages ?: @[]) arrayByAddingObjectsFromArray:sortedMessages];
    }
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
