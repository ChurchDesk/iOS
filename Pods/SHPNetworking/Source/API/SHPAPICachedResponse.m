//
// Created by kronborg on 04/09/13.
//


#import "SHPAPICachedResponse.h"


@implementation SHPAPICachedResponse

- (id)initWithCoder:(NSCoder *)aDecoder {
    if ((self = [super init])) {
        self->_result = [aDecoder decodeObjectForKey:@"result"];
        self->_body = [aDecoder decodeObjectForKey:@"body"];
        self->_headers = [aDecoder decodeObjectForKey:@"headers"];
        self->_statusCode = [aDecoder decodeIntegerForKey:@"statusCode"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:_result forKey:@"result"];
    [aCoder encodeObject:_body forKey:@"body"];
    [aCoder encodeObject:_headers forKey:@"headers"];
    [aCoder encodeInteger:_statusCode forKey:@"statusCode"];
}

@end