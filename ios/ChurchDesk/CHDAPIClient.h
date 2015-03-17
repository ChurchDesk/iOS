//
//  CHDAPIManager.h
//  ChurchDesk
//
//  Created by Mikkel Selsøe Sørensen on 20/02/15.
//  Copyright (c) 2015 Shape A/S. All rights reserved.
//

#import "SHPAPI.h"

@class CHDNotificationSettings;

@interface CHDAPIClient : SHPAPI

- (RACSignal*)loginWithUserName: (NSString*) username password: (NSString*) password;
- (RACSignal*) getCurrentUser;

- (RACSignal*) getEnvironment;

- (RACSignal*) getEventsFromYear: (NSInteger) year month: (NSInteger) month;
- (RACSignal*)getEventWithId:(NSNumber *)eventId siteId: (NSString*)siteId;
- (RACSignal*)createEventWithDictionary: (NSDictionary*) eventDictionary;
- (RACSignal*)updateEventWithId: (NSNumber*) eventId siteId: (NSString*) siteId dictionary: (NSDictionary*) eventDictionary;


- (RACSignal*) getInvitations;
- (RACSignal*) getHolidaysFromYear: (NSInteger) year;
- (RACSignal*) setResponseForEventWithId:(NSNumber *)eventId siteId: (NSString*)siteId response: (NSInteger) response;
- (RACSignal*) createMessageWithTitle:(NSString*) title message:(NSString*) message siteId: (NSString*) siteId groupId:(NSNumber*) groupId;
- (RACSignal*) createCommentForMessageId:(NSNumber*) targetId siteId: (NSString*) siteId body:(NSString*) message;

- (RACSignal*) getUnreadMessages;
- (RACSignal*) getMessagesFromDate: (NSDate*) date limit: (NSInteger) limit;
- (RACSignal*)getMessageWithId:(NSNumber *)messageId siteId:(NSString*)siteId;
- (RACSignal*)setMessageAsRead:(NSNumber *)messageId siteId:(NSString*)siteId;

- (RACSignal*) getNotificationSettings;
- (RACSignal*) updateNotificationSettingsWithSettings: (CHDNotificationSettings *) settings;

- (NSString*)resourcePathForGetMessageWithId:(NSNumber *)messageId;
- (NSString*)resourcePathForGetUnreadMessages;
@end
