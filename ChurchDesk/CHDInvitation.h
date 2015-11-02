//
//  CHDInvitation.h
//  ChurchDesk
//
//  Created by Mikkel Selsøe Sørensen on 24/02/15.
//  Copyright (c) 2015 Shape A/S. All rights reserved.
//

#import "CHDManagedModel.h"

/*
 {
 "id": 1098,
 "siteId": "http://hado.kw01.net",
 "title": "Højmesse",
 "eventCategoryId": 32,
 "allDay": false,
 "startDate": "2014-09-15T15:52:01+0000",
 "endDate": "2014-09-17T15:52:01+0000",
 "changed": "2014-05-13T12:52:01+0000",
 "location": "",
 "response": 0
 }
 */


@interface CHDInvitation : CHDManagedModel

@property (nonatomic, strong) NSNumber *invitationId;
@property (nonatomic, strong) NSString *siteId;
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSNumber *eventCategories;
@property (nonatomic, assign) BOOL allDay;
@property (nonatomic, strong) NSDate *startDate;
@property (nonatomic, strong) NSDate *endDate;
@property (nonatomic, strong) NSDate *changeDate;
@property (nonatomic, strong) NSString *location;
@property (nonatomic, assign) NSString *invitedByUser;
@property (nonatomic, assign) NSString *attending;

@end
