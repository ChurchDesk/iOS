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
#import "CHDAuthenticationManager.h"

@interface CHDDashboardInvitationsViewModel ()

@property (nonatomic, strong) NSArray *invitations;
@property (nonatomic, strong) CHDEnvironment *environment;
@property (nonatomic, strong) CHDUser *user;

@end

@implementation CHDDashboardInvitationsViewModel

- (instancetype)init {
    self = [super init];
    if (self) {
        //Update signal
        CHDAPIClient *apiClient = [CHDAPIClient sharedInstance];

        RACSignal *updateSignal = [[[apiClient.manager.cache rac_signalForSelector:@selector(invalidateObjectsMatchingRegex:)] filter:^BOOL(RACTuple *tuple) {
            NSString *regex = tuple.first;
            NSString *resourcePath = [apiClient resourcePathForGetInvitations];
            return [regex rangeOfString:resourcePath].location != NSNotFound;
        }] flattenMap:^RACStream *(id value) {
            return [[[[CHDAPIClient sharedInstance] getInvitations] map:^id(NSArray* invitations) {
                RACSequence *results = [invitations.rac_sequence filter:^BOOL(CHDInvitation * invitation) {
                    return (CHDInvitationResponse)invitation.response == CHDInvitationNoAnswer;
                }];

                //newest on top
                return [results.array sortedArrayUsingComparator:^NSComparisonResult(CHDInvitation *invitation1, CHDInvitation *invitation2) {
                    return [invitation2.changeDate compare:invitation1.changeDate];
                }];
            }] catch:^RACSignal *(NSError *error) {
                return [RACSignal empty];
            }];
        }];

        RACSignal *authenticationTokenSignal = [RACObserve([CHDAuthenticationManager sharedInstance], authenticationToken) ignore:nil];

        RAC(self, invitations) = [RACSignal merge:@[[[[[CHDAPIClient sharedInstance] getInvitations] map:^id(NSArray* invitations) {
            RACSequence *results = [invitations.rac_sequence filter:^BOOL(CHDInvitation * invitation) {
                return (CHDInvitationResponse)invitation.response == CHDInvitationNoAnswer;
            }];

            //newest on top
            return [results.array sortedArrayUsingComparator:^NSComparisonResult(CHDInvitation *invitation1, CHDInvitation *invitation2) {
                return [invitation2.changeDate compare:invitation1.changeDate];
            }];
        }] catch:^RACSignal *(NSError *error) {
            return [RACSignal empty];
        }], updateSignal]];

        [self shprac_liftSelector:@selector(setEnvironment:) withSignal:[authenticationTokenSignal flattenMap:^RACStream *(id value) {
            return [[[CHDAPIClient sharedInstance] getEnvironment] catch:^RACSignal *(NSError *error) {
                return [RACSignal empty];
            }];
        }]];
        
        [self shprac_liftSelector:@selector(setUser:) withSignal:[authenticationTokenSignal flattenMap:^RACStream *(id value) {
            return [[[CHDAPIClient sharedInstance] getCurrentUser] catch:^RACSignal *(NSError *error) {
                return [RACSignal empty];
            }];
        }]];
        
        [self shprac_liftSelector:@selector(reload) withSignal:authenticationTokenSignal];
    }
    return self;
}

-(NSString*)getFormattedInvitationTimeFrom:(CHDInvitation *)invitation{
    NSCalendar *calendar = [NSCalendar currentCalendar];
    unsigned unitFlags = NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear;

    NSDateFormatter *dateFormatterFrom = [NSDateFormatter new];
    NSDateFormatter *dateFormatterTo = [NSDateFormatter new];

    NSDateComponents *fromComponents = [calendar components:unitFlags fromDate:invitation.startDate];
    NSDateComponents *toComponents = [calendar components:unitFlags fromDate:invitation.endDate];

    //Set date format Templates
    NSString *dateComponentFrom;
    NSString *dateComponentTo;

    if(fromComponents.year != toComponents.year){
        dateComponentFrom = invitation.allDay? @"ddMMM" : @"ddMMMjjmm";
        dateComponentTo = invitation.allDay? @"ddMMMYY" : @"ddMMMYYjjmm";
    }else if(fromComponents.month != toComponents.month){
        dateComponentFrom = invitation.allDay? @"eeeddMMM" : @"eeeddMMMjjmm";
        dateComponentTo = invitation.allDay? @"eeeddMMM" :@"eeeddMMMjjmm";
    }else if(fromComponents.day != toComponents.day){
        dateComponentFrom = invitation.allDay? @"eeeddMMM" : @"eeeddMMMjjmm";
        dateComponentTo = invitation.allDay? @"eeedd" : @"eeeddjjmm";
    }else{
        dateComponentFrom = invitation.allDay? @"eeeeddMMM" : @"eeeeddMMMjjmm";
        dateComponentTo = invitation.allDay? @"" : @"jjmm";
    }

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
    NSString *formattedDate = [endDate isEqualToString:@""]? startDate : [[startDate stringByAppendingString:@" - "] stringByAppendingString:endDate];

    return formattedDate;
}

-(BOOL) removeInvitationWithIndexPath:(NSIndexPath *) indexPath {
    NSInteger idx = indexPath.row;
    if(self.invitations.count < idx){return NO;}

    NSMutableArray *messages = [[NSMutableArray alloc] initWithArray:self.invitations];
    [messages removeObjectAtIndex:idx];

    self.invitations = [messages copy];
    return YES;
}

-(void) setInivationAccept:(CHDInvitation *) invitation {
    NSLog(@"Invitation id %@", invitation.invitationId);
    [[[[CHDAPIClient sharedInstance] setResponseForEventWithId:invitation.invitationId siteId:invitation.siteId response:CHDInvitationAccept] catch:^RACSignal *(NSError *error) {
        return [RACSignal empty];
    }] subscribeNext:^(id x) {
        NSLog(@"Success with id %@", x);
    } error:^(NSError *error) {
        
    }];
}

-(void) setInivationMaybe:(CHDInvitation *) invitation {
    [[[[CHDAPIClient sharedInstance] setResponseForEventWithId:invitation.invitationId siteId:invitation.siteId response:CHDInvitationMaybe] catch:^RACSignal *(NSError *error) {
        return [RACSignal empty];
    }] subscribeNext:^(id x) {
        NSLog(@"Success with id %@", x);
    } error:^(NSError *error) {

    }];
}

-(void) setInivationDecline:(CHDInvitation *) invitation {
    [[[[CHDAPIClient sharedInstance] setResponseForEventWithId:invitation.invitationId siteId:invitation.siteId response:CHDInvitationDecline] catch:^RACSignal *(NSError *error) {
        return [RACSignal empty];
    }] subscribeNext:^(id x) {
        NSLog(@"Success with id %@", x);
    } error:^(NSError *error) {

    }];
}

-(void) reload {
    CHDAPIClient *apiClient = [CHDAPIClient sharedInstance];
    [[[apiClient manager] cache] invalidateObjectsMatchingRegex:[apiClient resourcePathForGetInvitations]];
}

@end
