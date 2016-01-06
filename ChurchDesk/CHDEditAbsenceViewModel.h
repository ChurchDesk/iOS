//
//  CHDEditAbsenceViewModel.h
//  ChurchDesk
//
//  Created by Chirag Sharma on 22/12/15.
//  Copyright © 2015 Shape A/S. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString *const CHDAbsenceEditSectionDate;
extern NSString *const CHDAbsenceEditSectionRecipients;
extern NSString *const CHDAbsenceEditSectionBooking;
extern NSString *const CHDAbsenceEditSectionSubstitute;
extern NSString *const CHDAbsenceEditSectionComments;
extern NSString *const CHDAbsenceEditSectionMisc;
extern NSString *const CHDAbsenceEditSectionDivider;

extern NSString *const CHDAbsenceEditRowTitle;
extern NSString *const CHDAbsenceEditRowAllDay;
extern NSString *const CHDAbsenceEditRowStartDate;
extern NSString *const CHDAbsenceEditRowEndDate;
extern NSString *const CHDAbsenceEditRowParish;
extern NSString *const CHDAbsenceEditRowGroup;
extern NSString *const CHDAbsenceEditRowCategories;
extern NSString *const CHDAbsenceEditRowLocation;
extern NSString *const CHDAbsenceEditRowResources;
extern NSString *const CHDAbsenceEditRowUsers;
extern NSString *const CHDAbsenceEditRowSubstitute;
extern NSString *const CHDAbsenceEditRowComments;
extern NSString *const CHDAbsenceEditRowContributor;
extern NSString *const CHDAbsenceEditRowPrice;
extern NSString *const CHDAbsenceEditRowDoubleBooking;
extern NSString *const CHDAbsenceEditRowVisibility;

extern NSString *const CHDAbsenceEditRowDivider;

@class CHDEvent, CHDEnvironment, CHDUser;

@interface CHDEditAbsenceViewModel : NSObject

@property (nonatomic, strong) CHDEvent *event;
@property (nonatomic, readonly) BOOL newEvent;
@property (nonatomic, readonly) CHDEnvironment *environment;
@property (nonatomic, readonly) CHDUser *user;
@property (nonatomic, readonly) NSDictionary *sectionRows;
@property (nonatomic, readonly) NSArray *sections;
@property (nonatomic, readonly) RACCommand *saveCommand;
- (instancetype)initWithEvent: (CHDEvent*) event;

- (NSString*) formatDate: (NSDate*) date allDay: (BOOL) isAllday;

- (NSArray*)rowsForSectionAtIndex: (NSInteger) section;

- (RACSignal*) saveEvent;

@end
