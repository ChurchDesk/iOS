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
    NSLog(@"section rows %@", self.sectionRows);
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

- (NSString*) textForEventResponse: (NSString *) response {
    if ([response isEqualToString:CHDInvitationAccept]) {
        return NSLocalizedString(@"Going", @"");
    }
    else if ([response isEqualToString:CHDInvitationDecline]){
        return NSLocalizedString(@"Not going", @"");
    }
    else if ([response isEqualToString:CHDInvitationMaybe]){
        return NSLocalizedString(@"Maybe", @"");
    }
    else{
        return NSLocalizedString(@"No reply", @"");
    }
    
}

- (UIColor*) textColorForEventResponse: (NSString *) response {
    if ([response isEqualToString:CHDInvitationAccept]) {
        return [UIColor chd_eventAcceptColor];
    }
    else if ([response isEqualToString:CHDInvitationDecline]){
        return [UIColor chd_eventDeclineColor];
    }
    else if ([response isEqualToString:CHDInvitationMaybe]){
        return [UIColor chd_eventMaybeColor];
    }
    else{
        return [UIColor chd_textDarkColor];
    }
}

- (NSArray*) categoryTitles {
    NSArray *categories = [self.environment.eventCategories shp_filter:^BOOL(CHDEventCategory *category) {
        return [self.event.eventCategoryIds containsObject:category.categoryId.stringValue] && [self.event.siteId isEqualToString:category.siteId];
    }];
    
    return [categories shp_map:^id(CHDEventCategory *category) {
        return category.name;
    }];
}

- (NSArray*) categoryColors {
    NSArray *categories = [self.environment.eventCategories shp_filter:^BOOL(CHDEventCategory *category) {
        return [self.event.eventCategoryIds containsObject:category.categoryId.stringValue] && [self.event.siteId isEqualToString:category.siteId];
    }];
    
    return [categories shp_map:^id(CHDEventCategory *category) {
        return category.color;
    }];
}

- (NSArray*) resourceTitles {
    NSArray *resources = [self.environment.resources shp_filter:^BOOL(CHDResource *resource) {
        return [self.event.resourceIds containsObject:resource.resourceId.stringValue] && [self.event.siteId isEqualToString:resource.siteId];
    }];
    
    return [resources shp_map:^id(CHDResource *resource) {
        return resource.name;
    }];
}

- (NSArray*) resourceColors {
    NSArray *resources = [self.environment.resources shp_filter:^BOOL(CHDResource *resource) {
        return [self.event.resourceIds containsObject:resource.resourceId.stringValue] && [resource.siteId isEqualToString:self.event.siteId];
    }];
    
    return [resources shp_map:^id(CHDResource *resource) {
        return resource.color;
    }];
}

- (NSArray*) userNames {
    NSArray *resources = [self.environment.users shp_filter:^BOOL(CHDPeerUser *user) {
        return [self.event.userIds containsObject:user.userId.stringValue];
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

- (RACSignal*) respondToEventWithResponse: (NSString*) response {
    CHDEvent *event = self.event;
    NSString *oldResponse = event.eventResponse;
    self.event.eventResponse = response;
    for (NSMutableDictionary *dict in self.event.attendenceStatus) {
        NSString *userIdFromDict = dict[@"user"];
        if (userIdFromDict.intValue == self.user.userId.intValue) {
            NSMutableDictionary *dictCopy = [dict mutableCopy];
            [dictCopy setValue:response forKey:@"status"];
    
            NSMutableArray *attendanceStatusCopy = [self.event.attendenceStatus mutableCopy];
            [attendanceStatusCopy replaceObjectAtIndex:[self.event.attendenceStatus indexOfObject:dict] withObject:dictCopy];
            self.event.attendenceStatus = attendanceStatusCopy;
        }
    }
    NSLog(@"site id %@", self.event.siteId);
    RACSignal *eventSignal = [[[CHDAPIClient sharedInstance] setResponseForEventWithId:self.event.eventId siteId:self.event.siteId response:response] doError:^(NSError *error) {
        event.eventResponse = oldResponse;
        for (NSMutableDictionary *dict in self.event.attendenceStatus) {
            NSString *userIdFromDict = dict[@"user"];
            if (userIdFromDict.intValue == self.user.userId.intValue) {
                NSMutableDictionary *dictCopy = [dict mutableCopy];
                [dictCopy setValue:oldResponse forKey:@"status"];
                
                
                NSMutableArray *attendanceStatusCopy = [self.event.attendenceStatus mutableCopy];
                [attendanceStatusCopy replaceObjectAtIndex:[self.event.attendenceStatus indexOfObject:dict] withObject:dictCopy];
                self.event.attendenceStatus = attendanceStatusCopy;
            }
        }
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
    }
    
    // Base section
    NSMutableArray *baseRows = [NSMutableArray array];
    if(!event.pictureURL){
        [baseRows addObject:CHDEventInfoRowTitle];
    }
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
    if ([event.userIds containsObject: self.user.userId.stringValue] ) {
        event.eventResponse = [event attendanceStatusForUserWithId:self.user.userId];
        [baseRows addObject:CHDEventInfoRowAttendance];
    }
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
        [mSections addObject:CHDEventInfoSectionDivider];
        //The title is added to the baseSection (in order to keep the seperator line)
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
