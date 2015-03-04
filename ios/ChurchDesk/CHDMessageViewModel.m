//
// Created by Jakob Vinther-Larsen on 04/03/15.
// Copyright (c) 2015 Shape A/S. All rights reserved.
//

#import "CHDMessageViewModel.h"
#import "CHDAPIClient.h"


@implementation CHDMessageViewModel

- (instancetype)initWithMessageId: (NSNumber*)messageId site: (NSString*) site {
    self = [super init];
    if (self) {

        self.showAllComments = NO;

        RACSignal *messageSignal = [[[CHDAPIClient sharedInstance] retrieveMessageWithId:messageId site:site] catch:^RACSignal *(NSError *error) {
                    return [RACSignal empty];
                }];
        
        RAC(self, message) = messageSignal;

        RAC(self, hasMessage) = [messageSignal map:^id(CHDMessage *message) {
            return @(message != nil);
        }];

        RAC(self, commentCount) = [messageSignal map:^id(CHDMessage *message) {
            return message != nil? @(message.comments.count) : @(0);
        }];

        RAC(self, comments) = [[RACSignal combineLatest:@[messageSignal, RACObserve(self, showAllComments)]
                                                 reduce:^(CHDMessage *message, NSNumber *showAll) {
                                                     if (message != nil) {

                                                         if (showAll.boolValue) {
                                                             return message.comments;
                                                         }
                                                         NSUInteger commentCount = message.comments.count;
                                                         NSArray *comments =commentCount > 0 ? @[message.comments[commentCount - 1]] : @[];
                                                         return comments;
                                                     };
                                                     return @[];
                                                 }] catch:^RACSignal *(NSError *error) {
            return [RACSignal empty];
        }];
    }
    return self;
}

@end