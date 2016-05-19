//
//  CHDSegmentsViewController.h
//  ChurchDesk
//
//  Created by Chirag Sharma on 17/03/16.
//  Copyright © 2016 Shape A/S. All rights reserved.
//

#import "CHDAbstractViewController.h"
@protocol sendSegmentsProtocol <NSObject>
-(void) sendSelectedPeopleArray: (NSArray *)selectedPeopleArray;
@end

@interface CHDSegmentsViewController : CHDAbstractViewController
@property(nonatomic,assign)id segmentDelegate;
@property(nonatomic, strong) NSMutableArray *selectedSegmentsArray;
@property (nonatomic, assign) BOOL createMessage;
@end
