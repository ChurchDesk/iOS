//
//  CHDDashboardInvitationsViewModel.m
//  ChurchDesk
//
//  Created by Mikkel Selsøe Sørensen on 24/02/15.
//  Copyright (c) 2015 Shape A/S. All rights reserved.
//

#import "CHDDashboardInvitationsViewModel.h"
#import "CHDAPIClient.h"
#import "CHDEnvironment.h"
#import "CHDUser.h"
#import "CHDInvitation.h"

@interface CHDDashboardInvitationsViewModel ()

@property (nonatomic, strong) NSArray *invitations;
@property (nonatomic, strong) CHDEnvironment *environment;
@property (nonatomic, strong) CHDUser *user;

@end

@implementation CHDDashboardInvitationsViewModel

- (instancetype)init {
    self = [super init];
    if (self) {
        RAC(self, invitations) = [[[CHDAPIClient sharedInstance] getInvitations] catch:^RACSignal *(NSError *error) {
            return [RACSignal empty];
        }];

        RAC(self, environment) = [[[CHDAPIClient sharedInstance] getEnvironment] catch:^RACSignal *(NSError *error) {
            return [RACSignal empty];
        }];

        RAC(self, user) = [[[CHDAPIClient sharedInstance] getCurrentUser] catch:^RACSignal *(NSError *error) {
            return [RACSignal empty];
        }];
    }
    return self;
}

-(NSString*)getFormattedInvitationTimeFrom:(CHDInvitation *)invitation{
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    unsigned unitFlags = NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear;

    NSDateFormatter *dateFormatterFrom = [NSDateFormatter new];
    NSDateFormatter *dateFormatterTo = [NSDateFormatter new];

    NSDateComponents *fromComponents = [gregorian components:unitFlags fromDate:invitation.startDate];
    NSDateComponents *toComponents = [gregorian components:unitFlags fromDate:invitation.endDate];

    //Set date format Templates
    NSString *dateFormatTemplateFrom;
    NSString *dateFormatTemplateTo;

    if(fromComponents.year != toComponents.year){
        dateFormatTemplateFrom = @"eee dd MMM',' HH':'mm";
        dateFormatTemplateTo = @"eee dd MMM YYYY',' HH':'mm";
    }else if(fromComponents.month != toComponents.month){
        dateFormatTemplateFrom = @"eee dd MMM',' HH':'mm";
        dateFormatTemplateTo = @"eee dd MMM',' HH':'mm";
    }else if(fromComponents.day != toComponents.day){
        dateFormatTemplateFrom = @"eee dd MMM',' HH':'mm";
        dateFormatTemplateTo = @"eee dd',' HH':'mm";
    }else{
        dateFormatTemplateFrom = @"eeee dd MMM',' HH':'mm";
        dateFormatTemplateTo = @"HH':'mm";
    }

    [dateFormatterFrom setDateFormat:dateFormatTemplateFrom];
    [dateFormatterTo setDateFormat:dateFormatTemplateTo];

    //NSLocale *daLocal = [[NSLocale alloc] initWithLocaleIdentifier:@"da_DK"];

    //Localize the date
    dateFormatterFrom.locale = [NSLocale currentLocale];
    dateFormatterTo.locale = [NSLocale currentLocale];
    
    NSString *startDate = [dateFormatterFrom stringFromDate:invitation.startDate];
    NSString *endDate = [dateFormatterTo stringFromDate:invitation.endDate];
    NSString *formattedDate = [[startDate stringByAppendingString:@" - "] stringByAppendingString:endDate];

    return formattedDate;
}

@end
