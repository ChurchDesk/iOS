//
//  CHDAccessToken.m
//  ChurchDesk
//
//  Created by Mikkel Selsøe Sørensen on 03/03/15.
//  Copyright (c) 2015 Shape A/S. All rights reserved.
//

#import "CHDAccessToken.h"

@implementation CHDAccessToken

- (id)initWithCoder:(NSCoder *)aDecoder {
    if ((self = [super init])) {
        _accessToken = [aDecoder decodeObjectForKey:@"accessToken"];
        _refreshToken = [aDecoder decodeObjectForKey:@"refreshToken"];
        _expiryDate = [aDecoder decodeObjectForKey:@"expiryDate"];
        _scope = [aDecoder decodeObjectForKey:@"scope"];
        _tokenType = [aDecoder decodeObjectForKey:@"tokenType"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:_accessToken forKey:@"accessToken"];
    [aCoder encodeObject:_refreshToken forKey:@"refreshToken"];
    [aCoder encodeObject:_expiryDate forKey:@"expiryDate"];
    [aCoder encodeObject:_scope forKey:@"scope"];
    [aCoder encodeObject:_tokenType forKey:@"tokenType"];
}

- (NSString *)mapPropertyForPropertyWithName:(NSString *)propName {
    
    if ([propName isEqualToString:@"accessToken"]) {
        return @"access_token";
    }
    if ([propName isEqualToString:@"refreshToken"]) {
        return @"refresh_token";
    }
    if ([propName isEqualToString:@"expiryDate"]) {
        return @"expires_in";
    }
    if ([propName isEqualToString:@"tokenType"]) {
        return @"token_type";
    }
    
    return [super mapPropertyForPropertyWithName:propName];
}

- (id)transformedValueForPropertyWithName:(NSString *)propName value:(id)value {
    if ([propName isEqualToString:@"expiryDate"] && [value respondsToSelector:@selector(doubleValue)]) {
        NSTimeInterval timeInterval = [value doubleValue];
        return [NSDate dateWithTimeIntervalSinceNow:timeInterval];
    }
    return [super transformedValueForPropertyWithName:propName value:value];
}

- (BOOL)expired {
    return [self.expiryDate timeIntervalSinceNow] < 0;
}

@end
