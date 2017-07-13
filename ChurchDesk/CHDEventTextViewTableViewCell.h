//
//  CHDEventTextViewTableViewCell.h
//  ChurchDesk
//
//  Created by Mikkel Selsøe Sørensen on 09/03/15.
//  Copyright (c) 2015 Shape A/S. All rights reserved.
//

#import "CHDEventInfoTableViewCell.h"

@interface CHDEventTextViewTableViewCell : UITableViewCell

@property (nonatomic, readonly) UITextView *textView;
@property (nonatomic, strong) NSString *placeholder;
@property (nonatomic, weak) UITableView *tableView;
@property (nonatomic, readonly) UIImageView *iconImageView;
@end
