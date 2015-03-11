//
//  CHDEventCategory.h
//  ChurchDesk
//
//  Created by Mikkel Selsøe Sørensen on 26/02/15.
//  Copyright (c) 2015 Shape A/S. All rights reserved.
//

#import "CHDManagedModel.h"

@interface CHDEventCategory : CHDManagedModel

@property (nonatomic, strong) NSNumber *categoryId;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *siteId;
@property (nonatomic, strong) NSString *colorString;
@property (nonatomic, strong) UIColor *color;

@end
