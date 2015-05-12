//
//  Created by Ole Gammelgaard Poulsen on 13/05/13.
//  Copyright (c) 2012 SHAPE A/S. All rights reserved.
//

#import "SHPMultipartElement.h"


@implementation SHPMultipartElement {

}

- (id)initWithData:(NSData *)data name:(NSString *)name fileName:(NSString *)fileName mimeType:(NSString *)mimeType {
	self = [super init];
	if (self) {
		_data = data;
		_name = name;
		_fileName = fileName;
		_mimeType = mimeType;
	}

	return self;
}

- (id)initWithStringValue:(NSString *)value name:(NSString *)name {
	NSData *data = [value dataUsingEncoding:NSUTF8StringEncoding];
	return [self initWithData:data name:name fileName:nil mimeType:nil];
}

- (NSData *)dataRepresentation {
	NSString *headerString = @"Content-Disposition: form-data";
	if (self.name.length) {
		headerString = [headerString stringByAppendingFormat:@"; name=\"%@\"", self.name];
	}
	if (self.fileName.length) {
		headerString = [headerString stringByAppendingFormat:@"; filename=\"%@\"", self.fileName];
	}
	if (self.mimeType.length) {
		headerString = [headerString stringByAppendingFormat:@"\r\nContent-Type: %@", self.mimeType];
	}
	headerString = [headerString stringByAppendingString:@"\r\n\r\n"];

	NSMutableData *resultData = [[headerString dataUsingEncoding:NSUTF8StringEncoding] mutableCopy];
	if (self.data) {
		[resultData appendData:self.data];
	}
	return resultData;
}
@end