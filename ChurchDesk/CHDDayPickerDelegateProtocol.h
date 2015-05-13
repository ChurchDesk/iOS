//
// Created by Jakob Vinther-Larsen on 08/04/15.
// Copyright (c) 2015 Shape A/S. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol CHDDayPickerDelegateProtocol <NSObject>
-(void)chd_dayPickerDidSelectDate: (NSDate*)date;
@end