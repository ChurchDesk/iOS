//
//  CHDEventSwitchTableViewCell.m
//  ChurchDesk
//
//  Created by Mikkel Selsøe Sørensen on 11/03/15.
//  Copyright (c) 2015 Shape A/S. All rights reserved.
//

#import "CHDEventSwitchTableViewCell.h"

@interface CHDEventSwitchTableViewCell ()

@property (nonatomic, strong) UISwitch *valueSwitch;

@end

@implementation CHDEventSwitchTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if ((self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])) {
        self.valueSwitch = [UISwitch new];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.disclosureArrowHidden = YES;
        
        [self.contentView addSubview:self.valueSwitch];
        [self.valueSwitch mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self.contentView);
            make.right.equalTo(self.contentView).offset(-kSideMargin);
        }];
    }
    return self;
}

@end
