//
//  UIBarButtonItem+UIBarButtonItem_ChurchDesk.m
//  ChurchDesk
//
//  Created by Jakob Vinther-Larsen on 20/02/15.
//  Copyright (c) 2015 Shape A/S. All rights reserved.
//

#import "UIBarButtonItem+UIBarButtonItem_ChurchDesk.h"

@implementation UIBarButtonItem (UIBarButtonItem_ChurchDesk)
+ (UIBarButtonItem*) chd_burgerWithTarget: (id)target action:(SEL)action{
  return [[UIBarButtonItem new] initWithImage:kImgBurgerMenu style:UIBarButtonItemStylePlain target:target action:action];
}
@end
