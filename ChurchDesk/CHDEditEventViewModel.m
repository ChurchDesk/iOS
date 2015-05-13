//
//  CHDEditEventViewModel.m
//  ChurchDesk
//
//  Created by Mikkel Selsøe Sørensen on 06/03/15.
//  Copyright (c) 2015 Shape A/S. All rights reserved.
//

#import "CHDEditEventViewModel.h"
#import "CHDEvent.h"
#import "CHDAPIClient.h"
#import "CHDEnvironment.h"
#import "CHDUser.h"
#import "NSUserDefaults+CHDDefaults.h"
#import "CHDSitePermission.h"

NSString *const CHDEventEditSectionTitle = @"CHDEventEditSectionTitle";
NSString *const CHDEventEditSectionDate = @"CHDEventEditSectionDate";
NSString *const CHDEventEditSectionRecipients = @"CHDEventEditSectionRecipients";
NSString *const CHDEventEditSectionLocation = @"CHDEventEditSectionLocation";
NSString *const CHDEventEditSectionBooking = @"CHDEventEditSectionBooking";
NSString *const CHDEventEditSectionInternalNote = @"CHDEventEditSectionInternalNote";
NSString *const CHDEventEditSectionDescription = @"CHDEventEditSectionDescription";
NSString *const CHDEventEditSectionMisc = @"CHDEventEditSectionMisc";
NSString *const CHDEventEditSectionDivider = @"CHDEventEditSectionDivider";

NSString *const CHDEventEditRowTitle = @"CHDEventEditRowTitle";
NSString *const CHDEventEditRowAllDay = @"CHDEventEditRowAllDay";
NSString *const CHDEventEditRowStartDate = @"CHDEventEditRowStartDate";
NSString *const CHDEventEditRowEndDate = @"CHDEventEditRowEndDate";
NSString *const CHDEventEditRowParish = @"CHDEventEditRowParish";
NSString *const CHDEventEditRowGroup = @"CHDEventEditRowGroup";
NSString *const CHDEventEditRowCategories = @"CHDEventEditRowCategories";
NSString *const CHDEventEditRowLocation = @"CHDEventEditRowLocation";
NSString *const CHDEventEditRowResources = @"CHDEventEditRowResources";
NSString *const CHDEventEditRowUsers = @"CHDEventEditRowUsers";
NSString *const CHDEventEditRowInternalNote = @"CHDEventEditRowInternalNote";
NSString *const CHDEventEditRowDescription = @"CHDEventEditRowDescription";
NSString *const CHDEventEditRowContributor = @"CHDEventEditRowContributor";
NSString *const CHDEventEditRowPrice = @"CHDEventEditRowPrice";
NSString *const CHDEventEditRowDoubleBooking = @"CHDEventEditRowDoubleBooking";
NSString *const CHDEventEditRowVisibility = @"CHDEventEditRowVisibility";

NSString *const CHDEventEditRowDivider = @"CHDEventEditRowDivider";

@interface CHDEditEventViewModel ()

@property (nonatomic, strong) NSArray *sections;
@property (nonatomic, strong) NSDictionary *sectionRows;
@property (nonatomic, assign) BOOL newEvent;

@property (nonatomic, strong) CHDEnvironment *environment;
@property (nonatomic, strong) CHDUser *user;

@property (nonatomic, strong) RACCommand *saveCommand;

@end

@implementation CHDEditEventViewModel

- (instancetype)initWithEvent: (CHDEvent*) event {
    self = [super init];
    if (self) {
        _event = event ? [event copy] : [CHDEvent new];
        _newEvent = event == nil;

        if(_newEvent){
            self.event.groupId = [[NSUserDefaults standardUserDefaults] chdDefaultGroupId];
            self.event.siteId = [[NSUserDefaults standardUserDefaults] chdDefaultSiteId];
            self.event.visibility = CHDEventVisibilityOnlyInGroup;
        }

        [self rac_liftSelector:@selector(setEnvironment:) withSignals:[[CHDAPIClient sharedInstance] getEnvironment], nil];
        RACSignal *userSignal = [[CHDAPIClient sharedInstance] getCurrentUser];
        [self rac_liftSelector:@selector(setUser:) withSignals:userSignal, nil];

        self.sections = @[CHDEventEditSectionTitle, CHDEventEditSectionDate, CHDEventEditSectionRecipients, CHDEventEditSectionLocation, CHDEventEditSectionBooking, CHDEventEditSectionInternalNote, CHDEventEditSectionDescription, CHDEventEditSectionMisc, CHDEventEditSectionDivider];

        self.sectionRows = @{CHDEventEditSectionTitle : @[CHDEventEditRowDivider, CHDEventEditRowTitle],
                             CHDEventEditSectionDate : @[CHDEventEditRowDivider, CHDEventEditRowAllDay, CHDEventEditRowStartDate],
                             CHDEventEditSectionRecipients : @[],
                             CHDEventEditSectionLocation : @[CHDEventEditRowDivider, CHDEventEditRowLocation],
                             CHDEventEditSectionBooking : @[],
                             CHDEventEditSectionInternalNote : @[CHDEventEditRowDivider, CHDEventEditRowInternalNote],
                             CHDEventEditSectionDescription : @[CHDEventEditRowDivider, CHDEventEditRowDescription],
                             CHDEventEditSectionMisc : @[CHDEventEditRowDivider, CHDEventEditRowContributor, CHDEventEditRowPrice, CHDEventEditRowVisibility],
                             CHDEventEditSectionDivider : @[CHDEventEditRowDivider]};

        [self rac_liftSelector:@selector(setupSectionsWithUser:) withSignals:[RACSignal merge:@[userSignal,
            [RACObserve(self.event, siteId) flattenMap:^RACStream *(id value) {
                return [[CHDAPIClient sharedInstance] getCurrentUser];
            }],
            [RACObserve(self.event, startDate) flattenMap:^RACStream *(id value) {
                return [[CHDAPIClient sharedInstance] getCurrentUser];
            }],
            [RACObserve(self.event, groupId) flattenMap:^RACStream *(id value) {
                return [[CHDAPIClient sharedInstance] getCurrentUser];
            }]
        ]],nil];
    }
    return self;
}

-(void) setupSectionsWithUser: (CHDUser *) user{

    NSArray *recipientsRows = _newEvent && user.sites.count > 1 ? @[CHDEventEditRowDivider, CHDEventEditRowParish, CHDEventEditRowGroup, CHDEventEditRowCategories] : @[CHDEventEditRowDivider, CHDEventEditRowGroup, CHDEventEditRowCategories];
    NSArray *bookingRows = @[CHDEventEditRowDivider, CHDEventEditRowResources, CHDEventEditRowUsers];

    if(self.event.siteId == nil){
        for(CHDSite *site in user.sites){
            if(site.permissions.canCreateEvent){
                self.event.siteId = site.siteId;
                break;
            }
        }
    }

    if(!self.event.siteId){
        recipientsRows = @[CHDEventEditRowDivider, CHDEventEditRowParish];
        bookingRows = @[];
    }
    else if([self.event.groupId isEqualToNumber:@0] || !self.event.groupId){
        bookingRows = @[CHDEventEditRowDivider, CHDEventEditRowResources];
    }

    NSArray *dateRows = self.event.startDate != nil? @[CHDEventEditRowDivider, CHDEventEditRowAllDay, CHDEventEditRowStartDate, CHDEventEditRowEndDate] : @[CHDEventEditRowDivider, CHDEventEditRowAllDay, CHDEventEditRowStartDate];
    NSArray *miscRows = [user siteWithId:self.event.siteId].permissions.canDoubleBook? @[CHDEventEditRowDivider, CHDEventEditRowContributor, CHDEventEditRowPrice, CHDEventEditRowDoubleBooking, CHDEventEditRowVisibility] : @[CHDEventEditRowDivider, CHDEventEditRowContributor, CHDEventEditRowPrice, CHDEventEditRowVisibility];

    self.sectionRows = @{CHDEventEditSectionTitle : @[CHDEventEditRowDivider, CHDEventEditRowTitle],
        CHDEventEditSectionDate : dateRows,
        CHDEventEditSectionRecipients : recipientsRows,
        CHDEventEditSectionLocation : @[CHDEventEditRowDivider, CHDEventEditRowLocation],
        CHDEventEditSectionBooking : bookingRows,
        CHDEventEditSectionInternalNote : @[CHDEventEditRowDivider, CHDEventEditRowInternalNote],
        CHDEventEditSectionDescription : @[CHDEventEditRowDivider, CHDEventEditRowDescription],
        CHDEventEditSectionMisc : miscRows,
        CHDEventEditSectionDivider : @[CHDEventEditRowDivider]};

}

- (NSArray*)rowsForSectionAtIndex: (NSInteger) section {
    return self.sectionRows[self.sections[section]];
}

- (RACSignal*) saveEvent {
    [self storeDefaults];
    return [self.saveCommand execute:RACTuplePack(@(self.newEvent), self.event)];
}

- (NSString*) formatDate: (NSDate*) date allDay: (BOOL) isAllday {
    NSDateFormatter *dateFormatter = [NSDateFormatter new];
    dateFormatter.dateStyle = NSDateFormatterLongStyle;
    dateFormatter.timeStyle = isAllday? NSDateFormatterNoStyle : NSDateFormatterShortStyle;

    return [dateFormatter stringFromDate:date];
}

-(void) storeDefaults {
    if(self.event.siteId){
        [[NSUserDefaults standardUserDefaults] chdSetDefaultSiteId:self.event.siteId];
    }

    if(self.event.groupId){
        [[NSUserDefaults standardUserDefaults] chdSetDefaultGroupId:self.event.groupId];
    }
}

#pragma mark - Lazy Initialization

- (RACCommand *)saveCommand {
    if (!_saveCommand) {
        _saveCommand = [[RACCommand alloc] initWithSignalBlock:^RACSignal *(RACTuple *tuple) {
            BOOL newEvent = [tuple.first boolValue];
            CHDEvent *event = tuple.second;

            if (newEvent) {
                return [[CHDAPIClient sharedInstance] createEventWithEvent:event];
            }
            else {
                return [[CHDAPIClient sharedInstance] updateEventWithEvent:event];
            }
        }];
    }
    return _saveCommand;
}

@end
