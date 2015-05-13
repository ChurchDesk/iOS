//
//  Created by Ole Gammelgaard Poulsen on 29/04/13.
//  Copyright (c) 2012 SHAPE A/S. All rights reserved.
//

#ifdef USE_REACTIVE_EXTENSION

#import "SHPAPIManager+ReactiveExtension.h"
#import "RACSubscriber.h"
#import "RACDisposable.h"
#import "SHPHTTPResponse.h"
#import "RACSignal.h"


NSString * const SHPAPIManagerReactiveExtensionErrorResponseKey = @"request_error_response_key";


@implementation SHPAPIManager (ReactiveExtension)

- (RACSignal *)dispatchRequest:(SHPHTTPRequestBlock)requestBlock toResource:(SHPAPIResource *)resource {
    return [RACSignal createSignal:^RACDisposable *(id <RACSubscriber> subscriber) {
        [self dispatchRequest:requestBlock toResource:resource withCompletion:^(SHPHTTPResponse *response, NSError *error) {
            if (error) {
                NSError *errorWithData = [self appendResponse:response toError:error];
                [subscriber sendError:errorWithData];
            } else {
                [subscriber sendNext:response.result];
            }
            [subscriber sendCompleted];
        }];
        return nil;
    }];
}

- (RACSignal *)dispatchRequest:(SHPHTTPRequestBlock)requestBlock withBodyContent:(NSDictionary *)content toResource:(SHPAPIResource *)resource {
	return [self dispatchRequest:requestBlock withBodyContent:content toResource:resource onlyResult:YES];
}

- (RACSignal *)dispatchRequest:(SHPHTTPRequestBlock)requestBlock withBodyContent:(NSDictionary *)content toResource:(SHPAPIResource *)resource onlyResult:(BOOL)onlyResult {
	return [RACSignal createSignal:^RACDisposable *(id <RACSubscriber> subscriber) {
		[self dispatchRequest:requestBlock withBodyContent:content toResource:resource withCompletion:^(SHPHTTPResponse *response, NSError *error) {
			if (error) {
                NSError *errorWithData = [self appendResponse:response toError:error];
				[subscriber sendError:errorWithData];
			} else {
				id nextValue = onlyResult ? response.result : response;
				[subscriber sendNext:nextValue];
			}
			[subscriber sendCompleted];
		}];
		return nil;
	}];
}

- (RACSignal *)dispatchRequest:(SHPHTTPRequestBlock)requestBlock withMultiparts:(NSArray *)parts toResource:(SHPAPIResource *)resource {
	return [RACSignal createSignal:^RACDisposable *(id <RACSubscriber> subscriber) {
		[self dispatchMultipartRequest:requestBlock withParts:parts toResource:resource withCompletion:^(SHPHTTPResponse *response, NSError *error) {
			if (error) {
                NSError *errorWithData = [self appendResponse:response toError:error];
				[subscriber sendError:errorWithData];
			} else {
				[subscriber sendNext:response.result];
			}
			[subscriber sendCompleted];
		}];
		return nil;
	}];
}

- (NSError *)appendResponse:(SHPHTTPResponse *)response toError:(NSError *)error {
    NSMutableDictionary *errorDict = [error.userInfo mutableCopy];
    if (response) {
        errorDict[SHPAPIManagerReactiveExtensionErrorResponseKey] = response;
    }
    NSError *errorWithData = [NSError errorWithDomain:error.domain code:error.code userInfo:[errorDict copy]];
    return errorWithData;
}

@end

#endif
