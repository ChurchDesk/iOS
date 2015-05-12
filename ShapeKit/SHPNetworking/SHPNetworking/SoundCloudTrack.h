//
//  SoundCloudTrack.h
//  SHPNetworking
//
//  Created by Kasper Kronborg on 20/11/12.
//  Copyright (c) 2012 SHAPE A/S. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SHPManagedModel.h"
#import "SoundCloudUser.h"


@interface SoundCloudTrack : SHPManagedModel

@property (nonatomic, assign) NSInteger trackId;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *labelName;
@property (nonatomic, strong) SoundCloudUser *user;

@end
