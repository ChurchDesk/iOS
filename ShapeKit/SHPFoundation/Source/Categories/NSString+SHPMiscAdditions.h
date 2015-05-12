//
//  Created by Ole Gammelgaard Poulsen on 18/12/12.
//  Copyright (c) 2012 SHAPE A/S. All rights reserved.
//
#import <Foundation/Foundation.h>

@interface NSString (SHPMiscAdditions)

- (NSString *)shp_snakeCaseFromCamelCaseString;
- (NSString *)shp_capitalizedFirstLetterString;
- (NSString *)shp_firstCaptureOfRegex:(NSString *)pattern;
- (NSArray *)shp_capturesOfRegex:(NSString *)pattern;
- (BOOL)shp_matchesRegex:(NSString *)pattern;
- (NSString *)shp_stringByRemovingOccurancesOfStrings:(NSArray *)strings;
- (BOOL)shp_matchesEmailRegex;

@end
