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

@interface CHDLoginViewModel ()

@property (nonatomic, strong) RACCommand *loginCommand;
@property (nonatomic, strong) RACCommand *resetPasswordCommand;

@end

@implementation CHDLoginViewModel

- (RACSignal*) loginWithUserName: (NSString*) username password: (NSString*) password {
    return [self.loginCommand execute:RACTuplePack(username, password)];
}

- (RACSignal*) resetPasswordForEmail: (NSString*) email {
    return [self.resetPasswordCommand execute:email];
}

#pragma mark - Lazy Initialization

- (RACCommand *)loginCommand {
    if (!_loginCommand) {
        _loginCommand = [[RACCommand alloc] initWithSignalBlock:^RACSignal *(RACTuple *tuple) {
            NSString *username = tuple.first;
            NSString *password = tuple.second;
            return [[CHDAuthenticationManager sharedInstance] rac_liftSelector:@selector(authenticateWithToken:userID:) withSignals:[[CHDAPIClient sharedInstance] loginWithUserName:username password:password], [RACSignal return:username], nil];
        }];
    }
    return _loginCommand;
}

- (RACCommand *)resetPasswordCommand {
    if (!_resetPasswordCommand) {
        _resetPasswordCommand = [[RACCommand alloc] initWithSignalBlock:^RACSignal *(NSString *email) {
            return [[CHDAPIClient sharedInstance] postResetPasswordForEmail:email];
        }];
    }
    return _resetPasswordCommand;
}

@end
