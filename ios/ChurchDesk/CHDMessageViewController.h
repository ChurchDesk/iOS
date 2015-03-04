//
//  CHDMessageViewController.h
//  ChurchDesk
//
//  Created by Jakob Vinther-Larsen on 25/02/15.
//  Copyright (c) 2015 Shape A/S. All rights reserved.
//

#import "CHDAbstractViewController.h"

@interface CHDMessageViewController : CHDAbstractViewController <UITableViewDelegate, UITableViewDataSource>
- (instancetype)initWithMessageId: (NSNumber*)messageId site: (NSString*) site;
@end
