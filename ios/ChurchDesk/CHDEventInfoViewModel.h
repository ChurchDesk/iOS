//
//  CHDEventInfoViewModel.h
//  ChurchDesk
//
//  Created by Mikkel Selsøe Sørensen on 26/02/15.
//  Copyright (c) 2015 Shape A/S. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CHDEvent.h"

extern NSString *const CHDEventInfoSectionImage;
extern NSString *const CHDEventInfoSectionBase;
extern NSString *const CHDEventInfoSectionResources;
extern NSString *const CHDEventInfoSectionContribution;
extern NSString *const CHDEventInfoSectionVisibility;
extern NSString *const CHDEventInfoSectionDivider;

extern NSString *const CHDEventInfoRowImage;
extern NSString *const CHDEventInfoRowGroup;
extern NSString *const CHDEventInfoRowDate;
extern NSString *const CHDEventInfoRowLocation;
extern NSString *const CHDEventInfoRowCategories;
extern NSString *const CHDEventInfoRowAttendance;
extern NSString *const CHDEventInfoRowResources;
extern NSString *const CHDEventInfoRowUsers;
extern NSString *const CHDEventInfoRowInternalNote;
extern NSString *const CHDEventInfoRowContributor;
extern NSString *const CHDEventInfoRowPrice;
extern NSString *const CHDEventInfoRowDescription;
extern NSString *const CHDEventInfoRowVisibility;
extern NSString *const CHDEventInfoRowCreated;
extern NSString *const CHDEventInfoRowDivider;

@class CHDEnvironment, CHDUser;

@interface CHDEventInfoViewModel : NSObject

@property (nonatomic, readonly) NSArray *sections;
@property (nonatomic, strong) CHDEvent *event;
@property (nonatomic, readonly) CHDEnvironment *environment;
@property (nonatomic, readonly) CHDUser *user;

- (instancetype)initWithEvent: (CHDEvent*) event;

- (NSArray*) rowsForSection: (NSString*) section;

- (NSString*) textForEventResponse: (CHDEventResponse) response;
- (UIColor*) textColorForEventResponse: (CHDEventResponse) response;

- (NSString*) eventDateString;
- (NSString*) parishName;
- (NSArray*) categoryTitles;
- (NSArray*) categoryColors;
- (NSArray*) resourceTitles;
- (NSArray*) resourceColors;
- (NSArray*) userNames;

- (void) openMapsWithLocationString: (NSString*) location;
@end
