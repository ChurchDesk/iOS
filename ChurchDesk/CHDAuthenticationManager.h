//
//  CHDAuthenticationManager.h
//  ChurchDesk
//
//  Created by Mikkel Selsøe Sørensen on 02/03/15.
//  Copyright (c) 2015 Shape A/S. All rights reserved.
//

#import <Foundation/Foundation.h>

@class CHDAccessToken;

@interface CHDAuthenticationManager : NSObject

@property (nonatomic, readonly) NSString *userID;
@property (nonatomic, readonly) CHDAccessToken *authenticationToken;
@property (nonatomic, strong) NSString *deviceToken;

+ (instancetype) sharedInstance;

- (void) authenticateWithToken: (CHDAccessToken*) token userID:(NSString *)userID;
- (void) signOut;

@end
