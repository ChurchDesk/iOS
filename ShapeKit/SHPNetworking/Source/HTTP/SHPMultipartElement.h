//
//  Created by Ole Gammelgaard Poulsen on 13/05/13.
//  Copyright (c) 2012 SHAPE A/S. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface SHPMultipartElement : NSObject

@property(nonatomic, readonly) NSData *data;
@property(nonatomic, readonly) NSString *name;
@property(nonatomic, readonly) NSString *fileName;
@property(nonatomic, readonly) NSString *mimeType;

- (id)initWithData:(NSData *)data name:(NSString *)name fileName:(NSString *)fileName mimeType:(NSString *)mimeType;

- (id)initWithStringValue:(NSString *)value name:(NSString *)name;


- (NSData *)dataRepresentation;

@end