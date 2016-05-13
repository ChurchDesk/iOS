//
//  CHDCreateMessageMailViewModel.m
//  ChurchDesk
//
//  Created by Chirag Sharma on 07/04/16.
//  Copyright © 2016 Shape A/S. All rights reserved.
//

#import "CHDCreateMessageMailViewModel.h"
#import "NSDateFormatter+ChurchDesk.h"
#import "CHDPeopleMessage.h"
#import "CHDAPIClient.h"


@interface CHDCreateMessageMailViewModel()
@property (nonatomic, strong) RACCommand *saveCommand;
@end
@implementation CHDCreateMessageMailViewModel

- (instancetype)init {
    RAC(self, canSendMessage) = [RACSignal combineLatest:@[RACObserve(self, selectedPeople), RACObserve(self, message), RACObserve(self, title)]
                                                  reduce:^(NSArray *selectedPeople, NSString *message, NSString *title){
                                                      BOOL validTitle = !([title isEqualToString:@""]);
                                                      BOOL validMessage = !([message isEqualToString:@""]);
                                                      
                                                      BOOL validPeople = NO;
                                                      if (selectedPeople.count > 0) {
                                                          validPeople = YES;
                                                      }
                                                      return @(validTitle && validMessage && validPeople);
                                                  }];
    return self;
}

- (RACSignal*)sendMessage {
    if(!self.canSendMessage){return [RACSignal empty];}
    CHDPeopleMessage *message = [CHDPeopleMessage new];
    message.content = self.message;
    message.title = self.title;
    message.organizationId = self.organizationId;
    message.from = self.from;
    message.type = @"email";
    message.to = [message toArray:self.selectedPeople];
    NSDateFormatter *dateFormatter = [NSDateFormatter chd_apiDateFormatter];
    message.scheduled = [dateFormatter stringFromDate:[NSDate date]];
    RACSignal *saveSignal = [self.saveCommand execute:RACTuplePack(message)];
    return saveSignal;
}


-(RACCommand*)saveCommand {
    if(!_saveCommand){
        _saveCommand = [[RACCommand alloc] initWithSignalBlock:^RACSignal *(RACTuple *tuple) {
            CHDPeopleMessage *message = tuple.first;
            
            return [[CHDAPIClient sharedInstance] createPeopleMessageWithTitle:message.title message:message.content organizationId:message.organizationId from:message.from to:message.to type:message.type scheduled:message.scheduled];
        }];
    }
    return _saveCommand;
}


@end
