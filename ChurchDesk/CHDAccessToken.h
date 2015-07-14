//
//  CHDAccessToken.h
//  ChurchDesk
//
//  Created by Mikkel Selsøe Sørensen on 03/03/15.
//  Copyright (c) 2015 Shape A/S. All rights reserved.
//

#import "CHDManagedModel.h"

@interface CHDAccessToken : CHDManagedModel <NSCoding>

@property (nonatomic, strong) NSString *accessToken;
@property (nonatomic, strong) NSArray *organizations;

@end
