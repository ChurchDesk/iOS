//
//  CHDCreateMessageMailViewController.h
//  ChurchDesk
//
//  Created by Chirag Sharma on 07/04/16.
//  Copyright © 2016 Shape A/S. All rights reserved.
//

#import "CHDAbstractViewController.h"
#import "CHDUser.h"


@interface CHDCreateMessageMailViewController : CHDAbstractViewController <UITableViewDataSource, UITableViewDelegate>
@property (nonatomic, strong) NSArray *selectedPeopleArray;
@property (nonatomic, strong) NSString *organizationId;
@property (nonatomic, strong) CHDUser *currentUser;
@property (nonatomic, strong) NSString *selectedSender;
@property (nonatomic, assign) BOOL isSegment;
@end
