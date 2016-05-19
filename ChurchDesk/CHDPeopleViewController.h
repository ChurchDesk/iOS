//
//  CHDPeopleViewController.h
//  ChurchDesk
//
//  Created by Chirag Sharma on 17/03/16.
//  Copyright © 2016 Shape A/S. All rights reserved.
//

#import "CHDAbstractViewController.h"

@protocol senddataProtocol <NSObject>
-(void) sendSelectedPeopleArray: (NSArray *)selectedPeopleArray;
@end

@interface CHDPeopleViewController : CHDAbstractViewController
@property(nonatomic,assign)id delegate;
@property (nonatomic, strong) NSMutableArray *selectedPeopleArray;
@property (nonatomic, strong) NSArray *segmentIds;
@property (nonatomic, assign) BOOL createMessage;
@end
