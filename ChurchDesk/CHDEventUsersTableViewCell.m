//
//  CHDEventUsersTableViewCell.m
//  ChurchDesk
//
//  Created by Mikkel Selsøe Sørensen on 02/03/15.
//  Copyright (c) 2015 Shape A/S. All rights reserved.
//

#import "CHDEventUsersTableViewCell.h"

@implementation CHDEventUsersTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if ((self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])) {
        self.titleLabel.text = NSLocalizedString(@"Users booked", @"");
    }
    return self;
}

- (void) setUserNames: (NSArray*) userNames {
    
    __block NSMutableArray *mViews = [NSMutableArray arrayWithCapacity:userNames.count];
    [userNames enumerateObjectsUsingBlock:^(NSString *name, NSUInteger idx, BOOL *stop) {
        UILabel *label = [UILabel chd_regularLabelWithSize:13];
        label.textColor = [UIColor chd_textLightColor];
        label.numberOfLines = 1;
        label.text = name;
        [mViews addObject:label];
    }];
    
    [self setViewsForMatrix:[mViews copy]];
}

@end
