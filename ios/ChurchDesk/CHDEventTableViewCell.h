//
//  CHDEventTableViewCell.h
//  ChurchDesk
//
//  Created by Jakob Vinther-Larsen on 18/02/15.
//  Copyright (c) 2015 Shape A/S. All rights reserved.
//

#import "CHDTableViewCell.h"

@interface CHDEventTableViewCell : CHDTableViewCell
@property (nonatomic, readonly) UILabel* titleLabel;
@property (nonatomic, readonly) UILabel*locationLabel;
@property (nonatomic, readonly) UILabel* dateTimeLabel;
@property (nonatomic, readonly) UILabel*parishLabel;
@end
