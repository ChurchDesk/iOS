//
//  CHDPeopleViewModel.m
//  ChurchDesk
//
//  Created by Chirag Sharma on 01/04/16.
//  Copyright © 2016 Shape A/S. All rights reserved.
//

#import "CHDPeopleViewModel.h"
#import "CHDAPIClient.h"
#import "CHDPeople.h"
#import "CHDSite.h"
#import "CHDSitePermission.h"
#import "CHDAuthenticationManager.h"
#import "NSDate+ChurchDesk.h"

@interface CHDPeopleViewModel()
@property (nonatomic, strong) NSArray *people;
@end
@implementation CHDPeopleViewModel
- (instancetype)initWithSegmentIds :(NSArray *)segmentIds {
    self = [super init];
    if (self) {
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        NSData *encodedObject = [defaults objectForKey:kcurrentuser];
        _user = [NSKeyedUnarchiver unarchiveObjectWithData:encodedObject];
        if (_user.sites.count > 1) {
            _organizationId = [defaults valueForKey:kselectedOrganizationIdforPeople];
        }
        else{
            CHDSite *site = [_user.sites objectAtIndex:0];
            _organizationId = site.siteId;
        }
        _peopleAccess = [_user siteWithId:_organizationId].permissions.canAccessPeople;
        //Initial signal
        RACSignal *initialSignal = [[[[CHDAPIClient sharedInstance] getpeopleforOrganization:_organizationId segmentIds:segmentIds] map:^id(NSArray* people) {
            RACSequence *results = [people.rac_sequence filter:^BOOL(CHDPeople* people) {
                    return YES;
            }];

            //NSLog(@"people array %@", results.array);
            return results.array;

        }] catch:^RACSignal *(NSError *error) {
            return [RACSignal empty];
        }];
        
        RAC(self, people) = initialSignal;
    }
    return self;
}

-(void) refreshData{
    _sectionIndices = [[NSMutableArray alloc] init];
    _peopleArrangedAccordingToIndex = [[NSMutableArray alloc] init];
    NSArray *alphaArray=[[NSArray alloc] initWithObjects:@"A",@"B",@"C",@"D",@"E",@"F",@"G",@"H",@"I",@"J",@"K",@"L",@"M",@"N",@"O",@"P",@"Q",@"R",@"S",@"T",@"U",@"V",@"W",@"X",@"Y",@"Z",@"Æ", @"Ø", @"Å", nil];
    NSMutableArray *tempArray;
    NSString *prefix;
    for (int i=0; i<alphaArray.count; i++)
    {
        tempArray=[[NSMutableArray alloc] init];
        for(int j=0;j<_people.count;j++)
        {
            NSCharacterSet *whitespace = [NSCharacterSet whitespaceAndNewlineCharacterSet];
            CHDPeople *individualContact = [_people objectAtIndex:j];
            if (!individualContact.fullName) {
                individualContact.fullName = NSLocalizedString(@"Unknown", @"");
            }
            prefix = [[individualContact.fullName stringByTrimmingCharactersInSet:whitespace] substringToIndex:1];
            if ([prefix caseInsensitiveCompare:[alphaArray objectAtIndex:i]] == NSOrderedSame )
            {
                [tempArray addObject:individualContact];
            }
        }
        if (tempArray.count>0)
        {
            [_sectionIndices addObject:[alphaArray objectAtIndex:i]];
            [_peopleArrangedAccordingToIndex addObject:tempArray];
        }
    }
}
- (void)reload {
    RACSignal *updateSignal = [[[[CHDAPIClient sharedInstance] getpeopleforOrganization:_organizationId segmentIds:[NSArray new]] map:^id(NSArray* people) {
        RACSequence *results = [people.rac_sequence filter:^BOOL(CHDPeople* people) {
            return YES;
        }];
        
        //NSLog(@"people array %@", results.array);
        return results.array;
        
    }] catch:^RACSignal *(NSError *error) {
        return [RACSignal empty];
    }];
    
    RAC(self, people) = updateSignal;
}
@end
