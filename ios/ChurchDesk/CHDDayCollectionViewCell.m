//
//  CHDDayCollectionViewCell.m
//  ChurchDesk
//
//  Created by Mikkel Selsøe Sørensen on 25/02/15.
//  Copyright (c) 2015 Shape A/S. All rights reserved.
//

#import "CHDDayCollectionViewCell.h"
#import "CHDDotView.h"

@interface CHDDayCollectionViewCell ()

@property (nonatomic, strong) UILabel *weekdayLabel;
@property (nonatomic, strong) UILabel *dayLabel;
@property (nonatomic, strong) CHDDotView *dotView;

@end

@implementation CHDDayCollectionViewCell

- (instancetype)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
        [self setupSubviews];
        [self makeConstraints];
        [self setupBindings];
    }
    return self;
}

- (void)prepareForReuse {
    [super prepareForReuse];
    self.picked = NO;
}

- (void) setupSubviews {
    [self.contentView addSubview:self.weekdayLabel];
    [self.contentView addSubview:self.dayLabel];
    [self.contentView addSubview:self.dotView];
}

- (void) makeConstraints {
    [self.weekdayLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.contentView);
        make.top.equalTo(self.contentView).offset(6);
    }];
    
    [self.dayLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.contentView);
        make.top.equalTo(self.contentView).offset(19);
    }];
    
    [self.dotView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.contentView);
        make.bottom.equalTo(self.contentView).offset(-5);
        make.size.equalTo([NSValue valueWithCGSize:CGSizeMake(5, 5)]);
    }];
}

- (void) setupBindings {
    RACSignal *pickedSignal = RACObserve(self, picked);
    
    RAC(self, backgroundColor) = [pickedSignal map:^id(NSNumber *nPicked) {
        return nPicked.boolValue ? [UIColor chd_blueColor] : [UIColor chd_greyColor];
    }];
    
    RAC(self.dotView, dotColor) = [pickedSignal map:^id(NSNumber *nPicked) {
        return nPicked.boolValue ? [UIColor whiteColor] : [UIColor shpui_colorWithHexValue:0xb0b0b0];
    }];
    
    RAC(self.weekdayLabel, textColor) = [pickedSignal map:^id(NSNumber *nPicked) {
        return nPicked.boolValue ? [UIColor whiteColor] : [UIColor chd_textDarkColor];
    }];
    
    RAC(self.dayLabel, textColor) = [pickedSignal map:^id(NSNumber *nPicked) {
        return nPicked.boolValue ? [UIColor whiteColor] : [UIColor chd_textDarkColor];
    }];

}

#pragma mark - Lazy Initialization

- (UILabel *)weekdayLabel {
    if (!_weekdayLabel) {
        _weekdayLabel = [UILabel chd_regularLabelWithSize:13];
//        _weekdayLabel.highlightedTextColor = [UIColor whiteColor];
    }
    return _weekdayLabel;
}

- (UILabel *)dayLabel {
    if (!_dayLabel) {
        _dayLabel = [UILabel chd_mediumLabelWithSize:17];
//        _dayLabel.highlightedTextColor = [UIColor whiteColor];
    }
    return _dayLabel;
}

- (CHDDotView *)dotView {
    if (!_dotView) {
        _dotView = [CHDDotView new];
    }
    return _dotView;
}

@end
