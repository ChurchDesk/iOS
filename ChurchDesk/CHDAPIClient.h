//
//  CHDAPIManager.h
//  ChurchDesk
//
//  Created by Mikkel Selsøe Sørensen on 20/02/15.
//  Copyright (c) 2015 Shape A/S. All rights reserved.
//

#import "SHPAPI.h"

@class CHDNotificationSettings;
@class CHDEvent;

@interface CHDAPIClient : SHPAPI

- (RACSignal*) loginWithUserName: (NSString*) username password: (NSString*) password;
- (RACSignal*) getCurrentUser;
- (RACSignal*) postResetPasswordForEmail: (NSString*) email accessToken:(NSString*) token;

- (RACSignal*) getEnvironment;

- (RACSignal*) getEventsFromYear: (NSInteger) year month: (NSInteger) month;
- (RACSignal*) getEventWithId:(NSNumber *)eventId siteId: (NSString*)siteId;
- (RACSignal*) createEventWithEvent: (CHDEvent*) event;
- (RACSignal*) updateEventWithEvent: (CHDEvent*) event;


- (RACSignal*) getInvitations;
- (RACSignal*) getHolidaysFromYear: (NSInteger) year;
- (RACSignal*) setResponseForEventWithId:(NSNumber *)eventId siteId: (NSString*)siteId response: (NSString *) response;
- (RACSignal*) createMessageWithTitle:(NSString*) title message:(NSString*) message siteId: (NSString*) siteId groupId:(NSNumber*) groupId;
- (RACSignal*) createCommentForMessageId:(NSNumber*) targetId siteId: (NSString*) siteId body:(NSString*) message;
- (RACSignal*) deleteCommentWithId: (NSNumber*) commentId siteId: (NSString*) siteId messageId: (NSNumber*) messageId;
- (RACSignal*) updateCommentWithId: (NSNumber*) commentId body:(NSString*) message siteId: (NSString*) siteId messageId: (NSNumber*) messageId;

- (RACSignal*) getUnreadMessages;
- (RACSignal*) getMessagesFromDate: (NSDate*) date limit: (NSInteger) limit;
- (RACSignal*) getMessagesFromDate: (NSDate*) date limit: (NSInteger) limit query: (NSString*) query;
- (RACSignal*) getMessageWithId:(NSNumber *)messageId siteId:(NSString*)siteId;
- (RACSignal*) setMessageAsRead:(NSNumber *)messageId siteId:(NSString*)siteId;

- (RACSignal*) getNotificationSettings;
- (RACSignal*) updateNotificationSettingsWithSettings: (CHDNotificationSettings *) settings;
- (RACSignal*) postDeviceToken: (NSString*) deviceToken;
- (RACSignal*) deleteDeviceToken: (NSString*) deviceToken accessToken: (NSString*)accessToken;

- (RACSignal*) clientAccessToken;

#pragma mark - ResourcePath for
- (NSString*) resourcePathForGetCurrentUser;
- (NSString*) resourcePathForGetEnvironment;
- (NSString*) resourcePathForGetEventsFromYear: (NSInteger) year month: (NSInteger) month;
- (NSString*) resourcePathForGetEvents;
- (NSString*) resourcePathForGetEventWithId:(NSNumber *)eventId siteId: (NSString*)siteId;

- (NSString*) resourcePathForGetInvitations;
- (NSString*) resourcePathForGetHolidaysFromYear: (NSInteger) year;

- (NSString*) resourcePathForGetUnreadMessages;
- (NSString*) resourcePathForGetMessagesFromDate;
- (NSString*) resourcePathForGetMessageWithId:(NSNumber *)messageId;
- (NSString*) resourcePathForGetNotificationSettings;
@end
