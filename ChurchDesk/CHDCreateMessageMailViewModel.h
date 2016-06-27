//
//  CHDCreateMessageMailViewModel.h
//  ChurchDesk
//
//  Created by Chirag Sharma on 07/04/16.
//  Copyright © 2016 Shape A/S. All rights reserved.
//

#import "CHDManagedModel.h"

@interface CHDCreateMessageMailViewModel : CHDManagedModel

- (instancetype)initAsSMSorEmail :(BOOL)isSMS;

@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *message;
@property (nonatomic, readonly) BOOL canSendMessage;
@property (nonatomic, strong) NSArray *selectedPeople;
@property (nonatomic, strong) NSString *from;
@property (nonatomic, strong) NSString *organizationId;
@property (nonatomic, strong) NSString *textLimit;
@property (nonatomic, readonly) RACCommand *saveCommand;
@property (nonatomic, assign) BOOL isSMS;

- (RACSignal*) sendMessage :(BOOL)isSegment;
@end
