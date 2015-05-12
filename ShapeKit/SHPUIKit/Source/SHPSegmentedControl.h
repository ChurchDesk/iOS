//
//  SHPSegmentedControl.h
//  THansen
//
//  Created by Ole Poulsen on 10/11/11.
//  Copyright (c) 2011 Shape ApS. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SHPSegmentedControl : UIControl

/// IMPORTANT: you must first call setImages: befor setting any other 
@property (nonatomic, strong) NSArray *images;

@property (nonatomic, assign) NSUInteger selectedIndex;
@property (nonatomic, strong) NSArray *buttons;

@end
