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
#import "CHDAPIClient.h"
@import Intercom;

static NSString * const KeychainService = @"dk.churchdesk";
static NSString * const kDeviceTokenAccountName = @"CHDDeviceToken";

@interface CHDAuthenticationManager ()

@property (nonatomic, strong) CHDAccessToken *authenticationToken;
@property (nonatomic, strong) NSString *userID;

@end

@implementation CHDAuthenticationManager {
    NSString *_deviceToken;
}

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
                @try {
                    _authenticationToken = query.passwordData ? [NSKeyedUnarchiver unarchiveObjectWithData:query.passwordData] : nil;
                } @catch(NSException * e){
                    NSLog(@"Authentication token issue %@", e);
                    _authenticationToken = nil;
                }
                _userID = query.account;
                [self registerRemoteNotificationTypes];
            }
            else {
                NSLog(@"Error fetching from Keychain: %@", error);
            }
        }
#if DEBUG
      [[RACObserve(self, authenticationToken) ignore:nil] subscribeNext:^(CHDAccessToken *token) {
          NSDateFormatter *dateFormatter = [NSDateFormatter new];
          dateFormatter.dateStyle = NSDateFormatterLongStyle;
          dateFormatter.timeStyle = NSDateFormatterShortStyle;
          dateFormatter.locale = [NSLocale localeWithLocaleIdentifier:@"da_DK"];
          NSLog(@"Authentication Token: %@", token.accessToken);
      }];
#endif
        
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
        //Intercom session registration
        [Intercom registerUserWithEmail:userID];
        [self registerRemoteNotificationTypes];
    }
}

- (void) signOut {
    //reset Intercom
    [Intercom reset];
    
    [[[CHDAPIClient sharedInstance] deleteDeviceToken:_deviceToken accessToken:self.authenticationToken.accessToken] subscribeNext:^(id x) {
        NSLog(@"Device token deleted from server");
    }];

    self.deviceToken = nil;
    
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
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:kcurrentuser];
    
}

- (void)registerRemoteNotificationTypes {
    
    UIApplication *application = [UIApplication sharedApplication];
    UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeBadge | UIUserNotificationTypeSound | UIUserNotificationTypeAlert categories:nil];
    [application registerUserNotificationSettings:settings];
    [application registerForRemoteNotifications];
}

#pragma mark - Device token

- (void) setDeviceToken: (NSString*) deviceToken {
    if (deviceToken) {
        [[[CHDAPIClient sharedInstance] postDeviceToken:deviceToken] subscribeNext:^(id x) {
#if DEBUG
            NSLog(@"Device token %@ posted to server", deviceToken);
#else 
        NSLog(@"Device token posted to server");
#endif
            [SSKeychain setPassword:deviceToken forService:KeychainService account:kDeviceTokenAccountName];
        }];
    }
    else {
        NSString *accessToken = self.authenticationToken.accessToken;
        if(accessToken){
            [[[CHDAPIClient sharedInstance] deleteDeviceToken:_deviceToken accessToken:accessToken] subscribeNext:^(id x) {
                NSLog(@"Device token deleted from server");
            }];
        }

        [SSKeychain deletePasswordForService:KeychainService account:kDeviceTokenAccountName];
    }
    _deviceToken = deviceToken;
}

- (NSString*) deviceToken {
    if (!_deviceToken) {
        _deviceToken = [SSKeychain passwordForService:KeychainService account:kDeviceTokenAccountName];
    }
    return _deviceToken;
}

@end
