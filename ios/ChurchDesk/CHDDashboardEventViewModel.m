//
// Created by Jakob Vinther-Larsen on 10/03/15.
// Copyright (c) 2015 Shape A/S. All rights reserved.
//

#import "CHDDashboardEventViewModel.h"
#import "CHDAPIClient.h"
#import "CHDEvent.h"
#import "CHDUser.h"
#import "CHDEnvironment.h"

@interface CHDDashboardEventViewModel()
@property (nonatomic, strong) CHDUser *user;
@property (nonatomic, strong) NSArray *events;
@property (nonatomic, strong) CHDEnvironment *environment;

@property (nonatomic) NSInteger year;
@property (nonatomic) NSInteger month;
@end

@implementation CHDDashboardEventViewModel

- (instancetype)init {
    self = [super init];
    if (self) {
        NSDate *referenceDate = [NSDate new];
        NSCalendar *calendar = [NSCalendar currentCalendar];
        NSInteger year = self.year = [calendar component:NSCalendarUnitYear fromDate:referenceDate];
        NSInteger month = self.month = [calendar component:NSCalendarUnitMonth fromDate:referenceDate];
        NSInteger today = [calendar component:NSCalendarUnitDay fromDate:referenceDate];

        //Initial signal
        RACSignal *initialSignal = [[[[CHDAPIClient sharedInstance] getEventsFromYear:year month:month] map:^id(NSArray* events) {
                RACSequence *results = [events.rac_sequence filter:^BOOL(CHDEvent* event) {
                    NSInteger compareDay = [calendar component:NSCalendarUnitDay fromDate:event.startDate];
                    return compareDay == today;
                }];
                return results.array;
            }] catch:^RACSignal *(NSError *error) {
                return [RACSignal empty];
            }];
        
        //Update signal
        CHDAPIClient *apiClient = [CHDAPIClient sharedInstance];

        RACSignal *updateSignal = [[[apiClient.manager.cache rac_signalForSelector:@selector(invalidateObjectsMatchingRegex:)] filter:^BOOL(RACTuple *tuple) {
            NSString *regex = tuple.first;
            NSString *resourcePath = [apiClient resourcePathForGetEventsFromYear:year month:month];
            return [regex rangeOfString:resourcePath].location != NSNotFound;
        }] flattenMap:^RACStream *(id value) {
            return [[[[CHDAPIClient sharedInstance] getEventsFromYear:year month:month] map:^id(NSArray* events) {
                RACSequence *results = [events.rac_sequence filter:^BOOL(CHDEvent* event) {
                    NSInteger compareDay = [calendar component:NSCalendarUnitDay fromDate:event.startDate];
                    return compareDay == today;
                }];
                return results.array;
            }] catch:^RACSignal *(NSError *error) {
                return [RACSignal empty];
            }];
        }];

        RAC(self, events) = [RACSignal merge:@[initialSignal, updateSignal]];

        RAC(self, user) = [[[CHDAPIClient sharedInstance] getCurrentUser] catch:^RACSignal *(NSError *error) {
            return [RACSignal empty];
        }];

        RAC(self, environment) = [[[CHDAPIClient sharedInstance] getEnvironment] catch:^RACSignal *(NSError *error) {
            return [RACSignal empty];
        }];
    }
    return self;
}

- (NSString *)formattedTimeForEvent:(CHDEvent *)event {

    if(event.allDayEvent){
        return NSLocalizedString(@"All day", @"");
    }

    NSDateFormatter *dateFormatterFrom = [NSDateFormatter new];
    NSDateFormatter *dateFormatterTo = [NSDateFormatter new];
    NSLocale *locale = [NSLocale currentLocale];
    NSString *dateTemplateFrom = [NSDateFormatter dateFormatFromTemplate:@"HHmm" options:0 locale:locale];
    NSString *dateTemplateTo = [NSDateFormatter dateFormatFromTemplate:@"HHmm" options:0 locale:locale];

    [dateFormatterFrom setDateFormat:dateTemplateFrom];
    [dateFormatterTo setDateFormat:dateTemplateTo];
    //Localize the date
    dateFormatterFrom.locale = locale;
    dateFormatterTo.locale = locale;

    NSString *startDate = [dateFormatterFrom stringFromDate:event.startDate];
    NSString *endDate = [dateFormatterTo stringFromDate:event.endDate];
    return [endDate isEqualToString:@""]? startDate : [[startDate stringByAppendingString:@" - "] stringByAppendingString:endDate];
}

- (void)reload {
    CHDAPIClient *apiClient = [CHDAPIClient sharedInstance];
    NSString *resoursePath = [apiClient resourcePathForGetEventsFromYear:self.year month:self.month];
    [[[apiClient manager] cache] invalidateObjectsMatchingRegex:resoursePath];
}


@end