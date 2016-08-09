//
//  CHDCreatePersonViewModel.m
//  ChurchDesk
//
//  Created by Chirag Sharma on 10/06/16.
//  Copyright © 2016 ChurchDesk ApS. All rights reserved.
//

#import "CHDCreatePersonViewModel.h"
#import "CHDAPIClient.h"
#import "CHDUser.h"
#import "CHDSite.h"
#import "CHDAuthenticationManager.h"

@interface CHDCreatePersonViewModel()
@property (nonatomic, strong) RACCommand *saveCommand;
@property (nonatomic, strong) RACCommand *editCommand;
@property (nonatomic, strong) NSString *organizationId;
@end

@implementation CHDCreatePersonViewModel

- (instancetype)init {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSData *encodedObject = [defaults objectForKey:kcurrentuser];
    CHDUser *user = [NSKeyedUnarchiver unarchiveObjectWithData:encodedObject];

    if (user.sites.count > 1) {
        _organizationId = [defaults valueForKey:kselectedOrganizationIdforPeople];
    }
    else{
        CHDSite *site = [user.sites objectAtIndex:0];
        _organizationId = site.siteId;
    }
    //Initial signal
    RACSignal *initialSignal = [[[[CHDAPIClient sharedInstance] getTagsforOrganization:_organizationId] map:^id(NSArray* tags) {
        RACSequence *results = [tags.rac_sequence filter:^BOOL(CHDTag* tag) {
            if (tag.name.length >1) {
                return YES;
            }
            else{
                return NO;
            }
        }];
        
        return results.array;
        
    }] catch:^RACSignal *(NSError *error) {
        return [RACSignal empty];
    }];
    
    
    //Update signal
    CHDAPIClient *apiClient = [CHDAPIClient sharedInstance];
    
    RACSignal *updateSignal = [[[apiClient.manager.cache rac_signalForSelector:@selector(invalidateObjectsMatchingRegex:)] filter:^BOOL(RACTuple *tuple) {
        NSString *regex = tuple.first;
        NSString *resourcePath = [apiClient resourcePathForGetSegments];
        [[NSUserDefaults standardUserDefaults] setValue:[NSDate date] forKey:keventsTimestamp];
        return [regex rangeOfString:resourcePath].location != NSNotFound;
    }] flattenMap:^RACStream *(id value) {
        return [[[[CHDAPIClient sharedInstance] getSegmentsforOrganization:_organizationId] map:^id(NSArray* tags) {
            RACSequence *results = [tags.rac_sequence filter:^BOOL(CHDTag* tag) {
                if (tag.name.length >1) {
                    return YES;
                }
                else{
                    return NO;
                }
            }];
            return results.array;
        }] catch:^RACSignal *(NSError *error) {
            return [RACSignal empty];
        }];
    }];
    RAC(self, tags) = [RACSignal merge:@[initialSignal, updateSignal]];
    
    RAC(self, canCreatePerson) = [RACSignal combineLatest:@[RACObserve(self, firstName), RACObserve(self, lastName), RACObserve(self, mobilePhone), RACObserve(self, email), RACObserve(self, homePhone), RACObserve(self, workPhone), RACObserve(self, jobTitle), RACObserve(self, address), RACObserve(self, city), RACObserve(self, postCode), RACObserve(self, birthday), RACObserve(self, gender), RACObserve(self, selectedTags), RACObserve(self, personPicture)]
                                                  reduce:^(NSString *firstName, NSString *lastName, NSString *mobilePhone, NSString *email, NSString *homePhone, NSString *workPhone, NSString *jobTitle, NSString *address, NSString *city, NSString *postcode, NSDate *birthday, NSString *gender, NSArray *selectedTags, NSDictionary *personPicture){
                                                      BOOL validFirstName = (firstName.length !=0);
                                                      BOOL validLastName = (lastName.length !=0);
                                                      BOOL validPhoneNumber = (mobilePhone.length !=0);
                                                      BOOL validEmail = (email.length !=0);
                                                      BOOL validHomePhone = (homePhone.length !=0);
                                                      BOOL validWorkPhone = (workPhone.length !=0);
                                                      BOOL validJobTitle = (jobTitle.length !=0);
                                                      BOOL validAddress = (address.length !=0);
                                                      BOOL validCity = (city.length !=0);
                                                      BOOL validPostCode = (postcode.length !=0);
                                                      BOOL validBirtdhay = (birthday != nil);
                                                      BOOL validGender = (gender.length != 0);
                                                      BOOL validSelectedTags = !(selectedTags.count == 0);
                                                      BOOL validPicture = (personPicture.allKeys.count != 0);
                                                      return @(validFirstName || validLastName || validPhoneNumber || validEmail || validHomePhone || validWorkPhone || validJobTitle || validAddress ||validCity || validPostCode || validBirtdhay || validGender ||validSelectedTags || validPicture);
                                                  }];
    return self;
}

- (NSString*) formatDate: (NSDate*) date {
    NSDateFormatter *dateFormatter = [NSDateFormatter new];
    dateFormatter.dateStyle = NSDateFormatterLongStyle;
    dateFormatter.timeStyle = NSDateFormatterNoStyle;
    
    return [dateFormatter stringFromDate:date];
}

- (CHDTag*) tagWithId: (NSNumber*) tagId{
    return tagId ? [self.tags shp_detect:^BOOL(CHDTag *tag) {
        return tag.tagId.integerValue == tagId.integerValue;
    }] : nil;
}

- (RACSignal*)createPerson{
    NSMutableDictionary *personDictionary = [[NSMutableDictionary alloc] init];
    
    [personDictionary setValue:self.firstName ? self.firstName: @"" forKey:@"firstName"];
    [personDictionary setValue:self.lastName ? self.lastName: @"" forKey:@"lastName"];
    [personDictionary setValue:self.email ? self.email: @"" forKey:@"email"];
    [personDictionary setValue:self.jobTitle ? self.jobTitle: @"" forKey:@"occupation"];
    NSDictionary *contactDictionay = [[NSDictionary alloc] initWithObjectsAndKeys:self.mobilePhone ? self.mobilePhone: @"", @"phone", self.homePhone ? self.homePhone: @"", @"homePhone", self.workPhone ? self.workPhone: @"", @"workPhone", self.postCode ? self.postCode: @"", @"zipcode", self.address ? self.address: @"", @"street", self.city ? self.city: @"", @"city", nil];
    [personDictionary setObject:contactDictionay forKey:@"contact"];
    [personDictionary setObject:self.gender ? self.gender: @"" forKey:@"gender"];
    //changing date to string
    if (self.birthday) {
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"];
        NSString *stringFromDate = [formatter stringFromDate:self.birthday];
        [personDictionary setValue:stringFromDate forKey:@"birthday"];
    }
    if (self.personPicture) {
        [personDictionary setObject:self.personPicture  forKey:@"picture"];
    }
    if (self.selectedTags.count >0) {
        NSMutableArray *tagsArray = [[NSMutableArray alloc] init];
        for (int i=0; i < self.selectedTags.count; i++) {
            CHDTag *singleTag = [self tagWithId:[self.selectedTags objectAtIndex:i]];
            NSDictionary *singlTagDictionary = [NSDictionary dictionaryWithObjectsAndKeys:singleTag.tagId, @"id", singleTag.name, @"name", nil];
            [tagsArray addObject:singlTagDictionary];
        }
        [personDictionary setObject:tagsArray forKey:@"tags"];
    }
    else{
        [personDictionary setObject:[NSArray new] forKey:@"tags"];
    }
    
    RACSignal *saveSignal = [self.saveCommand execute:RACTuplePack(personDictionary)];
    return saveSignal;
}

-(RACCommand*)saveCommand {
    if(!_saveCommand){
        _saveCommand = [[RACCommand alloc] initWithSignalBlock:^RACSignal *(RACTuple *tuple) {
            NSDictionary *personDict = tuple.first;
            
            return [[CHDAPIClient sharedInstance] createPersonwithPersonDictionary:personDict organizationId:_organizationId];
        }];
    }
    return _saveCommand;
}

- (RACSignal*)editPerson :(NSDictionary *)personDict personId:(NSString *)personId{
    RACSignal *saveSignal = [self.editCommand execute:RACTuplePack(personDict, personId)];
    return saveSignal;
}

-(RACCommand*)editCommand {
    if(!_editCommand){
        _editCommand = [[RACCommand alloc] initWithSignalBlock:^RACSignal *(RACTuple *tuple) {
            NSDictionary *personDict = tuple.first;
            NSString *personID = tuple.second;
            return [[CHDAPIClient sharedInstance] editPersonwithPersonDictionary:personDict organizationId:_organizationId personId:personID];
        }];
    }
    return _editCommand;
}

-(void)personInfoDistribution :(CHDPeople *)person{
    self.firstName = (person.firstName != (id)[NSNull null] && person.firstName.length > 0)? person.firstName : @"";
    self.lastName = (person.lastName != (id)[NSNull null] && person.lastName.length > 0)? person.lastName : @"";
    self.email = (person.email != (id)[NSNull null] && person.email.length > 0)? person.email : @"";
    self.jobTitle = (person.occupation != (id)[NSNull null] && person.occupation.length > 0)? person.occupation : @"";
    self.birthday = (person.birthday != (id)[NSNull null] && person.birthday != nil) ? person.birthday : nil;
    self.gender = (person.gender != (id)[NSNull null] && person.gender.length > 0)  ? person.gender : @"";
    self.personPicture = person.picture != (id)[NSNull null] ? person.picture : nil;
    self.mobilePhone = [person.contact valueForKey:@"phone"] != (id)[NSNull null] ? [person.contact valueForKey:@"phone"] : @"";
    self.workPhone = [person.contact valueForKey:@"workPhone"] != (id)[NSNull null] ? [person.contact valueForKey:@"workPhone"] : @"";
    self.homePhone = [person.contact valueForKey:@"homePhone"] != (id)[NSNull null] ? [person.contact valueForKey:@"homePhone"] : @"";
    self.address = [person.contact valueForKey:@"street"] != (id)[NSNull null] ? [person.contact valueForKey:@"street"] : @"";
    self.city = [person.contact valueForKey:@"city"] != (id)[NSNull null] ? [person.contact valueForKey:@"city"] : @"";
    self.postCode = [person.contact valueForKey:@"zipcode"] != (id)[NSNull null] ? [person.contact valueForKey:@"zipcode"] : @"";
    if (person.tags.count > 0) {
        NSMutableArray *personTags = [[NSMutableArray alloc] init];
        for (int i=0; i < person.tags.count; i++) {
            NSDictionary *singleTag = [person.tags objectAtIndex:i];
            [personTags addObject:[singleTag valueForKey:@"id"]];
        }
        self.selectedTags = personTags;
    }
}

@end
