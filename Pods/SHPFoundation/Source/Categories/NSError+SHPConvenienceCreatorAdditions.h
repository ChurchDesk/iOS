//
//  Created by Ole Gammelgaard Poulsen on 18/12/12.
//  Copyright (c) 2012 SHAPE A/S. All rights reserved.
//
#import <Foundation/Foundation.h>

enum SHPStandardErrorCodes {
    SHPUnknowErrorCode = 1000
};

/// Easy creation of errors without specifying a domain and optionally also ommiting a code. The bundle identifier is used as domain (bundle identifier).
@interface NSError (SHPConvenienceCreatorAdditions)

/// ---------------------------------------------------------------------
/// @name Simple Creation of Error Objects
/// ---------------------------------------------------------------------

/// Creates and initializes an NSError object for a given description but with default domain and error code
+ (NSError *)shp_errorWithDescription:(NSString *)localizedDescription;

/// Creates and initializes an NSError object for a given description and error code but with default domain (bundle identifier).
+ (NSError *)shp_errorWithDescription:(NSString *)localizedDescription code:(NSInteger)code;

@end
