//
//  CHDCreateMessageMailViewModel.h
//  ChurchDesk
//
//  Created by Chirag Sharma on 07/04/16.
//  Copyright © 2016 Shape A/S. All rights reserved.
//

#import "CHDManagedModel.h"

@interface CHDCreateMessageMailViewModel : CHDManagedModel
@property (nonatomic, assign) NSString *title;
@property (nonatomic, assign) NSString *message;
@property (nonatomic, readonly) BOOL canSendMessage;
@property (nonatomic, readonly) BOOL canSelectParish;
@property (nonatomic, readonly) BOOL canSelectGroup;
@property (nonatomic, readonly) NSString *selectedParishName;
@property (nonatomic, readonly) NSString *selectedGroupName;
- (RACSignal*) sendMessage;
@end
