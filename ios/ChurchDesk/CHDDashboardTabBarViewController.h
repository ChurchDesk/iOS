//
//  CHDDashboardTabBarViewController.h
//  ChurchDesk
//
//  Created by Jakob Vinther-Larsen on 17/02/15.
//  Copyright (c) 2015 Shape A/S. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CHDDashboardTabBarViewController : UIViewController
+ (instancetype) dashboardTabBarViewController;

-(instancetype) initWithTabItems: (NSArray*) items;
@end
