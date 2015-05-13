//
// Created by Soren Ulrikkeholm on 09/10/14.
// Copyright (c) 2014 SHAPE A/S. All rights reserved.
//

#import "SHPHTTPResponse.h"

@interface SHPHTTPResponse ()

@end

@implementation SHPHTTPResponse

- (instancetype)initWithResult:(id)result body:(id)body headers:(NSDictionary *)headers statusCode:(NSInteger)statusCode {
    if (!(self = [super init])) return nil;

    _result = result;
    _body = body;
    _headers = headers;
    _statusCode = statusCode;

    return self;
}

+ (instancetype)responseWithResult:(id)result body:(id)body headers:(NSDictionary *)headers statusCode:(NSInteger)statusCode {
    return [[self alloc] initWithResult:result body:body headers:headers statusCode:statusCode];
}

@end