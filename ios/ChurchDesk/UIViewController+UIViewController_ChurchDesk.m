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

@implementation UIViewController (UIViewController_ChurchDesk)
- (CHDExpandableButtonView*) setupAddButton {
    return [self setupAddButtonWithView:self.view withConstraints:YES];
}
- (CHDExpandableButtonView*) setupAddButtonWithView: (UIView*) view withConstraints: (BOOL) setConstraints {
    CHDExpandableButtonView *actionButtonView = [CHDExpandableButtonView new];
    [view addSubview:actionButtonView];
    
    if(setConstraints){
    [actionButtonView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(view);
        make.bottom.equalTo(view).offset(-5);
    }];
    }
    
    [actionButtonView.addMessageButton addTarget:self action:@selector(newMessageShow:) forControlEvents:UIControlEventTouchUpInside];
    [actionButtonView.addEventButton addTarget:self action:@selector(newEventAction:) forControlEvents:UIControlEventTouchUpInside];
    
    return actionButtonView;
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

    RACSignal *saveSignal = [RACObserve(vc, event) skip:1];
    [self rac_liftSelector:@selector(dismissViewControllerAnimated:completion:) withSignals:[saveSignal mapReplace:@YES], [RACSignal return:nil], nil];
}

@end
