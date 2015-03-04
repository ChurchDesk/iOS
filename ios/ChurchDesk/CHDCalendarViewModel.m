//
//  CHDCalendarViewModel.m
//  ChurchDesk
//
//  Created by Mikkel Selsøe Sørensen on 03/03/15.
//  Copyright (c) 2015 Shape A/S. All rights reserved.
//

#import "CHDCalendarViewModel.h"
#import "CHDAPIClient.h"
#import "CHDEvent.h"
#import "CHDHoliday.h"

@interface CHDCalendarViewModel ()

@property (nonatomic, strong) NSArray *events;
@property (nonatomic, strong) NSArray *sections;
@property (nonatomic, strong) NSDictionary *sectionRows;
@property (nonatomic, strong) NSArray *holidays;

@end

@implementation CHDCalendarViewModel

- (instancetype)init {
    self = [super init];
    if (self) {
        [self rac_liftSelector:@selector(fetchEventsFromReferenceDate:) withSignals:[RACObserve(self, referenceDate) ignore:nil], nil];
    }
    return self;
}

- (void) fetchEventsFromReferenceDate: (NSDate*) referenceDate {
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDate *nextMonthDate = [calendar dateByAddingUnit:NSCalendarUnitMonth value:1 toDate:referenceDate options:0];
    NSDate *prevMonthDate = [calendar dateByAddingUnit:NSCalendarUnitMonth value:-1 toDate:referenceDate options:0];
    
    NSInteger year = [calendar component:NSCalendarUnitYear fromDate:referenceDate];
    NSInteger month = [calendar component:NSCalendarUnitMonth fromDate:referenceDate];

    NSInteger nextMonthYear = [calendar component:NSCalendarUnitYear fromDate:nextMonthDate];
    NSInteger nextMonth = [calendar component:NSCalendarUnitMonth fromDate:nextMonthDate];
    
    NSInteger prevMonthYear = [calendar component:NSCalendarUnitYear fromDate:prevMonthDate];
    NSInteger prevMonth = [calendar component:NSCalendarUnitMonth fromDate:prevMonthDate];
    
    RACSignal *eventsSignal = [RACSignal combineLatest:@[[[CHDAPIClient sharedInstance] getEventsFromYear:year month:month], [[CHDAPIClient sharedInstance] getEventsFromYear:nextMonthYear month:nextMonth], [[CHDAPIClient sharedInstance] getEventsFromYear:prevMonthYear month:prevMonth]] reduce:^id (NSArray* thisMonth, NSArray *nextMonth, NSArray *prevMonth) {
        return [[prevMonth arrayByAddingObjectsFromArray:thisMonth] arrayByAddingObjectsFromArray:nextMonth];
    }];
    
    NSMutableArray *holidaySignals = [NSMutableArray arrayWithCapacity:2];
    if (year != prevMonthYear) {
        [holidaySignals addObject:[[CHDAPIClient sharedInstance] getHolidaysFromYear:prevMonthYear]];
    }
    [holidaySignals addObject:[[CHDAPIClient sharedInstance] getHolidaysFromYear:prevMonthYear]];
    if (year != nextMonthYear) {
        [holidaySignals addObject:[[CHDAPIClient sharedInstance] getHolidaysFromYear:nextMonthYear]];
    }
    RACSignal *holidaysSignal = [[RACSignal combineLatest:holidaySignals] map:^id(RACTuple *tuple) {
        NSArray *holidays = @[];
        for (NSArray *holidaysArray in tuple) {
            holidays = [holidays arrayByAddingObjectsFromArray:holidaysArray];
        }
        return holidays;
    }];
    
    [self rac_liftSelector:@selector(addEvents:holidays:) withSignals:eventsSignal, holidaysSignal, nil];
}

- (void) addEvents:(NSArray *)events holidays: (NSArray*) holidays {
    NSMutableArray *mEvents = self.events ? [self.events mutableCopy] : [NSMutableArray arrayWithCapacity:events.count];
    NSMutableDictionary *mSectionRows = [NSMutableDictionary new];
    
    [events enumerateObjectsUsingBlock:^(CHDEvent *event, NSUInteger idx, BOOL *stop) {
        if (![mEvents containsObject:event]) {
            [mEvents addObject:event];
        }
    }];

    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *lastSectionComponents = nil;
    NSDate *section = nil;
    NSMutableOrderedSet *mSections = [NSMutableOrderedSet orderedSetWithArray:[holidays shp_map:^id(CHDHoliday *holiday) {
        return holiday.date;
    }]];
    NSMutableArray *mSectionEvents = [NSMutableArray array];
    for (CHDEvent *event in mEvents) {
        NSDateComponents *eventComps = [calendar components:NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay fromDate:event.startDate];
        
        if (eventComps.year != lastSectionComponents.year || eventComps.month != lastSectionComponents.month || eventComps.day != lastSectionComponents.day) {
            if (section != nil) {
                mSectionRows[section] = [mSectionEvents copy];
            }
            
            section = [calendar dateFromComponents:eventComps];
            [mSections addObject:section];
            mSectionEvents = [NSMutableArray array];
        }
        [mSectionEvents addObject:event];
    }
    mSectionRows[section] = [mSectionEvents copy];
    
    self.events = [mEvents copy];
    self.sectionRows = [mSectionRows copy];
    self.holidays = holidays;
    self.sections = [mSections sortedArrayUsingComparator:^NSComparisonResult(NSDate *date1, NSDate *date2) {
        return [date1 compare:date2];
    }];
}

- (NSArray*) eventsForSectionAtIndex: (NSUInteger) section {
    return self.sectionRows[self.sections[section]];
}

- (CHDHoliday*) holidayForDate: (NSDate*) date {
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *dateComps = [calendar components:NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay fromDate:date];
    
    return [self.holidays shp_detect:^BOOL(CHDHoliday *holiday) {
        NSDateComponents *holidayComps = [calendar components:NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay fromDate:holiday.date];
        
        return holidayComps.year == dateComps.year && holidayComps.month == dateComps.month && holidayComps.day == dateComps.day;
    }];
}

- (NSIndexPath*) indexPathForDate: (NSDate*) date {
    if (!date) {
        return nil;
    }
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *dateComps = [calendar components:NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay fromDate:date];
    
    for (NSUInteger sectionIdx = 0; sectionIdx < self.sections.count; sectionIdx++) {
        NSDate *section = self.sections[sectionIdx];
        NSDateComponents *sectionComps = [calendar components:NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay fromDate:section];
        
        if ((sectionComps.year == dateComps.year && sectionComps.month == dateComps.month && sectionComps.day == dateComps.day) || [date laterDate:section] == section) {
            return [NSIndexPath indexPathForRow:[self eventsForSectionAtIndex:sectionIdx].count > 0 ? 0 : NSNotFound inSection:sectionIdx];
        }
    };
    return nil;
}

@end
