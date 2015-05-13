//
//  SHPValidator.h
//  SHPNetworking
//
//  Created by Kasper Kronborg on 03/01/13.
//  Copyright (c) 2013 SHAPE A/S. All rights reserved.
//

#import <Foundation/Foundation.h>



@protocol SHPValidator <NSObject>
@required
- (BOOL)validate:(id)input error:(NSError *__autoreleasing *)error;
@end
