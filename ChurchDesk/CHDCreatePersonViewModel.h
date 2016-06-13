//
//  CHDCreatePersonViewModel.h
//  ChurchDesk
//
//  Created by Chirag Sharma on 10/06/16.
//  Copyright © 2016 ChurchDesk ApS. All rights reserved.
//

#import "CHDManagedModel.h"

@interface CHDCreatePersonViewModel : CHDManagedModel
@property (nonatomic, strong) NSString *firstName;
@property (nonatomic, strong) NSString *lastName;
@property (nonatomic, strong) NSString *email;
@property (nonatomic, strong) NSString *phoneNumber;
@property (nonatomic, readonly) BOOL canCreatePerson;
@property (nonatomic, strong) NSArray *selectedTags;
@property (nonatomic, readonly) RACCommand *saveCommand;

@end
