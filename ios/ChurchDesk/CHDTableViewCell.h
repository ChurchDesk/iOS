//
//  CHDTableViewCell.h
//  ChurchDesk
//
//  Created by Jakob Vinther-Larsen on 17/02/15.
//  Copyright (c) 2015 Shape A/S. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CHDCellBackgroundView.h"

@interface CHDTableViewCell : UITableViewCell
-(void) makeViews;
-(void) makeConstraints;
@property (nonatomic, readonly) CHDCellBackgroundView* cellBackgroundView;
@property (nonatomic, strong) UIColor *borderColor;

@end
