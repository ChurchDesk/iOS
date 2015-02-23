//
//  CHDSettingsTableViewCell.h
//  ChurchDesk
//
//  Created by Jakob Vinther-Larsen on 23/02/15.
//  Copyright (c) 2015 Shape A/S. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CHDSettingsTableViewCell : UITableViewCell
@property (nonatomic, readonly) UILabel* titleLabel;
@property (nonatomic, readonly) UISwitch *aSwitch;
@end
