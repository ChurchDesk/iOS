//
// Created by Jakob Vinther-Larsen on 20/03/15.
// Copyright (c) 2015 Shape A/S. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface CHDCalendarFilterView : UIView
@property (nonatomic, assign) NSUInteger selectedFilter;

- (void) setupFiltersWithTitels: (NSArray*) titles filters: (NSArray*) filters;
@end