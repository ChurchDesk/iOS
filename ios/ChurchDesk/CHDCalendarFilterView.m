//
// Created by Jakob Vinther-Larsen on 20/03/15.
// Copyright (c) 2015 Shape A/S. All rights reserved.
//

#import "CHDCalendarFilterView.h"

@interface CHDCalendarFilterView()

@end

@implementation CHDCalendarFilterView

-(instancetype) init{
    self = [super init];
    if(self){
    }
    return self;
}

- (void) setupFiltersWithTitels: (NSArray*) titles filters: (NSArray*) filters {

    __block UIButton *prevFilterButton = nil;

    [titles enumerateObjectsUsingBlock:^(NSString *titleStr, NSUInteger idx, BOOL *stop) {
        UIButton *filterButton = [UIButton new];
        [filterButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        filterButton.titleLabel.font = [UIFont chd_fontWithFontWeight:CHDFontWeightRegular size:15];
        [filterButton setTitle:titleStr forState:UIControlStateNormal];
        [filterButton setContentEdgeInsets:UIEdgeInsetsMake(5, 11, 5, 11)];
        filterButton.layer.cornerRadius = 2.f;

        [self addSubview:filterButton];

        [filterButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(!prevFilterButton? self : prevFilterButton.mas_right).offset(!prevFilterButton? 15 : 3);
            make.bottom.equalTo(self).offset(-8);
        }];

        RACSignal *filterSelectedSignal = [RACObserve(self, selectedFilter) map:^id(NSNumber *iSelectedFilter) {
            NSNumber *filterValue = filters[idx];

            return @( [filterValue isEqualToNumber:iSelectedFilter]);
        }];

        RAC(filterButton, backgroundColor) = [filterSelectedSignal map:^id(NSNumber *iSelected) {
            return iSelected.boolValue? [UIColor chd_blueColor] : [UIColor clearColor];
        }];

        [self rac_liftSelector:@selector(setFilter:) withSignals:[[filterButton rac_signalForControlEvents:UIControlEventTouchUpInside] map:^id(id value) {
            return filters[idx];
        }], nil];

        prevFilterButton = filterButton;
    }];
}

-(void) setFilter: (NSNumber*) iFilter{
    self.selectedFilter = iFilter.unsignedIntegerValue;
}

@end