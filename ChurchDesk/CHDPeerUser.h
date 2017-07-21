//
//  CHDPeerUser.h
//  ChurchDesk
//
//  Created by Mikkel Selsøe Sørensen on 26/02/15.
//  Copyright (c) 2015 Shape A/S. All rights reserved.
//

#import "CHDManagedModel.h"

@interface CHDPeerUser : CHDManagedModel

@property (nonatomic, strong) NSNumber *userId;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *email;
@property (nonatomic, strong) NSArray *siteIds;
@property (nonatomic, strong) NSURL *pictureURL;
@property (nonatomic, strong) NSArray *groupIds;

@end
