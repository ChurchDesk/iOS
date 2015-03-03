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

@interface CHDCalendarViewModel ()

@property (nonatomic, strong) NSArray *events;
@property (nonatomic, strong) NSArray *sections;
@property (nonatomic, strong) NSDictionary *sectionRows;

@end

@implementation CHDCalendarViewModel

- (instancetype)initWithReferenceDate: (NSDate*) referenceDate {
    self = [super init];
    if (self) {
        _referenceDate = referenceDate;
        [self fetchEventsFromDate:referenceDate spanningInterval:60*60*24*30];
    }
    return self;
}

- (void) fetchEventsFromDate: (NSDate*) fromDate spanningInterval: (NSTimeInterval) interval {
    [self rac_liftSelector:@selector(addEvents:) withSignals:[[CHDAPIClient sharedInstance] getEventsFrom:fromDate to:[fromDate dateByAddingTimeInterval:interval]], nil];
}

- (void) addEvents:(NSArray *)events {
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
    NSMutableArray *mSections = [NSMutableArray array];
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
    self.sections = [mSections copy];
}

- (NSArray*) eventsForSectionAtIndex: (NSUInteger) section {
    return self.sectionRows[self.sections[section]];
}

@end
