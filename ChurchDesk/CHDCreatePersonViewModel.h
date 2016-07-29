//
//  CHDCreatePersonViewModel.h
//  ChurchDesk
//
//  Created by Chirag Sharma on 10/06/16.
//  Copyright © 2016 ChurchDesk ApS. All rights reserved.
//

#import "CHDManagedModel.h"
#import "CHDPeople.h"
#import "CHDTag.h"

@interface CHDCreatePersonViewModel : CHDManagedModel
@property (nonatomic, strong) NSString *firstName;
@property (nonatomic, strong) NSString *lastName;
@property (nonatomic, strong) NSString *email;
@property (nonatomic, strong) NSString *mobilePhone;
@property (nonatomic, strong) NSString *homePhone;
@property (nonatomic, strong) NSString *workPhone;
@property (nonatomic, strong) NSString *jobTitle;
@property (nonatomic, strong) NSString *address;
@property (nonatomic, strong) NSString *city;
@property (nonatomic, strong) NSString *postCode;
@property (nonatomic, strong) NSDate *birthday;
@property (nonatomic, strong) NSString *gender;
@property (nonatomic, readonly) BOOL canCreatePerson;
@property (nonatomic, strong) NSArray *selectedTags;
@property (nonatomic, readonly) RACCommand *saveCommand;
@property (nonatomic, readonly) NSArray *tags;
@property (nonatomic, strong) NSDictionary *personPicture;

-(void)personInfoDistribution :(CHDPeople *)person;
- (NSString*) formatDate: (NSDate*) date;
- (CHDTag *) tagWithId: (NSNumber*) tagId;
- (RACSignal*)createPerson;
- (RACSignal*)editPerson :(NSDictionary *)personDict personId:(NSString *)personId;
- (NSDictionary *)getCountryCodes;
@end
