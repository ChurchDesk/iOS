//
//  CHDCalendarViewModel.h
//  ChurchDesk
//
//  Created by Mikkel Selsøe Sørensen on 03/03/15.
//  Copyright (c) 2015 Shape A/S. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CHDCalendarViewModel : NSObject

@property (nonatomic, readonly) NSArray *events;
@property (nonatomic, readonly) NSArray *sections;
@property (nonatomic, strong) NSDate *referenceDate;

- (instancetype)initWithReferenceDate: (NSDate*) referenceDate;

- (NSArray*) eventsForSectionAtIndex: (NSUInteger) section;

@end
