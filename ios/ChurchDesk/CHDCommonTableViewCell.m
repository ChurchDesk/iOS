//
//  CHDCommonTableViewCell.m
//  ChurchDesk
//
//  Created by Mikkel Selsøe Sørensen on 26/02/15.
//  Copyright (c) 2015 Shape A/S. All rights reserved.
//

#import "CHDCommonTableViewCell.h"

CGFloat const kSideMargin = 15.0f;
CGFloat const kIndentedRightMargin = 30.0f;

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

        [self rac_liftSelector:@selector(setBackgroundColor:) withSignals:[RACObserve(self, disabled) map:^id(NSNumber *iDisabled) {
            return iDisabled.boolValue? [UIColor shpui_colorWithHexValue:0xcfcfcf] : [UIColor whiteColor];
        }], nil];

        [self rac_liftSelector:@selector(setSelectionStyle:) withSignals:[RACObserve(self, disabled) map:^id(NSNumber *iDisabled) {
            return iDisabled.boolValue? @(UITableViewCellSelectionStyleNone) : @(UITableViewCellSelectionStyleDefault);
        }], nil];

        RAC(disclosureArrow, alpha) = [RACObserve(self, disabled) map:^id(NSNumber *iDisabled) {
            return iDisabled.boolValue? @(0.5) : @(1);
        }];

        RAC(disclosureArrow, hidden) = RACObserve(self, disclosureArrowHidden);
    }
    return self;
}

- (void)prepareForReuse {
    self.disabled = NO;
}

@end
