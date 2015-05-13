//
//  CHDRootViewController.m
//  ChurchDesk
//
//  Created by Mikkel Selsøe Sørensen on 13/01/15.
//  Copyright (c) 2015 Shape A/S. All rights reserved.
//

#import "CHDRootViewController.h"

@interface CHDRootViewController ()

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

- (void) setPrimaryViewController:(UIViewController *)primaryViewController {
    if (primaryViewController == _primaryViewController) {
        return;
    }
    
    [_primaryViewController willMoveToParentViewController:nil];
    [_primaryViewController.view removeFromSuperview];
    [_primaryViewController removeFromParentViewController];
    
    _primaryViewController = primaryViewController;
    
    [self addChildViewController:_primaryViewController];
    if (self.secondaryViewController) {
        [self.view insertSubview:_primaryViewController.view belowSubview:self.secondaryViewController.view];
    }
    else {
        [self.view addSubview:_primaryViewController.view];
    }
    [_primaryViewController.view mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    [_primaryViewController didMoveToParentViewController:self];
}

- (void)presentSecondaryViewControllerAnimated:(BOOL)animated {
    [self presentSecondaryViewControllerAnimated:animated completion:nil];
}

- (void) presentSecondaryViewControllerAnimated: (BOOL) animated completion:(void (^)(BOOL finished))completion {
    
    UINavigationController *secondary = [self.secondaryViewControllerClass new];
    self.secondaryViewController = secondary;
    
    [self addChildViewController:secondary];
    [self.view addSubview:secondary.view];
    secondary.view.frame = CGRectOffset(self.view.bounds, 0, self.view.bounds.size.height);
    
    
    [UIView animateWithDuration:animated ? 0.4 : 0 delay:0 usingSpringWithDamping:0.9 initialSpringVelocity:1.0 options:0 animations:^{
        secondary.view.frame = self.view.bounds;
    } completion:^(BOOL finished) {
        [secondary didMoveToParentViewController:self];
        
        if (completion) {
            completion(finished);
        }
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
        self.secondaryViewController = nil;
        
        if (completion) {
            completion(finished);
        }
    }];
}

@end
