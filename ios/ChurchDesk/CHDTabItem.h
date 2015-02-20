//
//  CHDTabItem.h
//  ChurchDesk
//
//  Created by Jakob Vinther-Larsen on 19/02/15.
//  Copyright (c) 2015 Shape A/S. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CHDTabItem : NSObject
@property (nonatomic, strong) UIViewController* viewController;
@property (nonatomic, strong) UIImage* imageNormal;
@property (nonatomic, strong) UIImage* imageSelected;
@property (nonatomic, strong) NSString* title;
@end
