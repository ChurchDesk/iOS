//
//  CHDDatePickerViewController.h
//  ChurchDesk
//
//  Created by Jakob Vinther-Larsen on 18/03/15.
//  Copyright (c) 2015 Shape A/S. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CHDDatePickerViewController : UIViewController
@property (nonatomic, readonly) NSDate *date;
@property (nonatomic) BOOL allDay;

-(instancetype)initWithDate: (NSDate*) date allDay: (BOOL) allDay canSelectAllDay: (BOOL) allDaySelecable;
@end
