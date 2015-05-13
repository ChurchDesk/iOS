//
//  CHDSelectorTableViewCell.h
//  ChurchDesk
//
//  Created by Jakob Vinther-Larsen on 02/03/15.
//  Copyright (c) 2015 Shape A/S. All rights reserved.
//

#import "CHDCommonTableViewCell.h"

@interface CHDSelectorTableViewCell : CHDCommonTableViewCell
@property (nonatomic, assign) UIColor* dotColor;
@property (nonatomic, readonly) UILabel *titleLabel;
@end
