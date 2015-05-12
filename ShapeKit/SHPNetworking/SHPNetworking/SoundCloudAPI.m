//
//  SoundCloudAPI.m
//  SHPNetworking
//
//  Created by Kasper Kronborg on 28/11/12.
//  Copyright (c) 2012 SHAPE A/S. All rights reserved.
//

#import "SoundCloudAPI.h"



@implementation SoundCloudAPI

- (void)getTracksWithCompletion:(SHPAPIManagerResourceCompletionBlock)completion
{
//    NSDictionary *queryParams = @{ @"client_id": self.clientId };
//    
//    SHPAPIResource *tracksResource = [[SHPAPIResource alloc] initWithPath:@"/tracks.json"];
//    [tracksResource setResultObjectClass:[SoundCloudTrack class]];
//    [tracksResource addValidator:[SHPBlockValidator validatorWithValidationBlock:^BOOL(id input, NSError *__autoreleasing *error) {
//        if ([input isKindOfClass:[NSArray class]]) {
//            return YES;
//        }
//        
//        *error = [NSError errorWithDescription:@"Not validated"];
//        return NO;
//    }]];
//    
//    [self.manager dispatchRequest:^(SHPHTTPRequest *request) {
//        [request setQueryParameters:queryParams];
//    } toResource:tracksResource withCompletion:completion];
}

- (void)getUserWithId:(NSInteger)userId completion:(SHPAPIManagerResourceCompletionBlock)completion
{
    NSString *path = [NSString stringWithFormat:@"/users/%ld.json", (long)userId];

    SHPAPIResource *usersResource = [[SHPAPIResource alloc] initWithPath:path];
    [usersResource setResultObjectClass:[SoundCloudUser class]];
    [usersResource setCacheInterval:60];
//    [usersResource addValidator:[SHPBlockValidator validatorWithValidationBlock:^BOOL(id input, __autoreleasing NSError **error) {
//        if ([input isKindOfClass:[NSDictionary class]]) {
//            return YES;
//        }
//
//        *error = [NSError errorWithDomain:@"MyDomain" code:500 userInfo:nil];
//        return NO;
//    }]];

    [self.manager dispatchRequest:^(SHPHTTPRequest *request) {
        [request addValue:self.clientId forQueryParameterKey:@"client_id"];
    } toResource:usersResource withCompletion:completion];
}

- (void)authenticateWithUsername:(NSString *)username password:(NSString *)password completion:(SHPAPIManagerResourceCompletionBlock)completion
{
//    SHPOAuth2AuthClient *authClient = [[SHPOAuth2AuthClient alloc] initWithManager:self.manager];
//    [authClient setTokenPath:@"/oauth2/token"];
//    [authClient setClientId:self.clientId];
//    [authClient setClientSecret:self.clientSecret];
//    [authClient setUsername:username];
//    [authClient setPassword:password];
//    
//    [self.manager setAuthClient:authClient];
//    
//    [self.manager.authClient authenticate:^{
//        
//    }];
    
//    SHPAPIResource *authResource = [[SHPAPIResource alloc] initWithPath:@"/oauth2/token"];
//    [authResource setResultClass:[NSDictionary class]];
//    
//    NSDictionary *bodyContent = @{
//        @"client_id": self.clientId,
//        @"client_secret": self.clientSecret,
//        @"grant_type": @"password",
//        @"username": username,
//        @"password": password
//    };
//    
//    [self.manager dispatchRequest:^(SHPHTTPRequest *request) {
//        [request setMethod:SHPHTTPRequestMethodPOST];
//        
//    } withBodyContent:bodyContent toResource:authResource withCompletion:completion];

}

@end
