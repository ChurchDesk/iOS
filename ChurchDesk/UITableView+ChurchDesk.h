//
//  UITableView+ChurchDesk.h
//  ChurchDesk
//
//  Created by Mikkel Selsøe Sørensen on 04/03/15.
//  Copyright (c) 2015 Shape A/S. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UITableView (ChurchDesk)

- (NSIndexPath*) chd_indexPathForRowOrHeaderAtPoint: (CGPoint) point;

@end
