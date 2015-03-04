//
//  CHDHoliday.h
//  ChurchDesk
//
//  Created by Mikkel Selsøe Sørensen on 03/03/15.
//  Copyright (c) 2015 Shape A/S. All rights reserved.
//

#import "CHDManagedModel.h"

@interface CHDHoliday : CHDManagedModel

@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSDate *date;

@end
