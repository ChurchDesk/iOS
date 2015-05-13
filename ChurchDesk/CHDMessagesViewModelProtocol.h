//
//  CHDMessagesViewModelProtocol.h
//  ChurchDesk
//
//  Created by Jakob Vinther-Larsen on 25/02/15.
//  Copyright (c) 2015 Shape A/S. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol CHDMessagesViewModelProtocol <NSObject>

@property (nonatomic, readonly) NSArray *messages;

- (NSString*) authorNameWithId: (NSNumber*) authorId authorSiteId: (NSString *) siteId;

@end
