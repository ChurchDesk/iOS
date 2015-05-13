//
//  CHDGroup.h
//  ChurchDesk
//
//  Created by Mikkel Selsøe Sørensen on 26/02/15.
//  Copyright (c) 2015 Shape A/S. All rights reserved.
//

#import "CHDManagedModel.h"

@interface CHDGroup : CHDManagedModel

@property (nonatomic, strong) NSNumber *groupId;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *siteId;
@property (nonatomic, assign) BOOL canCreateEvent;

@end
