//
//  CHDEventInternalNoteTableViewCell.h
//  ChurchDesk
//
//  Created by Mikkel Selsøe Sørensen on 02/03/15.
//  Copyright (c) 2015 Shape A/S. All rights reserved.
//

#import "CHDCommonTableViewCell.h"

@interface CHDEventInternalNoteTableViewCell : CHDCommonTableViewCell

@property (nonatomic, readonly) UILabel *noteLabel;
@property (nonatomic, readonly) UILabel *titleLabel;
@end
