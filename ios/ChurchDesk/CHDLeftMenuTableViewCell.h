//
//  CHDLeftMenuTableViewCell.h
//  ChurchDesk
//
//  Created by Jakob Vinther-Larsen on 20/02/15.
//  Copyright (c) 2015 Shape A/S. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SHPSideMenu.h"

@interface CHDLeftMenuTableViewCell : UITableViewCell
@property (nonatomic, readonly) UIImageView* thumbnailLeft;
@property (nonatomic, readonly) UILabel* titleLabel;
@property (nonatomic, strong) SHPSideMenuController* shp_sideMenuController;
@end
