//
//  CHDAPIManager.h
//  ChurchDesk
//
//  Created by Mikkel Selsøe Sørensen on 20/02/15.
//  Copyright (c) 2015 Shape A/S. All rights reserved.
//

#import "SHPAPI.h"

@interface CHDAPIClient : SHPAPI

- (RACSignal*) getEnvironment;

- (RACSignal*) getEventWithId: (NSNumber*) eventId site: (NSString*) site;
- (RACSignal*) getInvitations;

- (RACSignal*) getUnreadMessages;

@end
