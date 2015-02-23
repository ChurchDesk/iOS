//
//  CHDCalendarHeaderView.m
//  ChurchDesk
//
//  Created by Mikkel Selsøe Sørensen on 23/02/15.
//  Copyright (c) 2015 Shape A/S. All rights reserved.
//

#import "CHDCalendarHeaderView.h"
#import "CHDDotView.h"

@interface CHDCalendarHeaderView ()

@property (nonatomic, strong) UILabel *dayLabel;
@property (nonatomic, strong) UILabel *dateLabel;
@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UIView *dotsContainer;

@end

@implementation CHDCalendarHeaderView

- (instancetype)initWithReuseIdentifier:(NSString *)reuseIdentifier {
    if ((self = [super initWithReuseIdentifier:reuseIdentifier])) {
        self.contentView.backgroundColor = [UIColor chd_greyColor];
        
        [self setupSubviews];
        [self makeConstraints];
        [self rac_liftSelector:@selector(configureDotsWithColors:) withSignalsFromArray:@[RACObserve(self, dotColors)]];
    }
    return self;
}

- (void) setupSubviews {
    [self.contentView addSubview:self.dayLabel];
    [self.contentView addSubview:self.dateLabel];
    [self.contentView addSubview:self.nameLabel];
    [self.contentView addSubview:self.dotsContainer];
}

- (void) makeConstraints {
    [self.dayLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView).offset(14);
        make.centerY.equalTo(self.contentView);
    }];
    
    [self.dateLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.dayLabel.mas_right).offset(5);
        make.centerY.equalTo(self.contentView);
    }];
    
    [self.nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.dotsContainer.mas_left);
        make.centerY.equalTo(self.contentView);
    }];
    
    [self.dotsContainer mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.contentView).offset(-8);
        make.centerY.equalTo(self.contentView);
    }];
}

- (void) configureDotsWithColors: (NSArray*) colors {
    [self.dotsContainer.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    UIView *previousView = nil;
    for (UIColor *color in colors) {
        CHDDotView *dotView = [CHDDotView new];
        dotView.dotColor = color;
        
        [self.dotsContainer addSubview:dotView];
        [dotView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.bottom.equalTo(self.dotsContainer);
            make.left.equalTo(previousView ? previousView.mas_right : self.dotsContainer).offset(previousView ? 4 : 7);
            make.size.equalTo([NSValue valueWithCGSize:CGSizeMake(8, 8)]);
            
            if (color == colors.lastObject) {
                make.right.equalTo(self.dotsContainer);
            }
        }];
        
        previousView = dotView;
    }
}

#pragma mark - Lazy Initialization

- (UILabel *)dayLabel {
    if (!_dayLabel) {
        _dayLabel = [UILabel chd_boldLabelWithSize:14];
    }
    return _dayLabel;
}

- (UILabel *)dateLabel {
    if (!_dateLabel) {
        _dateLabel = [UILabel chd_regularLabelWithSize:14];
    }
    return _dateLabel;
}

- (UILabel *)nameLabel {
    if (!_nameLabel) {
        _nameLabel = [UILabel chd_boldLabelWithSize:14];
    }
    return _nameLabel;
}

- (UIView *)dotsContainer {
    if (!_dotsContainer) {
        _dotsContainer = [UIView new];
    }
    return _dotsContainer;
}

@end
