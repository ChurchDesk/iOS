//
//  CHDCalendarHeaderView.h
//  ChurchDesk
//
//  Created by Mikkel Selsøe Sørensen on 23/02/15.
//  Copyright (c) 2015 Shape A/S. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CHDCalendarHeaderView : UITableViewHeaderFooterView

@property (nonatomic, readonly) UILabel *dayLabel;
@property (nonatomic, readonly) UILabel *dateLabel;
@property (nonatomic, readonly) UILabel *nameLabel;
@property (nonatomic, strong) NSArray *dotColors;

@end
