//
// Created by philip on 23/10/14.
//
// Copyright SHAPE A/S
//


#import "SHPCrypto.h"

@implementation SHPCrypto

+ (NSString *)shp_SHA1HexDigestFromData:(NSData *)data {
    // make a buffer to store the result bytes
    unsigned char md[CC_SHA1_DIGEST_LENGTH];
    // call the crypto lib function to get the hash bytes
    (void)CC_SHA1([data bytes], [data length], md);

    // Convert value to NSString of hex values
    NSMutableString *output = [NSMutableString stringWithCapacity:CC_SHA1_DIGEST_LENGTH * 2];
    for(int i = 0; i < CC_SHA1_DIGEST_LENGTH; i++)
        [output appendFormat:@"%02x",md[i]];

    // get a non-mutable string
    NSString *hashString = [output copy];
    return hashString;
}

+ (NSString *)shp_HMACSHA1HexSignatureFromData:(NSData *)data withSecret:(NSString *)secret {
    NSData *secretData = [secret dataUsingEncoding:NSUTF8StringEncoding];

    unsigned char result[CC_SHA1_DIGEST_LENGTH];
    CCHmac(kCCHmacAlgSHA1, [secretData bytes], [secretData length], [data bytes], [data length], result);

    // Convert value to NSString of hex values
    NSMutableString *output = [NSMutableString stringWithCapacity:CC_SHA1_DIGEST_LENGTH * 2];
    for(int i = 0; i < CC_SHA1_DIGEST_LENGTH; i++)
        [output appendFormat:@"%02x",result[i]];

    // get a non-mutable string
    NSString *hmac = [output copy];
    return hmac;
}

@end
