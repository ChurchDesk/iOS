//
//  SoundCloudUser.h
//  SHPNetworking
//
//  Created by Kasper Kronborg on 28/11/12.
//  Copyright (c) 2012 SHAPE A/S. All rights reserved.
//

#import "SHPManagedModel.h"



@interface SoundCloudUser : SHPManagedModel

@property (nonatomic, assign) NSInteger userId;
@property (nonatomic, copy) NSString *username;

@end
