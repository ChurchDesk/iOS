//
// Created by philip on 23/10/14.
//
// Copyright SHAPE A/S
//



#import <Foundation/Foundation.h>
#import <CommonCrypto/CommonDigest.h>
#import <CommonCrypto/CommonHMAC.h>

@interface SHPCrypto : NSObject

/// ---------------------------------------------------------------------
/// @name Crypto functions
/// ---------------------------------------------------------------------

/// Calculates the SHA1 digest of the data and returns as a string of hex values
+ (NSString *)shp_SHA1HexDigestFromData:(NSData *)data;

/// Calculates the HMAC signature of the data using the supplied secret and returns as a string of hex values
+ (NSString *)shp_HMACSHA1HexSignatureFromData:(NSData *)data withSecret:(NSString *)secret;

@end
