//
//  CHDEventUserDetailsViewController.h
//  ChurchDesk
//
//  Created by Mikkel Selsøe Sørensen on 26/03/15.
//  Copyright (c) 2015 Shape A/S. All rights reserved.
//

#import "CHDAbstractViewController.h"

@class CHDEvent;

@interface CHDEventUserDetailsViewController : CHDAbstractViewController

- (instancetype)initWithEvent: (CHDEvent*) event;

@end
