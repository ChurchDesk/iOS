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
#import "CHDUser.h"
#import "CHDEnvironment.h"
#import "NSDate+ChurchDesk.h"

@interface CHDCalendarViewModel ()

@property (nonatomic, strong) NSArray *noneFilteredEvents;
@property (nonatomic, strong) NSArray *events;
@property (nonatomic, strong) NSArray *sections;
@property (nonatomic, strong) NSDictionary *sectionRows;
@property (nonatomic, strong) NSArray *holidays;
@property (nonatomic, strong) CHDUser *user;
@property (nonatomic, strong) CHDEnvironment *environment;

@end

@implementation CHDCalendarViewModel

- (instancetype)init {
    self = [super init];
    if (self) {
        [self rac_liftSelector:@selector(fetchEventsFromReferenceDate:) withSignals:[RACObserve(self, referenceDate) ignore:nil], nil];
        [self rac_liftSelector:@selector(setUser:) withSignals:[[CHDAPIClient sharedInstance] getCurrentUser], nil];
        [self rac_liftSelector:@selector(setEnvironment:) withSignals:[[CHDAPIClient sharedInstance] getEnvironment], nil];

        [[self shprac_liftSelector:@selector(filterEvents) withSignal:RACObserve(self, myEventsOnly)] skip:1];
        
    }
    return self;
}

- (void) filterEvents {
    self.events = @[];
    self.sectionRows = [[NSDictionary alloc] init];
    self.sections = @[];
    if(self.noneFilteredEvents.count > 0) {
        [self addEvents:self.noneFilteredEvents holidays:self.holidays];
    }
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
    
    //Listen for invalidation on the cache for the year month
    CHDAPIClient *apiClient = [CHDAPIClient sharedInstance];
    NSString *resoucePathMonth = [apiClient resourcePathForGetEventsFromYear:year month:month];
    NSString *resoucePathNextMonth = [apiClient resourcePathForGetEventsFromYear:nextMonthYear month:nextMonth];
    NSString *resoucePathPrevMonth = [apiClient resourcePathForGetEventsFromYear:prevMonthYear month:prevMonth];

    RACSignal *eventUpdateSignal = [[[apiClient.manager.cache rac_signalForSelector:@selector(invalidateObjectsMatchingRegex:)] filter:^BOOL(RACTuple *tuple) {
        NSString *regex = tuple.first;
        return ([regex rangeOfString:resoucePathMonth].location != NSNotFound || [regex rangeOfString:resoucePathNextMonth].location != NSNotFound || [regex rangeOfString:resoucePathPrevMonth].location != NSNotFound);
    }] flattenMap:^RACStream *(RACTuple *tuple) {
        NSString *regex = tuple.first;
        if([regex rangeOfString:resoucePathMonth].location != NSNotFound){
            return [[CHDAPIClient sharedInstance] getEventsFromYear:year month:month];
        }else if([regex rangeOfString:resoucePathNextMonth].location != NSNotFound){
            return [[CHDAPIClient sharedInstance] getEventsFromYear:nextMonthYear month:nextMonth];
        }else{
            return [[CHDAPIClient sharedInstance] getEventsFromYear:prevMonthYear month:prevMonth];
        }
    }];

    [self rac_liftSelector:@selector(addEvents:holidays:) withSignals:[RACSignal merge:@[eventsSignal, eventUpdateSignal]], holidaysSignal, nil];
}

- (void) addEvents:(NSArray *)events holidays: (NSArray*) holidays {

    if(events.count > 0) {
        NSMutableArray *mEvents = self.events ? [self.events mutableCopy] : [NSMutableArray arrayWithCapacity:events.count];
        NSMutableArray *mNoneFilteredEvents = self.noneFilteredEvents ? [self.noneFilteredEvents mutableCopy] : [NSMutableArray arrayWithCapacity:events.count];
        NSMutableDictionary *mSectionRows = [NSMutableDictionary new];

        [events enumerateObjectsUsingBlock:^(CHDEvent *event, NSUInteger idx, BOOL *stop) {
            BOOL usersEventsOnly = (self.myEventsOnly ? [event eventForUserWithId:[self.user userIdForSiteId:event.siteId]] : YES);
            if (![mEvents containsObject:event] && usersEventsOnly) {
                [mEvents addObject:event];
            }
            if (![mNoneFilteredEvents containsObject:event]) {
                [mNoneFilteredEvents addObject:event];
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
//            NSDateComponents *eventStartDateComps = [calendar components:NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay fromDate:event.startDate];
            NSDateComponents *eventEndDateComps = [calendar components:NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay fromDate:event.endDate];

            //Use a temporary eventDate to iterate over days in between start and end date
            __block NSDate *eventDate = nil;
            __block NSDateComponents *eventComps = nil;


            do{
                if(eventDate == nil){
                    eventDate = [event.startDate copy];
                    eventComps = [calendar components:NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay fromDate:eventDate];
                }

                if (eventComps.year != lastSectionComponents.year || eventComps.month != lastSectionComponents.month || eventComps.day != lastSectionComponents.day) {
                    if (section != nil) {
                        mSectionRows[section] = [mSectionEvents copy];
                    }

                    lastSectionComponents = eventComps;

                    section = [calendar dateFromComponents:eventComps];
                    [mSections addObject:section];

                    //get potential other event from this section to add to
                    mSectionEvents = mSectionRows[section] ? [NSMutableArray arrayWithArray:mSectionRows[section]] : [NSMutableArray array];
                }
                [mSectionEvents addObject:event];

                //Add a day to the event day (for events over multiple days)
                NSDate *tmpDate = [eventDate dateByAddingTimeInterval:60*60*24];
                eventDate = [tmpDate copy];
                eventComps = [calendar components:NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay fromDate:tmpDate];

            }while ([[calendar dateFromComponents:eventComps] compare:[calendar dateFromComponents:eventEndDateComps]] == NSOrderedAscending || [[calendar dateFromComponents:eventComps] compare:[calendar dateFromComponents:eventEndDateComps]] == NSOrderedSame);
        }

        if (section) {mSectionRows[section] = [mSectionEvents copy];}

        self.events = [mEvents copy];
        self.noneFilteredEvents = [mNoneFilteredEvents copy];
        self.sectionRows = [mSectionRows copy];
        self.sections = [mSections sortedArrayUsingComparator:^NSComparisonResult(NSDate *date1, NSDate *date2) {
            return [date1 compare:date2];
        }];
    }
    if(holidays.count > 0){
        if(self.holidays == nil){
            self.holidays = @[];
        }
        NSArray *holidaysToAdd = [holidays shp_filter:^BOOL(CHDHoliday *holiday) {
            return [self.holidays indexOfObject:holiday] == NSNotFound;
        }];

        self.holidays = [self.holidays arrayByAddingObjectsFromArray:holidaysToAdd];
    }
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
        
        if ((sectionComps.year == dateComps.year && sectionComps.month == dateComps.month && sectionComps.day == dateComps.day) || [date laterDate:section] == section || sectionIdx == self.sections.count-1) {
            return [NSIndexPath indexPathForRow:[self eventsForSectionAtIndex:sectionIdx].count > 0 ? 0 : NSNotFound inSection:sectionIdx];
        }
    };
    
    return nil;
}

// Colors for rows in section before indexPath
-(NSArray*) rowColorsForSectionBeforeIndexPath: (NSIndexPath *) indexPath sectionRect: (CGRect) sectionRect contentOffset: (CGPoint)contentOffset {
    NSMutableArray *hiddenEventsColors = [[NSMutableArray alloc] init];
    NSArray *eventsInSection = [self eventsForSectionAtIndex:indexPath.section];

    CGFloat visibleHeight = (sectionRect.origin.y + sectionRect.size.height) - contentOffset.y;
    CGFloat cellHeight = sectionRect.size.height / eventsInSection.count;

    //Show the color of the first cell if less than 35% of it is shown
    if( visibleHeight < ((cellHeight * 0.35) + cellHeight * (eventsInSection.count - 1)) && eventsInSection.count > 1) {
        NSRange range = NSMakeRange(0, indexPath.row + 1);
        NSArray *hiddenEvents = [eventsInSection subarrayWithRange:range];

        for (CHDEvent *event in hiddenEvents){
            CHDEventCategory *category = [self.environment eventCategoryWithId:event.eventCategoryIds.firstObject siteId: event.siteId];
        
            BOOL colorExists = [hiddenEventsColors indexOfObject:category.color] != NSNotFound;
    
            if (!colorExists && category.color) {
                [hiddenEventsColors addObject:category.color];
            }
        }
    }

    return [hiddenEventsColors copy];
}

- (NSString *)formattedTimeForEvent:(CHDEvent *)event referenceDate: (NSDate*) referenceDate {

    return [NSDate formattedTimeForEvent:event referenceDate:referenceDate];;
}

#pragma mark - private methods
- (BOOL)isDate:(NSDate *)date inRangeFirstDate:(NSDate *)firstDate lastDate:(NSDate *)lastDate {
    NSCalendar *calendar = [NSCalendar currentCalendar];
    unsigned unitFlags = NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear;

    NSDateComponents *dateComponents = [calendar components:unitFlags fromDate:date];
    NSDateComponents *firstDateComponents = [calendar components:unitFlags fromDate:firstDate];
    NSDateComponents *lastDateComponents = [calendar components:unitFlags fromDate:lastDate];

    BOOL first = dateComponents.day == firstDateComponents.day && dateComponents.month == firstDateComponents.month && dateComponents.year == firstDateComponents.year;
    BOOL last = dateComponents.day == lastDateComponents.day && dateComponents.month == lastDateComponents.month && dateComponents.year == lastDateComponents.year;

    return ([date compare:firstDate] == NSOrderedDescending && [date compare:lastDate]  == NSOrderedAscending) || first || last;
}

#pragma mark -CHDDayPicker delegate

- (BOOL)chdDayPickerEventsExistsOnDay:(NSDate *)date {
    NSIndexPath *indexPath = [self indexPathForDate:date];
    if(indexPath != nil) {
        NSArray *events = [[self eventsForSectionAtIndex:indexPath.section] shp_filter:^BOOL(CHDEvent *event) {
            return [self isDate:date inRangeFirstDate:event.startDate lastDate:event.endDate];
        }];
        NSUInteger eventsCount = events.count;
        return eventsCount > 0;
    }
    return NO;
}


@end
