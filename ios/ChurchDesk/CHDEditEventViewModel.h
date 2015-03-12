//
//  CHDEditEventViewModel.h
//  ChurchDesk
//
//  Created by Mikkel Selsøe Sørensen on 06/03/15.
//  Copyright (c) 2015 Shape A/S. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString *const CHDEventEditSectionTitle;
extern NSString *const CHDEventEditSectionDate;
extern NSString *const CHDEventEditSectionRecipients;
extern NSString *const CHDEventEditSectionLocation;
extern NSString *const CHDEventEditSectionBooking;
extern NSString *const CHDEventEditSectionInternalNote;
extern NSString *const CHDEventEditSectionDescription;
extern NSString *const CHDEventEditSectionMisc;
extern NSString *const CHDEventEditSectionDivider;

extern NSString *const CHDEventEditRowTitle;
extern NSString *const CHDEventEditRowStartDate;
extern NSString *const CHDEventEditRowEndDate;
extern NSString *const CHDEventEditRowParish;
extern NSString *const CHDEventEditRowGroup;
extern NSString *const CHDEventEditRowCategories;
extern NSString *const CHDEventEditRowLocation;
extern NSString *const CHDEventEditRowResources;
extern NSString *const CHDEventEditRowUsers;
extern NSString *const CHDEventEditRowInternalNote;
extern NSString *const CHDEventEditRowDescription;
extern NSString *const CHDEventEditRowContributor;
extern NSString *const CHDEventEditRowPrice;
extern NSString *const CHDEventEditRowDoubleBooking;
extern NSString *const CHDEventEditRowVisibility;

extern NSString *const CHDEventEditRowDivider;

@class CHDEvent, CHDEnvironment, CHDUser;

@interface CHDEditEventViewModel : NSObject

@property (nonatomic, strong) CHDEvent *event;
@property (nonatomic, readonly) BOOL newEvent;
@property (nonatomic, readonly) CHDEnvironment *environment;
@property (nonatomic, readonly) CHDUser *user;
@property (nonatomic, readonly) NSArray *sections;
@property (nonatomic, readonly) RACCommand *saveCommand;

- (instancetype)initWithEvent: (CHDEvent*) event;

- (NSArray*)rowsForSectionAtIndex: (NSInteger) section;

- (RACSignal*) saveEvent;

@end
