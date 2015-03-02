//
//  CHDMultiViewCell.h
//  ChurchDesk
//
//  Created by Mikkel Selsøe Sørensen on 02/03/15.
//  Copyright (c) 2015 Shape A/S. All rights reserved.
//

#import "CHDCommonTableViewCell.h"

@interface CHDMultiViewCell : CHDCommonTableViewCell

@property (nonatomic, readonly) UILabel *titleLabel;

- (void) setViewsForMatrix: (NSArray*) views;

@end
