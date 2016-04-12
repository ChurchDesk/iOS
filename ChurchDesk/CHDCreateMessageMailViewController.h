//
//  CHDCreateMessageMailViewController.h
//  ChurchDesk
//
//  Created by Chirag Sharma on 07/04/16.
//  Copyright © 2016 Shape A/S. All rights reserved.
//

#import "CHDAbstractViewController.h"

@interface CHDCreateMessageMailViewController : CHDAbstractViewController <UITableViewDataSource, UITableViewDelegate>
@property (nonatomic, strong) NSArray *selectedPeopleArray;

@end
