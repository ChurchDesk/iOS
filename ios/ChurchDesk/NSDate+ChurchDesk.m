//
// Created by Jakob Vinther-Larsen on 12/04/15.
// Copyright (c) 2015 Shape A/S. All rights reserved.
//

#import "NSDate+ChurchDesk.h"
#import "CHDEvent.h"


@implementation NSDate (ChurchDesk)
+ (NSString *)formattedTimeForEvent:(CHDEvent *)event {
    return [self formattedTimeForEvent:event referenceDate:[self date]];
}
+ (NSString *)formattedTimeForEvent:(CHDEvent *)event referenceDate: (NSDate*) referenceDate {

//    if(event.allDayEvent){
//        return NSLocalizedString(@"All day", @"");
//    }

    NSCalendar *calendar = [NSCalendar currentCalendar];
    unsigned unitFlags = NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear;
    NSLocale *locale = [NSLocale currentLocale];
    NSString *formattedDate = nil;
    NSDateFormatter *dateFormatterFrom = [NSDateFormatter new];
    NSDateFormatter *dateFormatterTo = [NSDateFormatter new];

    NSDateComponents *fromComponents = [calendar components:unitFlags fromDate:event.startDate];
    NSDateComponents *toComponents = [calendar components:unitFlags fromDate:event.endDate];
    NSDateComponents *todayComponents = [calendar components:unitFlags fromDate:referenceDate];

    //Set date format Templates
    NSString *dateComponentFrom = nil;
    NSString *dateComponentTo = nil;

    if(fromComponents.day != toComponents.day || fromComponents.month != toComponents.month || fromComponents.year != toComponents.year){
        //Multiple day event
        if(fromComponents.day == todayComponents.day){
            //We're on the start of the event
            if(!event.allDayEvent) {
                dateComponentFrom = @"jjmm";
            }
            dateComponentTo = @"ddMMM";
        }else if(toComponents.day == todayComponents.day){
            // we're on the end of the event
            dateComponentFrom = @"ddMMM";
            if(!event.allDayEvent) {
                dateComponentTo = @"jjmm";
            }
        }else{
            //We're in the middle of an event
            dateComponentTo = @"ddMMM";
        }
    }else{
        // Single day event
        if(event.allDayEvent){
            return NSLocalizedString(@"All day", @"");
        }
        dateComponentFrom = @"jjmm";
        dateComponentTo = @"jjmm";
    }

    NSString *startDate = NSLocalizedString(@"All day", @"");
    NSString *endDate = NSLocalizedString(@"All day", @"");

    //If components is not set, we have an all day event, and the all day should be shown instead (we're either in the start or middel of the event)
    if(dateComponentFrom) {
        NSString *dateTemplateFrom = [NSDateFormatter dateFormatFromTemplate:dateComponentFrom options:0 locale:locale];
        [dateFormatterFrom setDateFormat:dateTemplateFrom];

        //Localize the date
        dateFormatterFrom.locale = locale;
        startDate = [dateFormatterFrom stringFromDate:event.startDate];
    }
    //If components is not set, we have an all day event, and the all day should be shown instead (we're at the end of the event)
    if(dateComponentTo) {
        NSString *dateTemplateTo = [NSDateFormatter dateFormatFromTemplate:dateComponentTo options:0 locale:locale];
        [dateFormatterTo setDateFormat:dateTemplateTo];

        //Localize the date
        dateFormatterTo.locale = locale;
        endDate = [dateFormatterTo stringFromDate:event.endDate];
    }

    formattedDate = [endDate isEqualToString:@""]? startDate : [[startDate stringByAppendingString:@" - "] stringByAppendingString:endDate];

    return formattedDate;
}
@end