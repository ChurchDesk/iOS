//
//  UINavigationController+ChurchDesk.h
//  ChurchDesk
//
//  Created by Mikkel Selsøe Sørensen on 26/02/15.
//  Copyright (c) 2015 Shape A/S. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UINavigationController (ChurchDesk)

+ (instancetype) chd_sideMenuNavigationControllerWithRootViewController: (UIViewController*) viewController;

@end
