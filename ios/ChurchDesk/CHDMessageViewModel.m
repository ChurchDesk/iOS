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
@property (nonatomic, strong) RACCommand *markAsReadCommand;
@property (nonatomic, strong) RACCommand *commentDeleteCommand;
@property (nonatomic, strong) RACCommand *commentUpdateCommand;
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
        RACSignal *updateMessageSignal = [[[[CHDAPIClient sharedInstance].manager.cache rac_signalForSelector:@selector(invalidateObjectsMatchingRegex:)] filter:^BOOL(RACTuple *tuple) {
            NSString *regex = tuple.first;
            NSString *resourcePath = [[CHDAPIClient sharedInstance] resourcePathForGetMessageWithId:messageId];
            return [regex rangeOfString:resourcePath].location != NSNotFound;
        }] flattenMap:^RACStream *(id value) {
            return [[[[CHDAPIClient sharedInstance] getMessageWithId:messageId siteId:siteId] map:^id(CHDMessage *message) {
                return message;
            }] catch:^RACSignal *(NSError *error) {
                return [RACSignal empty];
            }];
        }];

        [self rac_liftSelector:@selector(didFetchNewMessage:) withSignals:[[RACSignal merge:@[initialMessageSignal, updateMessageSignal]] filter:^BOOL(CHDMessage *message) {
            NSLog(@"Update message");
            return message != nil;
        }], nil];

        RAC(self, environment) = [[[CHDAPIClient sharedInstance] getEnvironment] catch:^RACSignal *(NSError *error) {
            return [RACSignal empty];
        }];

        RAC(self, user) = [[[CHDAPIClient sharedInstance] getCurrentUser] catch:^RACSignal *(NSError *error) {
            return [RACSignal empty];
        }];
    }
    return self;
}

-(void) didFetchNewMessage: (CHDMessage*) message {
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

    if(message.read == NO){
        [self.markAsReadCommand execute:RACTuplePack(message)];
    }
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

-(RACCommand*)markAsReadCommand {
    if(!_markAsReadCommand){
        _markAsReadCommand = [[RACCommand alloc] initWithSignalBlock:^RACSignal *(RACTuple *tuple) {
            CHDMessage *message = tuple.first;

            return [[CHDAPIClient sharedInstance] setMessageAsRead:message.messageId siteId:message.siteId];
        }];
    }
    return _markAsReadCommand;
}

- (RACSignal*)sendCommentWithText:(NSString *)body {
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
    return [self.saveCommand execute:RACTuplePack(self.message, comment)];
}

-(RACCommand*) commentDeleteCommand {
    if(!_commentDeleteCommand){
        _commentDeleteCommand = [[RACCommand alloc] initWithSignalBlock:^RACSignal *(RACTuple *tuple) {
            CHDComment *comment = tuple.first;
            CHDMessage *message = tuple.second;
            return [[CHDAPIClient sharedInstance] deleteCommentWithId:comment.commentId siteId:message.siteId messageId:message.messageId];
        }];
    }
    return _commentDeleteCommand;
}

-(RACSignal *) commentDeleteWithComment: (CHDComment*) comment {
    return [self.commentDeleteCommand execute:RACTuplePack(comment, self.message)];
}

- (RACCommand *)commentUpdateCommand {
    if(!_commentUpdateCommand){
        _commentUpdateCommand = [[RACCommand alloc] initWithSignalBlock:^RACSignal *(RACTuple *tuple) {
            CHDComment *comment = tuple.first;
            CHDMessage *message = tuple.second;
            return [[CHDAPIClient sharedInstance] updateCommentWithId:comment.commentId body:comment.body siteId:message.siteId messageId:message.messageId];
        }];
    }
    return _commentUpdateCommand;
}

-(RACSignal *) commentUpdateWithComment: (CHDComment*) comment {
    return [self.commentUpdateCommand execute:RACTuplePack(comment, self.message)];
}


@end