//
// Created by Jakob Vinther-Larsen on 04/03/15.
// Copyright (c) 2015 Shape A/S. All rights reserved.
//

#import "CHDMessageViewModel.h"
#import "CHDAPIClient.h"
#import "CHDEnvironment.h"
#import "CHDMessage.h"
#import "CHDComment.h"
#import "CHDUser.h"

@interface CHDMessageViewModel()
@property (nonatomic) BOOL hasMessage;
@property (nonatomic) BOOL canSendComment;

@property (nonatomic, strong) NSArray *latestComments;
@property (nonatomic, strong) NSArray *allComments;

@property (nonatomic) NSInteger notShownCommentCount;

@property (nonatomic) NSInteger commentsShownFromId;

@property (nonatomic, strong) CHDMessage *message;
@property (nonatomic, strong) CHDEnvironment *environment;
@property (nonatomic, strong) CHDUser *user;

@property (nonatomic, strong) RACCommand *saveCommand;
@end

@implementation CHDMessageViewModel

- (instancetype)initWithMessageId:(NSNumber *)messageId siteId: (NSString*)siteId {
    self = [super init];
    if (self) {
        self.showAllComments = NO;

        //Initial message signal
        RACSignal *initialMessageSignal = [[[[CHDAPIClient sharedInstance] getMessageWithId:messageId siteId:siteId] map:^id(CHDMessage *message) {
            return message;
        }] catch:^RACSignal *(NSError *error) {
            return [RACSignal empty];
        }];

        //Update signal
        CHDAPIClient *apiClient = [CHDAPIClient sharedInstance];
        RACSignal *updateSignal = [[apiClient.manager.cache rac_signalForSelector:@selector(invalidateObjectsMatchingRegex:)] filter:^BOOL(RACTuple *tuple) {
            NSString *regex = tuple.first;
            NSString *resourcePath = [apiClient resourcePathForGetMessageWithId:messageId];
            return [regex rangeOfString:resourcePath].location != NSNotFound;
        }];

        RACSignal *updateMessageSignal = [updateSignal flattenMap:^RACStream *(id value) {
            return [[[[CHDAPIClient sharedInstance] getMessageWithId:messageId siteId:siteId] map:^id(CHDMessage *message) {
                return message;
            }] catch:^RACSignal *(NSError *error) {
                return [RACSignal empty];
            }];
        }];

        RACSignal *combinedMessageSignal = [[RACSignal merge:@[initialMessageSignal, updateMessageSignal]] filter:^BOOL(CHDMessage *message) {
            return message != nil;
        }];

        RAC(self, environment) = [[[CHDAPIClient sharedInstance] getEnvironment] catch:^RACSignal *(NSError *error) {
            return [RACSignal empty];
        }];

        RAC(self, user) = [[[CHDAPIClient sharedInstance] getCurrentUser] catch:^RACSignal *(NSError *error) {
            return [RACSignal empty];
        }];

        [self rac_liftSelector:@selector(didFetchNewMessage:) withSignals:combinedMessageSignal, nil];

    }
    return self;
}

-(void) didFetchNewMessage: (CHDMessage*) message {
    //Update self.message

    NSArray *latestComments = nil;

    //No message has been set
    if(self.message == nil){
        if(message.comments.count > 0){
            self.commentsShownFromId = [message.comments indexOfObject: message.comments.lastObject];
        }else{
            self.commentsShownFromId = 0;
        }
    }else if( self.showAllComments){
        self.commentsShownFromId = 0;
    }

    if(message.comments.count > 0) {
        NSInteger rangeStart = self.commentsShownFromId;
        NSInteger rangeEnd = [message.comments count] - rangeStart;
        latestComments = [message.comments subarrayWithRange:NSMakeRange(rangeStart, rangeEnd)];
    }else{
        latestComments = @[];
    }

    self.notShownCommentCount =  [message.comments count] - [latestComments count];

    self.latestComments = latestComments;
    self.allComments = [message.comments copy];
    self.hasMessage = message != nil;
    self.message = message;
}

-(RACCommand*)saveCommand {
    if(!_saveCommand){
        _saveCommand = [[RACCommand alloc] initWithSignalBlock:^RACSignal *(RACTuple *tuple) {
            CHDMessage *message = tuple.first;
            CHDComment *comment = tuple.second;

            return [[CHDAPIClient sharedInstance] createCommentForMessageId:message.messageId siteId:message.siteId body:comment.body];
        }];
    }
    return _saveCommand;
}

- (void)sendCommentWithText:(NSString *)body {
    //Assume that the call will go well and add the comment right away
    CHDComment *comment = [CHDComment new];
    comment.body = body;
    comment.authorName = self.user.name;
    comment.createdDate = [NSDate new];

    CHDMessage *message = self.message;
    NSArray *newComments = [message.comments arrayByAddingObject:comment];
    message.comments = [newComments copy];

    [self didFetchNewMessage:message];

    //Send the create comment request
    [self.saveCommand execute:RACTuplePack(self.message, comment)];
}


@end