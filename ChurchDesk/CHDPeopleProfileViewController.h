//
//  CHDPeopleProfileViewController.h
//  ChurchDesk
//
//  Created by Chirag Sharma on 25/04/16.
//  Copyright © 2016 Shape A/S. All rights reserved.
//

#import "CHDAbstractViewController.h"
#import "CHDPeople.h"
#import "CHDUser.h"

@interface CHDPeopleProfileViewController : CHDAbstractViewController
@property (nonatomic, strong) CHDPeople *people;
@property (nonatomic, strong) NSString *organizationId;
@property (nonatomic, strong) CHDUser *currentUser;
@end
