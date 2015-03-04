//
//  CHDAPIManager.h
//  ChurchDesk
//
//  Created by Mikkel Selsøe Sørensen on 20/02/15.
//  Copyright (c) 2015 Shape A/S. All rights reserved.
//

#import "SHPAPI.h"

@interface CHDAPIClient : SHPAPI

- (RACSignal*)loginWithUserName: (NSString*) username password: (NSString*) password;
- (RACSignal*) getCurrentUser;

- (RACSignal*) getEnvironment;

- (RACSignal*) getEventsFromYear: (NSInteger) year month: (NSInteger) month;
- (RACSignal*) getEventWithId: (NSNumber*) eventId site: (NSString*) site;
- (RACSignal*) getInvitations;
- (RACSignal*) getHolidaysFromYear: (NSInteger) year;

- (RACSignal*) getUnreadMessages;
- (RACSignal*) retrieveMessageWithId:(NSNumber*)id site:(NSString*) site;
@end
