//
//  CHDEventCategoriesTableViewCell.m
//  ChurchDesk
//
//  Created by Mikkel Selsøe Sørensen on 02/03/15.
//  Copyright (c) 2015 Shape A/S. All rights reserved.
//

#import "CHDEventCategoriesTableViewCell.h"
#import "CHDColorDotLabelView.h"

@implementation CHDEventCategoriesTableViewCell

- (void) setCategoryTitles: (NSArray*) titles colors: (NSArray*) colors {
    
    __block NSMutableArray *mViews = [NSMutableArray arrayWithCapacity:titles.count];
    [titles enumerateObjectsUsingBlock:^(NSString *title, NSUInteger idx, BOOL *stop) {
        CHDColorDotLabelView *view = [CHDColorDotLabelView new];
        view.title = title;
        view.color = colors.count > idx? colors[idx] : nil;
        [mViews addObject:view];
    }];
    
    [self setViewsForMatrix:[mViews copy]];
}

@end
