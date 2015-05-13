//
//  CHDAPICreate.h
//  ChurchDesk
//
//  Created by Jakob Vinther-Larsen on 09/03/15.
//  Copyright (c) 2015 Shape A/S. All rights reserved.
//

#import "CHDManagedModel.h"

@interface CHDAPICreate : CHDManagedModel
@property (nonatomic, strong) NSNumber *createId;
@property (nonatomic, strong) NSString *siteId;
@property (nonatomic, strong) NSString *type;
@property (nonatomic, strong) NSString *error;
@end
