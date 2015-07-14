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
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:_accessToken forKey:@"accessToken"];
    
}

- (NSString *)mapPropertyForPropertyWithName:(NSString *)propName {
    
    if ([propName isEqualToString:@"accessToken"]) {
        return @"access_token";
    }
    if ([propName isEqualToString:@"organizations"]) {
        return @"organizations";
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



@end
