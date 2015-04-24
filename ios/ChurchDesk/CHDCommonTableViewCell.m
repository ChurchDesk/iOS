//
//  CHDCommonTableViewCell.m
//  ChurchDesk
//
//  Created by Mikkel Selsøe Sørensen on 26/02/15.
//  Copyright (c) 2015 Shape A/S. All rights reserved.
//

#import "CHDCommonTableViewCell.h"
#import "CHDCellBorderView.h"

CGFloat const kSideMargin = 15.0f;
CGFloat const kIndentedRightMargin = 30.0f;

@interface CHDCommonTableViewCell()
@property (nonatomic, strong) CHDCellBorderView* cellBackgroundView;
@end

@implementation CHDCommonTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if ((self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])) {
        self.backgroundColor = [UIColor whiteColor];

        [self insertSubview:self.cellBackgroundView atIndex:0];
        self.cellBackgroundView.backgroundColor = [UIColor whiteColor];
        [self.cellBackgroundView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self);
        }];

        [self shprac_liftSelector:@selector(lineViewHidden:) withSignal:RACObserve(self, dividerLineHidden)];

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

#pragma mark - Sub Views initialization

- (CHDCellBorderView *)cellBackgroundView {
    if (!_cellBackgroundView) {
        _cellBackgroundView = [CHDCellBorderView new];
        [_cellBackgroundView setLeftMargin:kSideMargin];
    }
    return _cellBackgroundView;
}

-(void)lineViewHidden: (BOOL) hidden {
     self.cellBackgroundView.hidden = hidden;
    if(!hidden) {
        [self.cellBackgroundView setNeedsDisplay];
    }
}

@end
