//
//  UINavigationController+ChurchDesk.m
//  ChurchDesk
//
//  Created by Mikkel Selsøe Sørensen on 26/02/15.
//  Copyright (c) 2015 Shape A/S. All rights reserved.
//

#import "UINavigationController+ChurchDesk.h"
#import "SHPSideMenu.h"

@implementation UINavigationController (ChurchDesk)

+ (instancetype) chd_sideMenuNavigationControllerWithRootViewController: (UIViewController*) viewController {
    UINavigationController *navigationController = [[self alloc] initWithRootViewController:viewController];
    viewController.navigationItem.leftBarButtonItem = [UIBarButtonItem chd_burgerWithTarget:navigationController action:@selector(sideMenuAction:)];
    
    return navigationController;
}

- (void)sideMenuAction: (id) sender {
    [Heap track:@"Side menu button clicked"];
    [[(UIViewController*)self.viewControllers.firstObject shp_sideMenuController] toggleLeft];
}

@end
