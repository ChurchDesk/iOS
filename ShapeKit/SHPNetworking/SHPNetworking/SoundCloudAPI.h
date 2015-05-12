//
//  SoundCloudAPI.h
//  SHPNetworking
//
//  Created by Kasper Kronborg on 28/11/12.
//  Copyright (c) 2012 SHAPE A/S. All rights reserved.
//

#import <Foundation/Foundation.h>

//
//  Models
//
#import "SoundCloudTrack.h"
#import "SoundCloudUser.h"



@interface SoundCloudAPI : SHPAPI

@property (nonatomic, copy) NSString *clientId;
@property (nonatomic, copy) NSString *clientSecret;

- (void)getTracksWithCompletion:(SHPAPIManagerResourceCompletionBlock)completion;

- (void)getUserWithId:(NSInteger)userId completion:(SHPAPIManagerResourceCompletionBlock)completion;

- (void)authenticateWithUsername:(NSString *)username password:(NSString *)password completion:(SHPAPIManagerResourceCompletionBlock)completion;

@end
