//
//  CHDPeopleViewController.h
//  ChurchDesk
//
//  Created by Chirag Sharma on 17/03/16.
//  Copyright © 2016 Shape A/S. All rights reserved.
//

#import "CHDAbstractViewController.h"

@interface CHDPeopleViewController : CHDAbstractViewController
@property (nonatomic, strong) NSString *organizationId;
@property(nonatomic, strong) NSMutableArray *selectedPeopleArray;
@property(nonatomic, strong) NSArray *segmentIds;
@end
