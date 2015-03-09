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
#import "CHDAPICreate.h"


@interface CHDMessageViewModel()
@property (nonatomic) BOOL hasMessage;
@property (nonatomic) BOOL canSendComment;
@property (nonatomic, strong) CHDAPICreate *apiResponse;

@property (nonatomic, strong) NSArray *allComments;
@property (nonatomic, strong) CHDComment *latestComment;
@property (nonatomic, strong) CHDMessage *message;
@property (nonatomic, strong) CHDEnvironment *environment;
@property (nonatomic, strong) CHDUser *user;
@property (nonatomic) NSInteger commentCount;
@end

@implementation CHDMessageViewModel

- (instancetype)initWithMessageId:(NSNumber *)messageId siteId: (NSString*)siteId {
    self = [super init];
    if (self) {

        self.showAllComments = NO;

        RACSignal *messageSignal = [[[CHDAPIClient sharedInstance] getMessageWithId:messageId siteId:siteId] catch:^RACSignal *(NSError *error) {
                    return [RACSignal empty];
                }];

        RAC(self, environment) = [[[CHDAPIClient sharedInstance] getEnvironment] catch:^RACSignal *(NSError *error) {
            return [RACSignal empty];
        }];

        RAC(self, user) = [[[CHDAPIClient sharedInstance] getCurrentUser] catch:^RACSignal *(NSError *error) {
            return [RACSignal empty];
        }];
        
        RAC(self, message) = messageSignal;

        RAC(self, hasMessage) = [messageSignal map:^id(CHDMessage *message) {
            return @(message != nil);
        }];

        RAC(self, commentCount) = [messageSignal map:^id(CHDMessage *message) {
            return message != nil? @(message.comments.count) : @(0);
        }];

        RAC(self, latestComment) = [messageSignal map:^id(CHDMessage *message) {
            if (message != nil) {
                NSUInteger commentCount = message.comments.count;
                CHDComment *comment = commentCount > 0 ? message.comments[commentCount - 1] : nil;
                return comment;
            };
            return @[];
        }];

        RAC(self, allComments) = [messageSignal map:^id(CHDMessage *message) {
            if (message != nil) {
                return message.comments;
            };
            return @[];
        }];

        RAC(self, canSendComment) = [RACObserve(self, comment) map:^id(NSString *string) {
            return @(![string isEqualToString:@""]);
        }];

        //[self rac_liftSelector:@selector(didSendComment:) withSignals:RACObserve(self, apiResponse), nil];
    }
    return self;
}

- (void) didSendComment: (CHDAPICreate *) apiResponse {
    if(apiResponse.error){

    }else if(apiResponse.createId){

    }
}

- (void)sendComment {
    if(self.canSendComment){
        NSNumber *messageId = self.message.messageId;
        NSString *siteId = self.message.siteId;
        NSString *comment = self.comment;
        RAC(self, apiResponse) = [[[CHDAPIClient sharedInstance] createCommentForMessageId:messageId siteId:siteId body:comment] catch:^RACSignal *(NSError *error) {
            return [RACSignal empty];
        }];
    }
}


@end