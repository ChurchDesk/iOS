//
//  CHDPeopleTabBarController.h
//  ChurchDesk
//
//  Created by Chirag Sharma on 15/03/16.
//  Copyright © 2016 Shape A/S. All rights reserved.
//

#import "CHDAbstractViewController.h"

@interface CHDPeopleTabBarController : CHDAbstractViewController
+ (instancetype) peopleTabBarViewController;

-(instancetype) initWithTabItems: (NSArray*) items;
- (void) notificationsForIndex: (NSUInteger) idx show: (BOOL) show;
@end
