//
//  CHDPeopleViewModel.m
//  ChurchDesk
//
//  Created by Chirag Sharma on 01/04/16.
//  Copyright © 2016 Shape A/S. All rights reserved.
//

#import "CHDPeopleViewModel.h"
#import "CHDAPIClient.h"
#import "CHDUser.h"
#import "CHDPeople.h"
#import "CHDAuthenticationManager.h"
#import "NSDate+ChurchDesk.h"

@interface CHDPeopleViewModel()
@property (nonatomic, strong) NSArray *people;
@end
@implementation CHDPeopleViewModel
- (instancetype)init {
    self = [super init];
    if (self) {
       
        //Initial signal
        RACSignal *initialSignal = [[[[CHDAPIClient sharedInstance] getpeopleforOrganization:@"58"] map:^id(NSArray* people) {
            RACSequence *results = [people.rac_sequence filter:^BOOL(CHDPeople* people) {
                if (people.fullName.length >1) {
                    return YES;
                }
                else{
                    return NO;
                }
            }];

            NSLog(@"people array %@", results.array);
            return results.array;

        }] catch:^RACSignal *(NSError *error) {
            return [RACSignal empty];
        }];
        
        
        //Update signal
        CHDAPIClient *apiClient = [CHDAPIClient sharedInstance];
        
        RACSignal *authenticationTokenSignal = [RACObserve([CHDAuthenticationManager sharedInstance], authenticationToken) ignore:nil];
        
        RACSignal *updateSignal = [[[apiClient.manager.cache rac_signalForSelector:@selector(invalidateObjectsMatchingRegex:)] filter:^BOOL(RACTuple *tuple) {
            NSString *regex = tuple.first;
            NSString *resourcePath = [apiClient resourcePathForGetPeople];
            [[NSUserDefaults standardUserDefaults] setValue:[NSDate date] forKey:keventsTimestamp];
            return [regex rangeOfString:resourcePath].location != NSNotFound;
        }] flattenMap:^RACStream *(id value) {
            return [[[[CHDAPIClient sharedInstance] getpeopleforOrganization:@"58"] map:^id(NSArray* people) {
                RACSequence *results = [people.rac_sequence filter:^BOOL(CHDPeople* people) {
                    if (people.fullName.length >1) {
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
        
        RAC(self, people) = [RACSignal merge:@[initialSignal, updateSignal]];
        [self shprac_liftSelector:@selector(reload) withSignal:authenticationTokenSignal];

    }
    return self;
}

-(void) refreshData{
    _sectionIndices = [[NSMutableArray alloc] init];
    
    _peopleArrangedAccordingToIndex = [[NSMutableArray alloc] init];
    NSArray *alphaArray=[[NSArray alloc] initWithObjects:@"A",@"B",@"C",@"D",@"E",@"F",@"G",@"H",@"I",@"J",@"K",@"L",@"M",@"N",@"O",@"P",@"Q",@"R",@"S",@"T",@"U",@"V",@"W",@"X",@"Y",@"Z", nil];
    NSMutableArray *tempArray;
    NSString *prefix;
    for (int i=0; i<alphaArray.count; i++)
    {
        tempArray=[[NSMutableArray alloc] init];
        for(int j=0;j<_people.count;j++)
        {
            NSCharacterSet *whitespace = [NSCharacterSet whitespaceAndNewlineCharacterSet];
            CHDPeople *individualContact = [_people objectAtIndex:j];
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
    CHDAPIClient *apiClient = [CHDAPIClient sharedInstance];
    NSString *resoursePath = [apiClient resourcePathForGetPeople];
    [[[apiClient manager] cache] invalidateObjectsMatchingRegex:resoursePath];
}
@end
