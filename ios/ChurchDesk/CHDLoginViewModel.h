//
//  CHDLoginViewModel.h
//  ChurchDesk
//
//  Created by Mikkel Selsøe Sørensen on 02/03/15.
//  Copyright (c) 2015 Shape A/S. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CHDLoginViewModel : NSObject

@property (nonatomic, readonly) RACCommand *loginCommand;
@property (nonatomic, readonly) RACCommand *resetPasswordCommand;

- (RACSignal*) loginWithUserName: (NSString*) username password: (NSString*) password;
- (RACSignal*) resetPasswordForEmail: (NSString*) email;

@end
