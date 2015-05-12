//
// Created by kronborg on 04/09/13.
//


#import <Foundation/Foundation.h>


@interface SHPAPICachedResponse : NSObject <NSCoding>
@property (nonatomic, strong) id result;
@property (nonatomic, strong) id body;
@property (nonatomic, strong) NSDictionary *headers;
@property (nonatomic, assign) NSInteger statusCode;
// Please add any new properties to the NSCoding methods in the implementation file

@end