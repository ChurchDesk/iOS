//
//  CHDMagicNavigationBarView.h
//  ChurchDesk
//
//  Created by Mikkel Selsøe Sørensen on 19/02/15.
//  Copyright (c) 2015 Shape A/S. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MASConstraint;

@interface CHDMagicNavigationBarView : UIView
@property (nonatomic, readonly) UIView *drawerView;
@property (nonatomic, strong) MASConstraint *bottomConstraint;
@property (nonatomic, assign) BOOL showDrawer;
@property (nonatomic, readonly) BOOL drawerIsHidden;

- (instancetype)initWithNavigationController: (UINavigationController*) navigationController navigationItem: (UINavigationItem*) navigationItem;

- (void) setShowDrawer:(BOOL) showDrawer animated: (BOOL) animated;

- (void) takeSnapshot;

@end
