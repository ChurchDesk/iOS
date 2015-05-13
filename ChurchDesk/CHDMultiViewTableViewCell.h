//
//  CHDMultiViewTableViewCell.h
//  ChurchDesk
//
//  Created by Mikkel Selsøe Sørensen on 02/03/15.
//  Copyright (c) 2015 Shape A/S. All rights reserved.
//

#import "CHDCommonTableViewCell.h"

@interface CHDMultiViewTableViewCell : CHDCommonTableViewCell

@property (nonatomic, readonly) UILabel *titleLabel;

- (void) setViewsForMatrix: (NSArray*) views;

@end
