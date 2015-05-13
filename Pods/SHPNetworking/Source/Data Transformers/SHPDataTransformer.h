//
//  SHPDataTransformer.h
//  SHPNetworking
//
//  Created by Kasper Kronborg on 20/11/12.
//  Copyright (c) 2012 SHAPE A/S. All rights reserved.
//

#import <Foundation/Foundation.h>



@protocol SHPDataTransformer <NSObject>
@required
- (id)objectWithData:(NSData *)data error:(__autoreleasing NSError **)error;
- (NSData *)dataWithObject:(id)object error:(__autoreleasing NSError **)error;
@end
