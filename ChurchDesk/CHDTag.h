//
//  CHDTag.h
//  ChurchDesk
//
//  Created by Chirag Sharma on 13/06/16.
//  Copyright © 2016 ChurchDesk ApS. All rights reserved.
//

#import "CHDManagedModel.h"

@interface CHDTag : CHDManagedModel
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *tagId;
@end
