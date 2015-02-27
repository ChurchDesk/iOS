//
//  CHDEventInfoViewModel.m
//  ChurchDesk
//
//  Created by Mikkel Selsøe Sørensen on 26/02/15.
//  Copyright (c) 2015 Shape A/S. All rights reserved.
//

#import "CHDEventInfoViewModel.h"
#import "CHDEvent.h"
#import "CHDAPIClient.h"

NSString *const CHDEventInfoSectionImage = @"CHDEventInfoSectionImage";
NSString *const CHDEventInfoSectionBase = @"CHDEventInfoSectionBase";
NSString *const CHDEventInfoSectionResources = @"CHDEventInfoSectionResources";
NSString *const CHDEventInfoSectionContribution = @"CHDEventInfoSectionContribution";
NSString *const CHDEventInfoSectionVisibility = @"CHDEventInfoSectionVisibility";
NSString *const CHDEventInfoSectionDivider = @"CHDEventInfoSectionDivider";

NSString *const CHDEventInfoRowImage = @"CHDEventInfoRowImage";
NSString *const CHDEventInfoRowGroup = @"CHDEventInfoRowGroup";
NSString *const CHDEventInfoRowDate = @"CHDEventInfoRowDate";
NSString *const CHDEventInfoRowLocation = @"CHDEventInfoRowLocation";
NSString *const CHDEventInfoRowCategories = @"CHDEventInfoRowCategories";
NSString *const CHDEventInfoRowAttendance = @"CHDEventInfoRowAttendance";
NSString *const CHDEventInfoRowResources = @"CHDEventInfoRowResources";
NSString *const CHDEventInfoRowUsers = @"CHDEventInfoRowUsers";
NSString *const CHDEventInfoRowInternalNote = @"CHDEventInfoRowInternalNote";
NSString *const CHDEventInfoRowContributor = @"CHDEventInfoRowContributor";
NSString *const CHDEventInfoRowPrice = @"CHDEventInfoRowPrice";
NSString *const CHDEventInfoRowDescription = @"CHDEventInfoRowDescription";
NSString *const CHDEventInfoRowVisibility = @"CHDEventInfoRowVisibility";
NSString *const CHDEventInfoRowCreated = @"CHDEventInfoRowCreated";
NSString *const CHDEventInfoRowDivider = @"CHDEventInfoRowDivider";

@interface CHDEventInfoViewModel ()

@property (nonatomic, strong) CHDEvent *event;
@property (nonatomic, strong) NSDictionary *sectionRows;
@property (nonatomic, strong) NSArray *sections;

@end

@implementation CHDEventInfoViewModel

- (instancetype)initWithEventId: (NSNumber*) eventId {
    self = [super init];
    if (self) {
        [self shprac_liftSelector:@selector(configureSectionsWithEvent:) withSignal:[[CHDAPIClient sharedInstance] getEventWithId:eventId site:@"site"]];
    }
    return self;
}

- (NSArray *)rowsForSection:(NSString *)section {
    if ([section isEqualToString:CHDEventInfoSectionDivider]) {
        return @[CHDEventInfoRowDivider];
    }
    return self.sectionRows[section];
}

#pragma mark - Private

- (void) configureSectionsWithEvent: (CHDEvent*) event {
    
    NSMutableDictionary *mSectionRows = [NSMutableDictionary dictionary];
    
    // Image section
    if (event.pictureURL) {
        mSectionRows[CHDEventInfoSectionImage] = @[CHDEventInfoRowImage];
    }
    
    // Base section
    NSMutableArray *baseRows = [NSMutableArray array];
    if (event.groupId) {
        [baseRows addObject:CHDEventInfoRowGroup];
    }
    [baseRows addObject:CHDEventInfoRowDate];
    if (event.location.length) {
        [baseRows addObject:CHDEventInfoRowLocation];
    }
    if (event.eventCategoryIds.count > 0) {
        [baseRows addObject:CHDEventInfoRowCategories];
    }
    [baseRows addObject:CHDEventInfoRowAttendance];
    mSectionRows[CHDEventInfoSectionBase] = [baseRows copy];
    
    // Resources section
    NSMutableArray *resourceRows = [NSMutableArray array];
    if (self.event.resourceIds.count > 0) {
        [resourceRows addObject:CHDEventInfoRowResources];
    }
    if (self.event.userIds.count > 0) {
        [resourceRows addObject:CHDEventInfoRowUsers];
    }
    if (self.event.internalNote.length > 0) {
        [resourceRows addObject:CHDEventInfoRowInternalNote];
    }
    mSectionRows[CHDEventInfoSectionResources] = [resourceRows copy];
    
    // Contribution section
    NSMutableArray *contributionRows = [NSMutableArray array];
    if (event.contributor.length > 0) {
        [contributionRows addObject:CHDEventInfoRowContributor];
    }
    if (event.price.length > 0) {
        [contributionRows addObject:CHDEventInfoRowPrice];
    }
    if (event.eventDescription.length > 0) {
        [contributionRows addObject:CHDEventInfoRowDescription];
    }
    mSectionRows[CHDEventInfoSectionContribution] = [contributionRows copy];
    
    // Visibility section
    NSMutableArray *visibilityRows = [NSMutableArray array];
    [visibilityRows addObject:CHDEventInfoRowVisibility];
    [visibilityRows addObject:CHDEventInfoRowCreated];
    mSectionRows[CHDEventInfoSectionVisibility] = [visibilityRows copy];
    
    // Sections
    NSMutableArray *mSections = [NSMutableArray array];
    if (event.pictureURL) {
        [mSections addObject:CHDEventInfoSectionImage];
    }
    if (baseRows.count > 0) {
        [mSections addObject:CHDEventInfoSectionBase];
        [mSections addObject:CHDEventInfoSectionDivider];
    }
    if (resourceRows.count > 0) {
        [mSections addObject:CHDEventInfoSectionResources];
        [mSections addObject:CHDEventInfoSectionDivider];
    }
    if (contributionRows.count > 0) {
        [mSections addObject:CHDEventInfoSectionContribution];
        [mSections addObject:CHDEventInfoSectionDivider];
    }
    if (visibilityRows.count > 0) {
        [mSections addObject:CHDEventInfoSectionBase];
    }
    
    self.sections = [mSections copy];
    self.sectionRows = [mSectionRows copy];
    self.event = event;
}

@end
