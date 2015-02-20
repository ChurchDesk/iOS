//
//  CHDMenuItem.h
//  ChurchDesk
//
//  Created by Jakob Vinther-Larsen on 20/02/15.
//  Copyright (c) 2015 Shape A/S. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CHDMenuItem : NSObject
@property (nonatomic, strong) UIViewController* viewController;
@property (nonatomic, strong) NSString* title;
@property (nonatomic, strong) UIImage* image;
@end
