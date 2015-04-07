//
//  CHDListSelectorViewController.h
//  ChurchDesk
//
//  Created by Jakob Vinther-Larsen on 02/03/15.
//  Copyright (c) 2015 Shape A/S. All rights reserved.
//

#import "CHDAbstractViewController.h"
#import "CHDListConfigModel.h"

@interface CHDListViewController : CHDAbstractViewController  <UITableViewDelegate, UITableViewDataSource>
- (instancetype)initWithItems:(NSArray *)items;
@end
