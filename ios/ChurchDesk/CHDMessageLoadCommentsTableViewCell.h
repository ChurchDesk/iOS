//
//  CHDMessageLoadCommentsTableViewCell.h
//  ChurchDesk
//
//  Created by Jakob Vinther-Larsen on 25/02/15.
//  Copyright (c) 2015 Shape A/S. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CHDTableViewCell.h"

@interface CHDMessageLoadCommentsTableViewCell : CHDTableViewCell
@property (nonatomic, readonly) UILabel* messageLabel;
@property (nonatomic, readonly) UILabel* countLabel;
@end
