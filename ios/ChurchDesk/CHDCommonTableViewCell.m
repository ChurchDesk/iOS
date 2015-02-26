//
//  CHDCommonTableViewCell.m
//  ChurchDesk
//
//  Created by Mikkel Selsøe Sørensen on 26/02/15.
//  Copyright (c) 2015 Shape A/S. All rights reserved.
//

#import "CHDCommonTableViewCell.h"

CGFloat const kSideMargin = 15.0f;

@implementation CHDCommonTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if ((self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])) {
        self.backgroundColor = [UIColor whiteColor];
        
        UIView *lineView = [UIView new];
        lineView.backgroundColor = [UIColor chd_cellDividerColor];
        [self addSubview:lineView];
        [lineView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.right.equalTo(self);
            make.left.equalTo(self).offset(kSideMargin);
            make.height.equalTo(@1);
        }];
        
        RAC(lineView, hidden) = RACObserve(self, dividerLineHidden);
        
        UIImageView *disclosureArrow = [[UIImageView alloc] initWithImage:kImgDisclosureArrow];
        [self.contentView addSubview:disclosureArrow];
        [disclosureArrow mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(self.contentView).offset(-kSideMargin);
            make.centerY.equalTo(self.contentView);
        }];
        
        RAC(disclosureArrow, hidden) = RACObserve(self, disclosureArrowHidden);
    }
    return self;
}

@end
