//
//  CHDEventInfoViewController.h
//  ChurchDesk
//
//  Created by Mikkel Selsøe Sørensen on 26/02/15.
//  Copyright (c) 2015 Shape A/S. All rights reserved.
//

#import "CHDAbstractViewController.h"

@class CHDEvent;

@interface CHDEventInfoViewController : CHDAbstractViewController

- (instancetype)initWithEventId: (NSNumber*) eventId siteId: (NSString*) siteId;
- (instancetype)initWithEvent: (CHDEvent*) event;

@end
