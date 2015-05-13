//
//  SHPManagedModel.h
//  SHPNetworking
//
//  Created by Kasper Kronborg on 21/11/12.
//  Copyright (c) 2012 SHAPE A/S. All rights reserved.
//

#import <Foundation/Foundation.h>



@interface SHPManagedModel : NSObject
@property (nonatomic, readonly) NSDictionary *initializedDictionary;
- (id)initWithDictionary:(NSDictionary *)dict;
@end
