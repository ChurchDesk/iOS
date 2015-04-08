//
//  CHDDayPickerViewController.h
//  ChurchDesk
//
//  Created by Mikkel Selsøe Sørensen on 25/02/15.
//  Copyright (c) 2015 Shape A/S. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CHDDayPickerDelegateProtocol;

@interface CHDDayPickerViewController : UIViewController

@property (nonatomic, readonly) NSDate *referenceDate;
@property (nonatomic, strong) NSDate *selectedDate;
@property (nonatomic, readonly) NSUInteger currentWeekNumber;
@property (nonatomic, weak) id<CHDDayPickerDelegateProtocol> delegate;
- (void) scrollToDate: (NSDate*) date animated: (BOOL) animated;
-(void) reloadShownDates;
@end
