//
//  CHDMagicNavigationBarView.m
//  ChurchDesk
//
//  Created by Mikkel Selsøe Sørensen on 19/02/15.
//  Copyright (c) 2015 Shape A/S. All rights reserved.
//

#import "CHDMagicNavigationBarView.h"

@interface CHDMagicNavigationBarView ()

@property (nonatomic, strong) UIView *drawerView;

@end

@implementation CHDMagicNavigationBarView



- (void) showDrawer: (BOOL) showDrawer animated: (BOOL) animated withNavigationController: (UINavigationController*) navigationController {
    UIView *snapshotView = [navigationController.navigationBar snapshotViewAfterScreenUpdates:YES];
    [self addSubview:snapshotView];
}

@end
