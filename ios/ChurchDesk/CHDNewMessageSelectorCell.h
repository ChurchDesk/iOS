//
// Created by Jakob Vinther-Larsen on 27/02/15.
// Copyright (c) 2015 Shape A/S. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CHDCommonTableViewCell.h"


@interface CHDNewMessageSelectorCell : CHDCommonTableViewCell
@property (nonatomic, readonly) UILabel* titleLabel;
@property (nonatomic, readonly) UILabel* selectedLabel;
@end