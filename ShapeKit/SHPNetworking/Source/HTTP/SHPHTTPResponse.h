//
// Created by Soren Ulrikkeholm on 09/10/14.
// Copyright (c) 2014 SHAPE A/S. All rights reserved.
//


@interface SHPHTTPResponse : NSObject

@property (nonatomic, readonly) id result;
@property (nonatomic, readonly) id body;
@property (nonatomic, readonly) NSDictionary *headers;
@property (nonatomic, readonly) NSInteger statusCode;

- (instancetype)initWithResult:(id)result body:(id)body headers:(NSDictionary *)headers statusCode:(NSInteger)statusCode;

+ (instancetype)responseWithResult:(id)result body:(id)body headers:(NSDictionary *)headers statusCode:(NSInteger)statusCode;

@end