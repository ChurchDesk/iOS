//
// Created by philip on 06/11/14.
//
// Copyright SHAPE A/S
//



#import <Foundation/Foundation.h>

@interface SHPNetworkBase64 : NSObject

+ (NSString *)stringByBase64EncodingString:(NSString *)string;
+ (NSString *)stringByBase64EncodingData:(NSData *)data;

@end
