//
//  CHDPeopleViewModel.h
//  ChurchDesk
//
//  Created by Chirag Sharma on 01/04/16.
//  Copyright © 2016 Shape A/S. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CHDUser.h"

@interface CHDPeopleViewModel : NSObject
@property (nonatomic, readonly) NSArray *people;
@property (nonatomic, strong) NSMutableArray *sectionIndices;
@property (nonatomic, strong) NSMutableArray *peopleArrangedAccordingToIndex ;
@property (nonatomic, strong) NSString *organizationId;
@property (nonatomic, strong) CHDUser *user;
- (instancetype)initWithSegmentIds :(NSArray *)segmentIds;
-(void) reload;
-(void) refreshData;
@end
