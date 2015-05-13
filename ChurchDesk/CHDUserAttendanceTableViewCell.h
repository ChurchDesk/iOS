//
//  CHDUserAttendanceTableViewCell.h
//  ChurchDesk
//
//  Created by Mikkel Selsøe Sørensen on 26/03/15.
//  Copyright (c) 2015 Shape A/S. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CHDEvent.h"

@interface CHDUserAttendanceTableViewCell : UITableViewCell

@property (nonatomic, readonly) UIImageView *userImageView;
@property (nonatomic, readonly) UILabel *nameLabel;
@property (nonatomic, assign) CHDEventResponse status;
@property (nonatomic, assign) BOOL topLineHidden;
@property (nonatomic, assign) BOOL bottomLineFull;

@end
