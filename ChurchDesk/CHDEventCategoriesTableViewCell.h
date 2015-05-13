//
//  CHDEventCategoriesTableViewCell.h
//  ChurchDesk
//
//  Created by Mikkel Selsøe Sørensen on 02/03/15.
//  Copyright (c) 2015 Shape A/S. All rights reserved.
//

#import "CHDMultiViewTableViewCell.h"

@interface CHDEventCategoriesTableViewCell : CHDMultiViewTableViewCell

- (void) setCategoryTitles: (NSArray*) titles colors: (NSArray*) colors;

@end
