//
//  CHDLoginViewModel.m
//  ChurchDesk
//
//  Created by Mikkel Selsøe Sørensen on 02/03/15.
//  Copyright (c) 2015 Shape A/S. All rights reserved.
//

#import "CHDLoginViewModel.h"
#import "CHDAPIClient.h"
#import "CHDAuthenticationManager.h"

@implementation CHDLoginViewModel

- (void) loginWithUserName: (NSString*) username password: (NSString*) password {
    [[CHDAuthenticationManager sharedInstance] rac_liftSelector:@selector(authenticateWithToken:userID:) withSignals:[[CHDAPIClient sharedInstance] loginWithUserName:username password:password], [RACSignal return:username], nil];
}

@end
