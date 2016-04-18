//
//  CHDSegment.h
//  ChurchDesk
//
//  Created by Chirag Sharma on 18/04/16.
//  Copyright © 2016 Shape A/S. All rights reserved.
//

#import "CHDManagedModel.h"

@interface CHDSegment : CHDManagedModel
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *segmentId;
@end
