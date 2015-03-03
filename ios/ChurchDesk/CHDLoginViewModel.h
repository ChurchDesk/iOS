//
//  CHDLoginViewModel.h
//  ChurchDesk
//
//  Created by Mikkel Selsøe Sørensen on 02/03/15.
//  Copyright (c) 2015 Shape A/S. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CHDLoginViewModel : NSObject

- (void) loginWithUserName: (NSString*) username password: (NSString*) password;

@end
