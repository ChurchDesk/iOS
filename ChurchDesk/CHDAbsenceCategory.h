//
//  CHDAbsenceCategory.h
//  ChurchDesk
//
//  Created by Chirag Sharma on 21/12/15.
//  Copyright © 2015 Shape A/S. All rights reserved.
//

#import "CHDManagedModel.h"

@interface CHDAbsenceCategory : CHDManagedModel

@property (nonatomic, strong) NSNumber *categoryId;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *siteId;
@property (nonatomic, strong) UIColor *color;

@end
