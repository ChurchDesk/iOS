//
//  CHDPeople.h
//  ChurchDesk
//
//  Created by Chirag Sharma on 01/04/16.
//  Copyright © 2016 Shape A/S. All rights reserved.
//

#import "CHDManagedModel.h"

@interface CHDPeople : CHDManagedModel
@property (nonatomic, strong) NSString *fullName;
@property (nonatomic, strong) NSString *email;
@end
