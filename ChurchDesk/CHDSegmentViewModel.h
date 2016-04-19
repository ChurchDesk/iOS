//
//  CHDSegmentViewModel.h
//  ChurchDesk
//
//  Created by Chirag Sharma on 12/04/16.
//  Copyright © 2016 Shape A/S. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CHDSegmentViewModel : NSObject
@property (nonatomic, readonly) NSArray *segments;
@property (nonatomic, strong) NSString *organizationId;
-(void) reload;
@end
