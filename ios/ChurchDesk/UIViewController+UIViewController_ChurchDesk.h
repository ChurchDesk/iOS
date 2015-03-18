//
//  UIViewController+UIViewController_ChurchDesk.h
//  ChurchDesk
//
//  Created by Jakob Vinther-Larsen on 18/03/15.
//  Copyright (c) 2015 Shape A/S. All rights reserved.
//

#import <UIKit/UIKit.h>
@class CHDExpandableButtonView;

@interface UIViewController (UIViewController_ChurchDesk)
- (void) setupAddButton;
- (void) newMessageShow: (id) sender;
- (void) newEventAction: (id) sender;
@end
