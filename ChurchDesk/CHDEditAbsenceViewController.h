//
//  CHDEditAbsenceViewController.h
//  ChurchDesk
//
//  Created by Chirag Sharma on 22/12/15.
//  Copyright © 2015 Shape A/S. All rights reserved.
//

#import "CHDAbstractViewController.h"
@class CHDEvent;
@class CHDEditAbsenceViewModel;

@interface CHDEditAbsenceViewController : CHDAbstractViewController

@property (nonatomic, readonly) CHDEvent *event;
@property (nonatomic, readonly) CHDEditAbsenceViewModel *viewModel;
- (instancetype)initWithEvent: (CHDEvent*) event;

@end
