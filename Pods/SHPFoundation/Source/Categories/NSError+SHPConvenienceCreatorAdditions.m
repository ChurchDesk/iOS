//
//  Created by Ole Gammelgaard Poulsen on 18/12/12.
//  Copyright (c) 2012 SHAPE A/S. All rights reserved.
//
#import "NSError+SHPConvenienceCreatorAdditions.h"

@implementation NSError (SHPConvenienceCreatorAdditions)

+ (NSError *)shp_errorWithDescription:(NSString *)localizedDescription {
	return [NSError shp_errorWithDescription:localizedDescription code:SHPUnknowErrorCode];
}

+ (NSError *)shp_errorWithDescription:(NSString *)localizedDescription code:(NSInteger)code {
	NSString *domain = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleIdentifier"];
	NSError *error = [NSError errorWithDomain:domain code:code userInfo:[NSDictionary dictionaryWithObject:localizedDescription forKey:NSLocalizedDescriptionKey]];
	return error;
}

@end
