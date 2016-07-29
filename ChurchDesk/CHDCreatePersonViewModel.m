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
    [personDictionary setValue:self.firstName forKey:@"firstName"];
    [personDictionary setValue:self.lastName forKey:@"lastName"];
    [personDictionary setValue:self.email forKey:@"email"];
    [personDictionary setValue:self.jobTitle forKey:@"occupation"];
    NSDictionary *contactDictionay = [[NSDictionary alloc] initWithObjectsAndKeys:self.mobilePhone, @"phone", self.homePhone, @"homePhone", self.workPhone, @"workPhone", self.postCode, @"zipcode", self.address, @"street", self.city, @"city", nil];
    [personDictionary setObject:contactDictionay forKey:@"contact"];
    [personDictionary setObject:self.gender forKey:@"gender"];
    //changing date to string
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"];
    NSString *stringFromDate = [formatter stringFromDate:self.birthday];
    
    [personDictionary setValue:stringFromDate forKey:@"birthday"];
    [personDictionary setObject:self.personPicture forKey:@"picture"];
    if (self.selectedTags.count >0) {
        NSMutableArray *tagsArray = [[NSMutableArray alloc] init];
        for (int i=0; i < self.selectedTags.count; i++) {
            CHDTag *singleTag = [self tagWithId:[self.selectedTags objectAtIndex:i]];
            NSDictionary *singlTagDictionary = [NSDictionary dictionaryWithObjectsAndKeys:singleTag.tagId, @"id", singleTag.name, @"name", nil];
            [tagsArray addObject:singlTagDictionary];
        }
        [personDictionary setObject:tagsArray forKey:@"tags"];
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
    self.firstName = person.firstName;
    self.lastName = person.lastName;
    self.email = person.email;
    self.jobTitle = person.occupation;
    self.birthday = person.birthday;
    self.gender = person.gender;
    self.personPicture = person.picture;
    self.mobilePhone = [person.contact valueForKey:@"phone"];
    self.workPhone = [person.contact valueForKey:@"workPhone"];
    self.homePhone = [person.contact valueForKey:@"homePhone"];
    self.address = [person.contact valueForKey:@"street"];
    self.city = [person.contact valueForKey:@"city"];
    self.postCode = [person.contact valueForKey:@"zipcode"];
    if (person.tags.count > 0) {
        NSMutableArray *personTags = [[NSMutableArray alloc] init];
        for (int i=0; i < person.tags.count; i++) {
            NSDictionary *singleTag = [person.tags objectAtIndex:i];
            NSLog(@"name %@", [singleTag valueForKey:@"name"]);
            NSLog(@"tag id %@", [singleTag valueForKey:@"id"]);
            [personTags addObject:[singleTag valueForKey:@"id"]];
        }
        self.selectedTags = personTags;
    }
}

// list of all countries
- (NSDictionary *)getCountryCodes {
    NSDictionary * dialingCodes = @ {
    @ "Canada"                                       : @ "+ 1" ,
    @ "China"                                         : @ "+ 86" ,
    @ "France"                                       : @ "+ 33" ,
    @ "Germany"                                       : @ "+ 49" ,
    @ "India"                                         : @ "+ 91" ,
    @ "Japan"                                         : @ "+ 81" ,
    @ "Pakistan"                                     : @ "+ 92" ,
    @ "United Kingdom"                               : @ "+ 44" ,
    @ "United States"                                 : @ "+ 1" ,
    @ "Abkhazia"                                     : @ "+ 7840" ,
    @ "Abkhazia"                                     : @ "+ 7940" ,
    @ "Afghanistan"                                   : @ "+ 93" ,
    @ "Albania"                                       : @ "+ 355" ,
    @ "Algeria"                                       : @ "+ 213" ,
    @ "American Samoa"                               : @ "+ 1684" ,
    @ "Andorra"                                       : @ "+ 376" ,
    @ "Angola"                                       : @ "+ 244" ,
    @ "Anguilla"                                     : @ "+ 1264" ,
    @ "Antigua and Barbuda"                           : @ "+ 1268" ,
    @ "Argentina"                                     : @ "+ 54" ,
    @ "Armenia"                                       : @ "+ 374" ,
    @ "Aruba"                                         : @ "+ 297" ,
    @ "Ascension"                                     : @ "+ 247" ,
    @ "Australia"                                     : @ "+ 61" ,
    @ "Australian External Territories"               : @ "+ 672" ,
    @ "Austria"                                       : @ "+ 43" ,
    @ "Azerbaijan"                                   : @ "+ 994" ,
    @ "Bahamas"                                       : @ "+ 1242" ,
    @ "Bahrain"                                       : @ "+ 973" ,
    @ "Bangladesh"                                   : @ "+ 880" ,
    @ "Barbados"                                     : @ "+ 1246" ,
    @ "Barbuda"                                       : @ "+ 1268" ,
    @ "Belarus"                                       : @ "+ 375" ,
    @ "Belgium"                                       : @ "+ 32" ,
    @ "Belize"                                       : @ "+ 501" ,
    @ "Benin"                                         : @ "+ 229" ,
    @ "Bermuda"                                       : @ "+ 1441" ,
    @ "Bhutan"                                       : @ "+ 975" ,
    @ "Bolivia"                                       : @ "+ 591" ,
    @ "Bosnia and Herzegovina"                       : @ "+ 387" ,
    @ "Botswana"                                     : @ "+ 267" ,
    @ "Brazil"                                       : @ "+ 55" ,
    @ "British Indian Ocean Territory"               : @ "+ 246" ,
    @ "British Virgin Islands"                       : @ "+ 1284" ,
    @ "Brunei"                                       : @ "+ 673" ,
    @ "Bulgaria"                                     : @ "+ 359" ,
    @ "Burkina Faso"                                 : @ "+ 226" ,
    @ "Burundi"                                       : @ "+ 257" ,
    @ "Cambodia"                                     : @ "+ 855" ,
    @ "Cameroon"                                     : @ "+ 237" ,
    @ "Canada"                                       : @ "+ 1" ,
    @ "Cape Verde"                                   : @ "+ 238" ,
    @ "Cayman Islands"                               : @ "+ 345" ,
    @ "Central African Republic"                     : @ "+ 236" ,
    @ "Chad"                                         : @ "+ 235" ,
    @ "Chile"                                         : @ "+ 56" ,
    @ "China"                                         : @ "+ 86" ,
    @ "Christmas Island"                             : @ "+ 61" ,
    @ "Cocos-Keeling Islands"                         : @ "+ 61" ,
    @ "Columbia"                                     : @ "+ 57" ,
    @ "Comoros"                                       : @ "+ 269" ,
    @ "Congo"                                         : @ "+ 242" ,
    @ "Congo, Dem. Rep. Of (Zaire)"                   : @ "+ 243" ,
    @ "Cook Islands"                                 : @ "+ 682" ,
    @ "Costa Rica"                                   : @ "+ 506" ,
    @ "Ivory Coast"                                   : @ "+ 225" ,
    @ "Croatia"                                       : @ "+ 385" ,
    @ "Cuba"                                         : @ "+ 53" ,
    @ "Curacao"                                       : @ "+ 599" ,
    @ "Cyprus"                                       : @ "+ 537" ,
    @ "Czech Republic"                               : @ "+ 420" ,
    @ "Denmark"                                       : @ "+ 45" ,
    @ "Diego Garcia"                                 : @ "+ 246" ,
    @ "Djibouti"                                     : @ "+ 253" ,
    @ "Dominica"                                     : @ "+ 1767" ,
    @ "Dominican Republic"                           : @ "+ 1809" ,
    @ "Dominican Republic"                           : @ "+ 1829" ,
    @ "Dominican Republic"                           : @ "+ 1849" ,
    @ "East Timor"                                   : @ "+ 670" ,
    @ "Easter Island"                                 : @ "+ 56" ,
    @ "Ecuador"                                       : @ "+ 593" ,
    @ "Egypt"                                         : @ "+ 20" ,
    @ "El Salvador"                                   : @ "+ 503" ,
    @ "Equatorial Guinea"                             : @ "+ 240" ,
    @ "Eritrea"                                       : @ "+291" ,
    @ "Estonia"                                       : @ "+ 372" ,
    @ "Ethiopia"                                     : @ "+ 251" ,
    @ "Falkland Islands"                             : @ "+ 500" ,
    @ "Faroe Islands"                                 : @ "+ 298" ,
    @ "Fiji"                                         : @ "+ 679" ,
    @ "Finland"                                       : @ "+ 358" ,
    @ "France"                                       : @ "+ 33" ,
    @ "French Antilles"                               : @ "+ 596" ,
    @ "French Guiana"                                 : @ "+ 594" ,
    @ "French Polynesia"                             : @ "+ 689" ,
    @ "Gabon"                                         : @ "+ 241" ,
    @ "Gambia"                                       : @ "+ 220" ,
    @ "Georgia"                                       : @ "+ 995" ,
    @ "Germany"                                       : @ "+ 49" ,
    @ "Ghana"                                         : @ "+ 233" ,
    @ "Gibraltar"                                     : @ "+ 350" ,
    @ "Greece"                                       : @ "+ 30" ,
    @ "Greenland"                                     : @ "+ 299" ,
    @ "Granada"                                       : @ "+ 1473" ,
    @ "Guadeloupe"                                   : @ "+ 590" ,
    @ "Guam"                                         : @ "+ 1671" ,
    @ "Guatemala"                                     : @ "+ 502" ,
    @ "Guinea"                                       : @ "+ 224" ,
    @ "Guinea-Bissau"                                 : @ "+ 245" ,
    @ "Guiana"                                       : @ "+ 595" ,
    @ "Haiti"                                         : @ "+ 509" ,
    @ "Honduras"                                     : @ "+ 504" ,
    @ "Hong Kong SAR China"                           : @ "+ 852" ,
    @ "Hungary"                                       : @ "+ 36" ,
    @ "Island"                                       : @ "+ 354" ,
    @ "India"                                         : @ "+ 91" ,
    @ "Indonesia"                                     : @ "+ 62" ,
    @ "Iran"                                         : @ "+ 98" ,
    @ "Iraq"                                         : @ "+ 964" ,
    @ "Ireland"                                       : @ "+ 353" ,
    @ "Israel"                                       : @ "+ 972" ,
    @ "Italy"                                         : @ "+ 39" ,
    @ "Jamaica"                                       : @ "+ 1876" ,
    @ "Japan"                                         : @ "+ 81" ,
    @ "Jordan"                                       : @ "+ 962" ,
    @ "Kazakhstan"                                   : @ "+ 7 7" ,
    @ "Kenya"                                         : @ "+ 254" ,
    @ "Kiribati"                                     : @ "+ 686" ,
    @ "North Korea"                                   : @ "+ 850" ,
    @ "South Korea"                                   : @ "+ 82" ,
    @ "Kuwait"                                       : @ "+ 965" ,
    @ "Kyrgyzstan"                                   : @ "+ 996" ,
    @ "Lao"                                         : @ "+ 856" ,
    @ "Latvia"                                       : @ "+ 371" ,
    @ "Lebanon"                                       : @ "+ 961" ,
    @ "Lesotho"                                       : @ "+ 266" ,
    @ "Liberia"                                       : @ "+ 231" ,
    @ "Libya"                                         : @ "+ 218" ,
    @ "Liechtenstein"                                 : @ "+ 423" ,
    @ "Lithuania"                                     : @ "+370" ,
    @ "Luxembourg"                                   : @ "+352" ,
    @ "Macau SAR China"                               : @ "+853" ,
    @ "Macedonia"                                     : @ "+389" ,
    @ "Madagascar"                                   : @ "+261" ,
    @ "Malawi"                                       : @ "+265" ,
    @ "Malaysia"                                     : @ "+60" ,
    @ "Maldives"                                     : @ "+960" ,
    @ "Mali"                                         : @ "+223" ,
    @ "Malta"                                         : @ "+356" ,
    @ "Marshall Islands"                             : @ "+692" ,
    @ "Martinique"                                   : @ "+596" ,
    @ "Mauritania"                                   : @ "+222" ,
    @ "Mauritius"                                     : @ "+230" ,
    @ "Mayotte"                                       : @ "+262" ,
    @ "Mexico"                                       : @ "+52" ,
    @ "Micronesia"                                   : @ "+691" ,
    @ "Midway Island"                                 : @ "+1808" ,
    @ "Micronesia"                                   : @ "+691" ,
    @ "Moldova"                                       : @ "+373" ,
    @ "Monaco"                                       : @ "+377" ,
    @ "Mongolia"                                     : @ "+976" ,
    @ "Montenegro"                                   : @ "+382" ,
    @ "Montserrat"                                   : @ "+1664" ,
    @ "Morocco"                                       : @ "+212" ,
    @ "Myanmar"                                       : @ "+95" ,
    @ "Namibia"                                       : @ "+264" ,
    @ "Nauru"                                         : @ "+674" ,
    @ "Nepal"                                         : @ "+977" ,
    @ "Netherlands"                                   : @ "+31" ,
    @ "Netherlands Antilles"                         : @ "+599" ,
    @ "Nevis"                                         : @ "+1869" ,
    @ "New Caledonia"                                 : @ "+687" ,
    @ "New Zealand"                                   : @ "+64" ,
    @ "Nicaragua"                                     : @ "+505" ,
    @ "Message"                                         : @ "+227" ,
    @ "Nigeria"                                       : @ "+234" ,
    @ "Niue"                                         : @ "+683" ,
    @ "Norfolk Island"                               : @ "+672" ,
    @ "Northern Mariana Islands"                     : @ "+1670" ,
    @ "Norway"                                       : @ "+47" ,
    @ "Oman"                                         : @ "+968" ,
    @ "Pakistan"                                     : @ "+92" ,
    @ "Palau"                                         : @ "+680" ,
    @ "Palestinian Territory"                         : @ "+970" ,
    @ "Panama"                                       : @ "+507" ,
    @ "Papua New Guinea"                             : @ "+675" ,
    @ "Paraguay"                                     : @ "+595" ,
    @ "Peru"                                         : @ "+51" ,
    @ "Philippines"                                   : @ "+63" ,
    @ "Poland"                                       : @ "+48" ,
    @ "Portugal"                                     : @ "+351" ,
    @ "Puerto Rico"                                   : @ "+1787" ,
    @ "Puerto Rico"                                   : @ "+1939" ,
    @ "Qatar"                                         : @ "+974" ,
    @ "Reunion"                                       : @ "+262" ,
    @ "Romania"                                       : @ "+40" ,
    @ "Russia"                                       : @ "+7" ,
    @ "Rwanda"                                       : @ "+250" ,
    @ "Samoa"                                         : @ "+685" ,
    @ "San Marino"                                   : @ "+378" ,
    @ "Saudi Arabia"                                 : @ "+966" ,
    @ "Senegal"                                       : @ "+221" ,
    @ "Serbia"                                       : @ "+381" ,
    @ "Seychelles"                                   : @ "+248" ,
    @ "Sierra Leone"                                 : @ "+232" ,
    @ "Singapore"                                     : @ "+65" ,
    @ "Slovakia"                                     : @ "+421" ,
    @ "Slovenia"                                     : @ "+386" ,
    @ "Solomon Islands"                               : @ "+677" ,
    @ "South Africa"                                 : @ "+27" ,
    @ "South Georgia and the South Sandwich Islands" : @ "+500" ,
    @ "Spain"                                         : @ "+34" ,
    @ "Sri Lanka"                                     : @ "+94" ,
    @ "Sudan"                                         : @ "+249" ,
    @ "Suriname"                                     : @ "+597" ,
    @ "Swaziland"                                     : @ "+268" ,
    @ "Sweden"                                       : @ "+46" ,
    @ "Switzerland"                                   : @ "+41" ,
    @ "Syria "                                         : @"+963 " ,
    @ "Taiwan"                                       : @ "+886" ,
    @ "Tajikistan"                                   : @ "+992" ,
    @ "Tanzania"                                     : @ "+255" ,
    @ "Thailand"                                     : @ "+66" ,
    @ "Timor Leste"                                   : @ "+670" ,
    @ "Togo"                                         : @ "+228" ,
    @ "Tokelau"                                       : @ "+690" ,
    @ "Tonga"                                         : @ "+676" ,
    @ "Trinidad and Tobago"                           : @ "+1868" ,
    @ "Tunisia"                                       : @ "+216" ,
    @ "Turkey"                                       : @ "+90" ,
    @ "Turkmenistan"                                 : @ "+993" ,
    @ "Turks and Caicos Islands"                     : @ "+1649" ,
    @ "Tuvalu"                                       : @ "+688" ,
    @ "Uganda"                                       : @ "+256" ,
    @ "Ukraine"                                       : @ "+380" ,
    @ "United Arab Emirates"                         : @ "+971" ,
    @ "United Kingdom"                               : @ "+44" ,
    @ "United States"                                 : @ "+1" ,
    @ "Uruguay"                                       : @ "+598" ,
    @ "US Virgin Islands"                           : @ "+1340" ,
    @ "Uzbekistan"                                   : @ "+998" ,
    @ "Vanuatu"                                       : @ "+678" ,
    @ "Venezuela"                                     : @ "+58" ,
    @ "Vietnam"                                       : @ "+84" ,
    @ "Wake Island"                                   : @ "+1808" ,
    @ "Wallis and Futuna"                             : @ "+681" ,
    @ "Yemen"                                         : @ "+967" ,
    @ "Zambia"                                       : @ "+260" ,
    @ "Zanzibar"                                     : @ "+255" ,
    @ "Zimbabwe"                                     : @ "+263"
    } ;
    return dialingCodes;
}

@end
