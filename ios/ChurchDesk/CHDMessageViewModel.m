//
// Created by Jakob Vinther-Larsen on 04/03/15.
// Copyright (c) 2015 Shape A/S. All rights reserved.
//

#import "CHDMessageViewModel.h"
#import "CHDAPIClient.h"
#import "CHDEnvironment.h"
#import "CHDMessage.h"
#import "CHDComment.h"


@implementation CHDMessageViewModel

- (instancetype)initWithMessageId: (NSNumber*)messageId site: (NSString*) site {
    self = [super init];
    if (self) {

        self.showAllComments = NO;

        RACSignal *messageSignal = [[[CHDAPIClient sharedInstance] retrieveMessageWithId:messageId site:site] catch:^RACSignal *(NSError *error) {
                    return [RACSignal empty];
                }];

        RAC(self, environment) = [[[CHDAPIClient sharedInstance] getEnvironment] catch:^RACSignal *(NSError *error) {
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
    }
    return self;
}

@end