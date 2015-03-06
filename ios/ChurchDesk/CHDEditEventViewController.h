//
//  CHDEditEventViewController.h
//  ChurchDesk
//
//  Created by Mikkel Selsøe Sørensen on 06/03/15.
//  Copyright (c) 2015 Shape A/S. All rights reserved.
//

#import "CHDAbstractViewController.h"

@class CHDEvent;

@interface CHDEditEventViewController : CHDAbstractViewController

- (instancetype)initWithEvent: (CHDEvent*) event;

@end
