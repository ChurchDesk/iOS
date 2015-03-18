//
//  UIViewController+UIViewController_ChurchDesk.m
//  ChurchDesk
//
//  Created by Jakob Vinther-Larsen on 18/03/15.
//  Copyright (c) 2015 Shape A/S. All rights reserved.
//

#import "UIViewController+UIViewController_ChurchDesk.h"
#import "CHDNewMessageViewController.h"
#import "CHDEditEventViewController.h"
#import "CHDExpandableButtonView.h"

//code in here
@implementation UIViewController (UIViewController_ChurchDesk)
- (void) setupAddButton {
    CHDExpandableButtonView *actionButtonView = [CHDExpandableButtonView new];
    [self.view addSubview:actionButtonView];
    
    UIView* superview = self.view;
    [actionButtonView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(superview);
        make.bottom.equalTo(superview).offset(-5);
    }];
    
    [actionButtonView.addMessageButton addTarget:self action:@selector(newMessageShow:) forControlEvents:UIControlEventTouchUpInside];
    [actionButtonView.addEventButton addTarget:self action:@selector(newEventAction:) forControlEvents:UIControlEventTouchUpInside];
}
- (void) newMessageShow: (id) sender {
    CHDNewMessageViewController* newMessageViewController = [CHDNewMessageViewController new];
    UINavigationController *navigationVC = [[UINavigationController new] initWithRootViewController:newMessageViewController];
    [self presentViewController:navigationVC animated:YES completion:nil];
}
- (void) newEventAction: (id) sender {
    CHDEditEventViewController *vc = [[CHDEditEventViewController alloc] initWithEvent:nil];
    UINavigationController *navigationVC = [[UINavigationController new] initWithRootViewController:vc];
    [self presentViewController:navigationVC animated:YES completion:nil];
}

@end
