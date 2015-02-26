//
//  CHDEvent.h
//  ChurchDesk
//
//  Created by Mikkel Selsøe Sørensen on 26/02/15.
//  Copyright (c) 2015 Shape A/S. All rights reserved.
//

#import "CHDManagedModel.h"

typedef NS_ENUM(NSUInteger, CHDEventResponse) {
    CHDEventResponseNone,
    CHDEventResponseGoing,
    CHDEventResponseNotGoing,
    CHDEventResponseMaybe,
};

@interface CHDEvent : CHDManagedModel

@property (nonatomic, strong) NSNumber *eventId;
@property (nonatomic, strong) NSString *site;
@property (nonatomic, strong) NSNumber *authorId;
@property (nonatomic, strong) NSNumber *groupId;
@property (nonatomic, strong) NSArray *eventCategoryIds;

@property (nonatomic, assign) BOOL publicEvent;
@property (nonatomic, assign) BOOL allDayEvent;

@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *eventDescription;
@property (nonatomic, strong) NSString *internalNote;
@property (nonatomic, strong) NSString *location;
@property (nonatomic, strong) NSString *price;
@property (nonatomic, strong) NSString *contributor;
@property (nonatomic, strong) NSURL *pictureURL;

@property (nonatomic, assign) CHDEventResponse eventResponse;
@property (nonatomic, assign) BOOL canEdit;
@property (nonatomic, assign) BOOL canDelete;

@property (nonatomic, strong) NSDate *creationDate;
@property (nonatomic, strong) NSDate *startDate;
@property (nonatomic, strong) NSDate *endDate;

@property (nonatomic, strong) NSArray *resourceIds;
@property (nonatomic, strong) NSArray *userIds;

@end
