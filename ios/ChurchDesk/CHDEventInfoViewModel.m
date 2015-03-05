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
#import "CHDEnvironment.h"
#import "CHDUser.h"
#import "CHDSite.h"

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
@property (nonatomic, strong) CHDEnvironment *environment;
@property (nonatomic, strong) CHDUser *user;

@property (nonatomic, strong) NSDictionary *sectionRows;
@property (nonatomic, strong) NSArray *sections;

@end

@implementation CHDEventInfoViewModel

- (instancetype)initWithEvent: (CHDEvent*) event {
    self = [super init];
    if (self) {
        _event = event;
        RAC(self, environment) = [[[CHDAPIClient sharedInstance] getEnvironment] catch:^RACSignal *(NSError *error) {
            return [RACSignal empty];
        }];
        
        RAC(self, user) = [[[CHDAPIClient sharedInstance] getCurrentUser] catch:^RACSignal *(NSError *error) {
            return [RACSignal empty];
        }];
        
        [self shprac_liftSelector:@selector(configureSectionsWithEvent:) withSignal:[[[CHDAPIClient sharedInstance] getEventWithId:event.eventId site:event.site] startWith:event]];
    }
    return self;
}

- (NSArray *)rowsForSection:(NSString *)section {
    if ([section isEqualToString:CHDEventInfoSectionDivider]) {
        return @[CHDEventInfoRowDivider];
    }
    return self.sectionRows[section];
}

- (NSString*) textForEventResponse: (CHDEventResponse) response {
    switch (response) {
        case CHDEventResponseGoing:
            return NSLocalizedString(@"Going", @"");
        case CHDEventResponseNotGoing:
            return NSLocalizedString(@"Not going", @"");
        case CHDEventResponseMaybe:
            return NSLocalizedString(@"Maybe", @"");
        case CHDEventResponseNone:
        default:
            return NSLocalizedString(@"No reply", @"");
    }
}

- (UIColor*) textColorForEventResponse: (CHDEventResponse) response {
    switch (response) {
        case CHDEventResponseGoing:
            return [UIColor chd_eventAcceptColor];
        case CHDEventResponseNotGoing:
            return [UIColor chd_eventDeclineColor];
        case CHDEventResponseMaybe:
            return [UIColor chd_eventMaybeColor];
        case CHDEventResponseNone:
        default:
            return [UIColor chd_textDarkColor];
    }
}

- (NSArray*) categoryTitles {
    NSArray *categories = [self.environment.eventCategories shp_filter:^BOOL(CHDEventCategory *category) {
        return [self.event.eventCategoryIds containsObject:category.categoryId];
    }];
    
    return [categories shp_map:^id(CHDEventCategory *category) {
        return category.name;
    }];
}

- (NSArray*) categoryColors {
    NSArray *categories = [self.environment.eventCategories shp_filter:^BOOL(CHDEventCategory *category) {
        return [self.event.eventCategoryIds containsObject:category.categoryId];
    }];
    
    return [categories shp_map:^id(CHDEventCategory *category) {
        return category.color;
    }];
}

- (NSArray*) resourceTitles {
    NSArray *resources = [self.environment.resources shp_filter:^BOOL(CHDResource *resource) {
        return [self.event.resourceIds containsObject:resource.resourceId];
    }];
    
    return [resources shp_map:^id(CHDResource *resource) {
        return resource.name;
    }];
}

- (NSArray*) resourceColors {
    NSArray *resources = [self.environment.resources shp_filter:^BOOL(CHDResource *resource) {
        return [self.event.resourceIds containsObject:resource.resourceId];
    }];
    
    return [resources shp_map:^id(CHDResource *resource) {
        return resource.color;
    }];
}

- (NSArray*) userNames {
    NSArray *resources = [self.environment.users shp_filter:^BOOL(CHDPeerUser *user) {
        return [self.event.userIds containsObject:user.userId];
    }];
    
    return [resources shp_map:^id(CHDPeerUser *user) {
        return user.name;
    }];
}

- (NSString*) parishName {
    if (self.user.sites.count > 1) {
        CHDSite *site = [self.user siteWithId:self.event.site];
        return site.name;
    }
    return @"";
}

- (NSString*) eventDateString {
    NSDateFormatter *dateFormatter = [NSDateFormatter new];
    dateFormatter.dateFormat = @"EEEE d LLL, HH:mm";
    NSString *fromString = [dateFormatter stringFromDate:self.event.startDate];
    
    NSDateFormatter *timeFormatter = [NSDateFormatter new];
    timeFormatter.dateFormat = @"HH:mm";
    NSString *toString = [timeFormatter stringFromDate:self.event.endDate];
    
    return [NSString stringWithFormat:@"%@ - %@", fromString, toString];
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
    if (event.resourceIds.count > 0) {
        [resourceRows addObject:CHDEventInfoRowResources];
    }
    if (event.userIds.count > 0) {
        [resourceRows addObject:CHDEventInfoRowUsers];
    }
    if (event.internalNote.length > 0) {
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
        [mSections addObject:CHDEventInfoSectionVisibility];
    }
    
    self.sections = [mSections copy];
    self.sectionRows = [mSectionRows copy];
    self.event = event;
}

@end
