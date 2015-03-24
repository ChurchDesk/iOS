//
//  CHDCalendarViewModel.h
//  ChurchDesk
//
//  Created by Mikkel Selsøe Sørensen on 03/03/15.
//  Copyright (c) 2015 Shape A/S. All rights reserved.
//

#import <Foundation/Foundation.h>

@class CHDUser, CHDHoliday;
@class CHDEnvironment;

@interface CHDCalendarViewModel : NSObject

@property (nonatomic, readonly) NSArray *events;
@property (nonatomic, readonly) NSArray *sections;
@property (nonatomic, strong) NSDate *referenceDate;
@property (nonatomic, readonly) CHDUser *user;
@property (nonatomic, readonly) CHDEnvironment *environment;

@property (nonatomic, assign) BOOL myEventsOnly;

- (NSArray*) eventsForSectionAtIndex: (NSUInteger) section;
- (CHDHoliday*) holidayForDate: (NSDate*) date;
- (NSIndexPath*) indexPathForDate: (NSDate*) date;

-(NSArray*) rowColorsForSectionBeforeIndexPath: (NSIndexPath *) indexPath sectionRect: (CGRect) sectionRect contentOffset: (CGPoint)contentOffset;
@end
