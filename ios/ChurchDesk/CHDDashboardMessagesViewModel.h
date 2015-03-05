//
//  CHDDashboardMessagesViewModel.h
//  ChurchDesk
//
//  Created by Jakob Vinther-Larsen on 25/02/15.
//  Copyright (c) 2015 Shape A/S. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CHDMessagesViewModelProtocol.h"

@interface CHDDashboardMessagesViewModel : NSObject <CHDMessagesViewModelProtocol>

@property (nonatomic, readonly) NSArray *messages;

- (NSString*) authorNameWithId: (NSNumber*) authorId;

- (void) fetchMoreMessagesFromDate: (NSDate*) date;

@end
