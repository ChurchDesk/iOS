//
//  CHDPeopleMessage.h
//  ChurchDesk
//
//  Created by Chirag Sharma on 15/04/16.
//  Copyright © 2016 Shape A/S. All rights reserved.
//

#import "CHDManagedModel.h"

@interface CHDPeopleMessage : CHDManagedModel

@property (nonatomic, strong) NSString *organizationId;
@property (nonatomic, strong) NSString *content;
@property (nonatomic, strong) NSString *type;
@property (nonatomic, strong) NSString *from;
@property (nonatomic, strong) NSArray *to;
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *scheduled;
- (NSArray*) toArray: (NSArray*) recepientsArray isSegment: (BOOL)isSegment;
@end
