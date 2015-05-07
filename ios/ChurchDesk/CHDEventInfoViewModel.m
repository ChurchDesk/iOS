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
@import MapKit;

NSString *const CHDEventInfoSectionImage = @"CHDEventInfoSectionImage";
NSString *const CHDEventInfoSectionTitle = @"CHDEventInfoSectionTitle";
NSString *const CHDEventInfoSectionBase = @"CHDEventInfoSectionBase";
NSString *const CHDEventInfoSectionResources = @"CHDEventInfoSectionResources";
NSString *const CHDEventInfoSectionContribution = @"CHDEventInfoSectionContribution";
NSString *const CHDEventInfoSectionVisibility = @"CHDEventInfoSectionVisibility";
NSString *const CHDEventInfoSectionDivider = @"CHDEventInfoSectionDivider";

NSString *const CHDEventInfoRowImage = @"CHDEventInfoRowImage";
NSString *const CHDEventInfoRowTitle = @"CHDEventInfoRowTitle";
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

@property (nonatomic, strong) CHDEnvironment *environment;
@property (nonatomic, strong) CHDUser *user;

@property (nonatomic, strong) NSDictionary *sectionRows;
@property (nonatomic, strong) NSArray *sections;

@property (nonatomic, strong) RACCommand *loadCommand;

@end

@implementation CHDEventInfoViewModel

- (instancetype)initWithEvent: (CHDEvent*) event {
    _event = event;
    return [self initWithEventId:event.eventId siteId:event.siteId];
}

- (instancetype)initWithEventId: (NSNumber*) eventId siteId: (NSString*) siteId {
    self = [super init];
    if (self) {
        
        RAC(self, environment) = [[[CHDAPIClient sharedInstance] getEnvironment] catch:^RACSignal *(NSError *error) {
            return [RACSignal empty];
        }];
        
        RAC(self, user) = [[[CHDAPIClient sharedInstance] getCurrentUser] catch:^RACSignal *(NSError *error) {
            return [RACSignal empty];
        }];

        [self shprac_liftSelector:@selector(configureSectionsWithEvent:) withSignal:[self.loadCommand execute:RACTuplePack(eventId, siteId)]];
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
        return [self.event.eventCategoryIds containsObject:category.categoryId] && [self.event.siteId isEqualToString:category.siteId];
    }];
    
    return [categories shp_map:^id(CHDEventCategory *category) {
        return category.name;
    }];
}

- (NSArray*) categoryColors {
    NSArray *categories = [self.environment.eventCategories shp_filter:^BOOL(CHDEventCategory *category) {
        return [self.event.eventCategoryIds containsObject:category.categoryId] && [self.event.siteId isEqualToString:category.siteId];
    }];
    
    return [categories shp_map:^id(CHDEventCategory *category) {
        return category.color;
    }];
}

- (NSArray*) resourceTitles {
    NSArray *resources = [self.environment.resources shp_filter:^BOOL(CHDResource *resource) {
        return [self.event.resourceIds containsObject:resource.resourceId] && [self.event.siteId isEqualToString:resource.siteId];
    }];
    
    return [resources shp_map:^id(CHDResource *resource) {
        return resource.name;
    }];
}

- (NSArray*) resourceColors {
    NSArray *resources = [self.environment.resources shp_filter:^BOOL(CHDResource *resource) {
        return [self.event.resourceIds containsObject:resource.resourceId] && [resource.siteId isEqualToString:self.event.siteId];
    }];
    
    return [resources shp_map:^id(CHDResource *resource) {
        return resource.color;
    }];
}

- (NSArray*) userNames {
    NSArray *resources = [self.environment.users shp_filter:^BOOL(CHDPeerUser *user) {
        return [self.event.userIds containsObject:user.userId] && [self.event.siteId isEqualToString:user.siteId];
    }];
    
    return [resources shp_map:^id(CHDPeerUser *user) {
        return user.name;
    }];
}

- (NSString*) parishName {
    if (self.user.sites.count > 1) {
        CHDSite *site = [self.user siteWithId:self.event.siteId];
        return site.name;
    }
    return @"";
}

- (NSString*) eventDateString {
    NSCalendar *calendar = [NSCalendar currentCalendar];
    unsigned unitFlags = NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear;

    NSDateFormatter *dateFormatterFrom = [NSDateFormatter new];
    NSDateFormatter *dateFormatterTo = [NSDateFormatter new];

    NSDateComponents *fromComponents = [calendar components:unitFlags fromDate:self.event.startDate];
    NSDateComponents *toComponents = [calendar components:unitFlags fromDate:self.event.endDate];

    //Set date format Templates
    NSString *dateComponentFrom;
    NSString *dateComponentTo;

    if(fromComponents.year != toComponents.year){
        dateComponentFrom = self.event.allDayEvent? @"ddMMM" : @"ddMMMjjmm";
        dateComponentTo = self.event.allDayEvent? @"ddMMMYY" : @"ddMMMYYjjmm";
    }else if(fromComponents.month != toComponents.month){
        dateComponentFrom = self.event.allDayEvent? @"eeeddMMM" : @"eeeddMMMjjmm";
        dateComponentTo = self.event.allDayEvent? @"eeeddMMM" :@"eeeddMMMjjmm";
    }else if(fromComponents.day != toComponents.day){
        dateComponentFrom = self.event.allDayEvent? @"eeeddMMM" : @"eeeddMMMjjmm";
        dateComponentTo = self.event.allDayEvent? @"eeedd" : @"eeeddjjmm";
    }else{
        dateComponentFrom = self.event.allDayEvent? @"eeeeddMMM" : @"eeeeddMMMjjmm";
        dateComponentTo = self.event.allDayEvent? @"" : @"jjmm";
    }

    NSLocale *locale = [NSLocale currentLocale];
    NSString *dateTemplateFrom = [NSDateFormatter dateFormatFromTemplate:dateComponentFrom options:0 locale:locale];
    NSString *dateTemplateTo = [NSDateFormatter dateFormatFromTemplate:dateComponentTo options:0 locale:locale];

    [dateFormatterFrom setDateFormat:dateTemplateFrom];
    [dateFormatterTo setDateFormat:dateTemplateTo];

    //Localize the date
    dateFormatterFrom.locale = locale;
    dateFormatterTo.locale = locale;

    NSString *startDate = [dateFormatterFrom stringFromDate:self.event.startDate];
    NSString *endDate = [dateFormatterTo stringFromDate:self.event.endDate];
    NSString *formattedDate = [endDate isEqualToString:@""]? startDate : [[startDate stringByAppendingString:@" - "] stringByAppendingString:endDate];

    return formattedDate;
}

#pragma mark - Actions

- (void) openMapsWithLocationString: (NSString*) location {
        MKLocalSearchRequest *request = [[MKLocalSearchRequest alloc] init];
        request.naturalLanguageQuery = location;
        
        MKLocalSearch *search = [[MKLocalSearch alloc] initWithRequest:request];
        
        [search startWithCompletionHandler:^(MKLocalSearchResponse *response, NSError *error) {
            if (response) {
                MKMapItem *mapItem = response.mapItems.firstObject;
                [mapItem openInMapsWithLaunchOptions:nil];
            }
        }];
}

- (RACSignal*) respondToEventWithResponse: (CHDEventResponse) response {
    CHDEvent *event = self.event;
    CHDEventResponse oldResponse = event.eventResponse;
    self.event.eventResponse = response;

    RACSignal *eventSignal = [[[CHDAPIClient sharedInstance] setResponseForEventWithId:self.event.eventId siteId:self.event.siteId response:response] doError:^(NSError *error) {
        event.eventResponse = oldResponse;
    }];

    [eventSignal subscribeNext:^(id x) {
        NSLog(@"Event response");
    }];

    return eventSignal;
}

-(RACCommand*)loadCommand {
    if(!_loadCommand){
        _loadCommand = [[RACCommand alloc] initWithSignalBlock:^RACSignal *(RACTuple *tuple) {
            NSNumber *eventId = tuple.first;
            NSString *siteId = tuple.second;

            return [[CHDAPIClient sharedInstance] getEventWithId:eventId siteId:siteId];
        }];
    }
    return _loadCommand;
}

#pragma mark - Private

- (void) configureSectionsWithEvent: (CHDEvent*) event {
    
    NSMutableDictionary *mSectionRows = [NSMutableDictionary dictionary];
    
    // Image section
    if (event.pictureURL) {
        mSectionRows[CHDEventInfoSectionImage] = @[CHDEventInfoRowImage];
    }else{
        mSectionRows[CHDEventInfoSectionTitle] = @[CHDEventInfoRowTitle];
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
    }else{
        [mSections addObject:CHDEventInfoSectionTitle];
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
        [mSections addObject:CHDEventInfoSectionDivider];
    }
    
    self.sections = [mSections copy];
    self.sectionRows = [mSectionRows copy];
    self.event = event;
}

@end
