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
@property (nonatomic, strong) UIView *lineView;

@property (nonatomic, strong) MASConstraint *dotViewWidthConstraint;

@end

@implementation CHDCalendarHeaderView

- (instancetype)initWithReuseIdentifier:(NSString *)reuseIdentifier {
    if ((self = [super initWithReuseIdentifier:reuseIdentifier])) {
        self.contentView.backgroundColor = [UIColor chd_greyColor];
        
        [self setupSubviews];
        [self makeConstraints];
        [self rac_liftSelector:@selector(configureDotsWithColors:) withSignalsFromArray:@[[[RACObserve(self, dotColors) combinePreviousWithStart:@[] reduce:^id(NSArray *previous, NSArray *current) {
            return RACTuplePack(previous, current);
        }] filter:^BOOL(RACTuple *value) {
            RACTupleUnpack(NSArray *previous, NSArray *current) = value;
            return ![current isEqualToArray:previous];
        }]]];
    }
    return self;
}

- (void) setupSubviews {
    [self.contentView addSubview:self.dayLabel];
    [self.contentView addSubview:self.dateLabel];
    [self.contentView addSubview:self.nameLabel];
    [self.contentView addSubview:self.dotsContainer];
    [self addSubview:self.lineView];
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
    
    [self.nameLabel setContentCompressionResistancePriority:UILayoutPriorityDefaultLow forAxis:UILayoutConstraintAxisHorizontal];
    [self.nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.dotsContainer.mas_left);
        make.left.greaterThanOrEqualTo(self.dateLabel.mas_right).offset(4).priorityLow();
        make.centerY.equalTo(self.contentView);
    }];
    
    [self.dotsContainer mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.contentView).offset(-8);
        self.dotViewWidthConstraint = make.width.equalTo(@0);
        make.centerY.equalTo(self.contentView);
    }];
    
    [self.lineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.left.right.equalTo(self);
        make.height.equalTo(@1);
    }];
}

-(void) configureDotsWithColors: (RACTuple *) tuple {
    RACTupleUnpack(NSArray* previousColors, NSArray* newColors) = tuple;
    [self.dotsContainer.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];

    UIView *previousView = nil;
    __block MASConstraint *lastRightConstraint = nil;
    __block MASConstraint *lastLeftConstraint = nil;
    for (UIColor *color in newColors) {
        CHDDotView *dotView = [CHDDotView new];
        dotView.dotColor = color;

        [self.dotsContainer addSubview:dotView];
        [dotView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.bottom.equalTo(self.dotsContainer);
            make.size.equalTo([NSValue valueWithCGSize:CGSizeMake(8, 8)]).priorityLow();

            if (color == newColors.lastObject) {
                lastRightConstraint = make.right.equalTo(self.dotsContainer).offset(newColors.count > previousColors.count? 16 : -8);
                lastLeftConstraint = make.left.equalTo(previousView ? previousView.mas_right : self.dotsContainer).offset(previousView ? 12 : 15).priorityLow();
            }else{
                make.left.equalTo(previousView ? previousView.mas_right : self.dotsContainer).offset(previousView ? 4 : 7).priorityLow();
            }
        }];

        previousView = dotView;
    }
    if(lastRightConstraint) {
        float colorCount = newColors.count;
        float dotViewWidth = colorCount * 8.f + (colorCount -1) * 4 + 7;
        [self layoutIfNeeded];
        self.dotViewWidthConstraint.offset( dotViewWidth );
        lastRightConstraint.offset(0);
        if(lastLeftConstraint) {
            lastLeftConstraint.offset(previousView ? 4 : 7);
        }
        [UIView animateWithDuration:0.3 delay:0 usingSpringWithDamping:3 initialSpringVelocity:6 options:0 animations:^{
            [self layoutIfNeeded];
        } completion:nil];
    }else{
        self.dotViewWidthConstraint.offset(0);
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

- (UIView *)lineView {
    if (!_lineView) {
        _lineView = [UIView new];
        _lineView.backgroundColor = [UIColor shpui_colorWithHexValue:0xececec];
    }
    return _lineView;
}

@end
