//
//  UITableView+ChurchDesk.m
//  ChurchDesk
//
//  Created by Mikkel Selsøe Sørensen on 04/03/15.
//  Copyright (c) 2015 Shape A/S. All rights reserved.
//

#import "UITableView+ChurchDesk.h"

@implementation UITableView (ChurchDesk)

- (NSIndexPath*) chd_indexPathForRowOrHeaderAtPoint: (CGPoint) point {
    NSIndexPath *indexPath = [self indexPathForRowAtPoint:point];
    if (!indexPath) {
        for (NSInteger sectionIdx = 0; sectionIdx < self.numberOfSections; sectionIdx++) {
            CGRect rect = [self rectForHeaderInSection:sectionIdx];
            if (CGRectContainsPoint(rect, point)) {
                indexPath = [NSIndexPath indexPathForItem:NSNotFound inSection:sectionIdx];
                break;
            }
        }
    }
    return indexPath;
}

@end
