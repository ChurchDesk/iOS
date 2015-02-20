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

@property (nonatomic, strong) MASConstraint *topConstraint;
@property (nonatomic, assign) BOOL showDrawer;

- (instancetype)initWithNavigationController: (UINavigationController*) navigationController;

- (void) setShowDrawer:(BOOL) showDrawer animated: (BOOL) animated;

- (void) takeSnapshot;

@end
