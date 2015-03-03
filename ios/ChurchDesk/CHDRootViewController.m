//
//  CHDRootViewController.m
//  ChurchDesk
//
//  Created by Mikkel Selsøe Sørensen on 13/01/15.
//  Copyright (c) 2015 Shape A/S. All rights reserved.
//

#import "CHDRootViewController.h"

@interface CHDRootViewController ()

@property (nonatomic, strong) UIViewController *primaryViewController;
@property (nonatomic, strong) UIViewController *secondaryViewController;
@property (nonatomic, strong) Class secondaryViewControllerClass;

@end

@implementation CHDRootViewController

- (instancetype)initWithPrimaryViewController: (UIViewController*) primaryViewController secondaryViewControllerClass: (Class) secondaryViewControllerClass {
    self = [super init];
    if (self) {
        self.primaryViewController = primaryViewController;
        self.secondaryViewControllerClass = secondaryViewControllerClass;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self addChildViewController:self.primaryViewController];
    [self.view addSubview:self.primaryViewController.view];
    self.primaryViewController.view.frame = self.view.bounds;
    [self.primaryViewController didMoveToParentViewController:self];
}

- (void) presentSecondaryViewControllerAnimated: (BOOL) animated {
    
    UINavigationController *secondary = [self.secondaryViewControllerClass new];
    self.secondaryViewController = secondary;
    
    [self addChildViewController:secondary];
    [self.view addSubview:secondary.view];
    secondary.view.frame = CGRectOffset(self.view.bounds, 0, self.view.bounds.size.height);
    
    
    [UIView animateWithDuration:animated ? 0.4 : 0 delay:0 usingSpringWithDamping:0.9 initialSpringVelocity:1.0 options:0 animations:^{
        secondary.view.frame = self.view.bounds;
    } completion:^(BOOL finished) {
        [secondary didMoveToParentViewController:self];
    }];
}

- (void) dismissSecondaryViewControllerAnimated: (BOOL) animated completion:(void (^)(BOOL finished))completion {
    UIViewController *viewController = self.secondaryViewController;
    
    [UIView animateWithDuration:animated ? 0.4 : 0 delay:0 usingSpringWithDamping:1.0 initialSpringVelocity:1.0 options:0 animations:^{
        viewController.view.frame = CGRectOffset(self.view.bounds, 0, self.view.bounds.size.height);
    } completion:^(BOOL finished) {
        [viewController willMoveToParentViewController:nil];
        [viewController.view removeFromSuperview];
        [viewController removeFromParentViewController];
        
        if (completion) {
            completion(finished);
        }
    }];
}

@end
