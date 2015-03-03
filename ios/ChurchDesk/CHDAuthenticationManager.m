//
//  CHDAuthenticationManager.m
//  ChurchDesk
//
//  Created by Mikkel Selsøe Sørensen on 02/03/15.
//  Copyright (c) 2015 Shape A/S. All rights reserved.
//

#import "CHDAuthenticationManager.h"
#import "SSKeyChain.h"
#import "CHDAccessToken.h"

static NSString * const KeychainService = @"dk.churchdesk";

@interface CHDAuthenticationManager ()

@property (nonatomic, strong) CHDAccessToken *authenticationToken;
@property (nonatomic, strong) NSString *userID;

@end

@implementation CHDAuthenticationManager

+ (instancetype) sharedInstance {
    static CHDAuthenticationManager *_sharedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedManager = [CHDAuthenticationManager new];
    });
    return _sharedManager;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        SSKeychainQuery *query = [[SSKeychainQuery alloc] init];
        query.service = KeychainService;
        query.synchronizationMode = SSKeychainQuerySynchronizationModeNo;
        NSError *error = nil;
        NSArray *result = [query fetchAll:&error];
        if (!result) {
            NSLog(@"Error fetching from Keychain: %@", error);
        }
        else {
            NSString *userID = result.firstObject[kSSKeychainAccountKey];
            query.account = userID;
            if ([query fetch:&error]) {
                _authenticationToken = query.passwordData ? [NSKeyedUnarchiver unarchiveObjectWithData:query.passwordData] : nil;
                _userID = query.account;
            }
            else {
                NSLog(@"Error fetching from Keychain: %@", error);
            }
        }
    }
    return self;
}

- (void) authenticateWithToken: (CHDAccessToken*) token userID:(NSString *)userID {
    
    SSKeychainQuery *query = [[SSKeychainQuery alloc] init];
    query.service = KeychainService;
    query.account = userID;
    query.synchronizationMode = SSKeychainQuerySynchronizationModeNo;
    query.passwordData = [NSKeyedArchiver archivedDataWithRootObject:token];
    NSError *error = nil;
    if (![query save:&error]) {
        NSLog(@"Error saving to Keychain: %@", error);
    }
    else {
        self.userID = userID;
        self.authenticationToken = token;
    }
}

- (void) signOut {
    SSKeychainQuery *query = [[SSKeychainQuery alloc] init];
    query.service = KeychainService;
    query.synchronizationMode = SSKeychainQuerySynchronizationModeNo;
    query.account = self.userID;
    
    NSError *error = nil;
    if (![query deleteItem:&error]) {
        NSLog(@"Error removing credentials from Keychain: %@", error);
    }
    
    self.userID = nil;
    self.authenticationToken = nil;
}
@end
