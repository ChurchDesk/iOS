//
//  CHDRootViewController.h
//  ChurchDesk
//
//  Created by Mikkel Selsøe Sørensen on 13/01/15.
//  Copyright (c) 2015 Shape A/S. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CHDRootViewController : UIViewController

@property (nonatomic, strong) UIViewController *primaryViewController;

- (instancetype)initWithPrimaryViewController: (UIViewController*) primaryViewController secondaryViewControllerClass: (Class) secondaryViewControllerClass;

- (void) presentSecondaryViewControllerAnimated: (BOOL) animated;
- (void) presentSecondaryViewControllerAnimated: (BOOL) animated completion:(void (^)(BOOL finished))completion;
- (void) dismissSecondaryViewControllerAnimated: (BOOL) animated completion:(void (^)(BOOL finished))completion;

@end
