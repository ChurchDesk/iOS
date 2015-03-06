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
    NSString *dateComponentFrom;
    NSString *dateComponentTo;

    // Use "jj" instead of "HH" to create a 01-12(am/pm) and 00-23 template
    // "jj" follows the local format
    if(fromComponents.year != toComponents.year){
        dateComponentFrom = @"eeeddMMMHHmm";
        dateComponentTo = @"eeeddMMMYYYYHHmm";
    }else if(fromComponents.month != toComponents.month){
        dateComponentFrom = @"eeeddMMMHHmm";
        dateComponentTo = @"eeeddMMMHHmm";
    }else if(fromComponents.day != toComponents.day){
        dateComponentFrom = @"eeeddMMMHHmm";
        dateComponentTo = @"eeeddHHmm";
    }else{
        dateComponentFrom = @"eeeeddMMMHHmm";
        dateComponentTo = @"HHmm";
    }

    //NSLocale *locale = [[NSLocale alloc] initWithLocaleIdentifier:@"da_DK"];
    NSLocale *locale = [NSLocale currentLocale];
    NSString *dateTemplateFrom = [NSDateFormatter dateFormatFromTemplate:dateComponentFrom options:0 locale:locale];
    NSString *dateTemplateTo = [NSDateFormatter dateFormatFromTemplate:dateComponentTo options:0 locale:locale];

    [dateFormatterFrom setDateFormat:dateTemplateFrom];
    [dateFormatterTo setDateFormat:dateTemplateTo];

    //Localize the date
    dateFormatterFrom.locale = locale;
    dateFormatterTo.locale = locale;
    
    NSString *startDate = [dateFormatterFrom stringFromDate:invitation.startDate];
    NSString *endDate = [dateFormatterTo stringFromDate:invitation.endDate];
    NSString *formattedDate = [[startDate stringByAppendingString:@" - "] stringByAppendingString:endDate];

    return formattedDate;
}

-(void) setInivationAccept:(CHDInvitation *) invitation {
    NSLog(@"Invitation id %@", invitation.invitationId);
    [[[[CHDAPIClient sharedInstance] setResponseForEventWithId:invitation.invitationId siteId:invitation.siteId response:CHDInvitationAccept] catch:^RACSignal *(NSError *error) {
        return [RACSignal empty];
    }] subscribeNext:^(id x) {
        NSLog(@"Success");
    } error:^(NSError *error) {
        
    }];
}

-(void) setInivationMaybe:(CHDInvitation *) invitation {
    [[[[CHDAPIClient sharedInstance] setResponseForEventWithId:invitation.invitationId siteId:invitation.siteId response:CHDInvitationMaybe] catch:^RACSignal *(NSError *error) {
        return [RACSignal empty];
    }] subscribeNext:^(id x) {
        NSLog(@"Success");
    } error:^(NSError *error) {

    }];
}

-(void) setInivationDecline:(CHDInvitation *) invitation {
    [[[[CHDAPIClient sharedInstance] setResponseForEventWithId:invitation.invitationId siteId:invitation.siteId response:CHDInvitationDecline] catch:^RACSignal *(NSError *error) {
        return [RACSignal empty];
    }] subscribeNext:^(id x) {
        NSLog(@"Success");
    } error:^(NSError *error) {

    }];
}

@end
