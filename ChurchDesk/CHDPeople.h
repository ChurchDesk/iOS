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
@property (nonatomic, strong) NSString *peopleId;
@property (nonatomic, strong) NSDictionary *contact;
@property (nonatomic, strong) NSDate *birthday;
@property (nonatomic, strong) NSDate *registered;
@property (nonatomic, strong) NSString *gender;
@end
