//
//  CHDEditAbsenceViewModel.m
//  ChurchDesk
//
//  Created by Chirag Sharma on 22/12/15.
//  Copyright © 2015 Shape A/S. All rights reserved.
//

#import "CHDEditAbsenceViewModel.h"
#import "CHDEvent.h"
#import "CHDAPIClient.h"
#import "CHDEnvironment.h"
#import "CHDUser.h"
#import "NSUserDefaults+CHDDefaults.h"
#import "CHDSitePermission.h"

NSString *const CHDAbsenceEditSectionDate = @"CHDAbsenceEditSectionDate";
NSString *const CHDAbsenceEditSectionRecipients = @"CHDAbsenceEditSectionRecipients";
NSString *const CHDAbsenceEditSectionBooking = @"CHDAbsenceEditSectionBooking";
NSString *const CHDAbsenceEditSectionSubstitute = @"CHDEventEditSectionSubstitute";
NSString *const CHDAbsenceEditSectionComments = @"CHDAbsenceEditSectionComments";
NSString *const CHDAbsenceEditSectionMisc = @"CHDAbsenceEditSectionMisc";
NSString *const CHDAbsenceEditSectionDivider = @"CHDAbsenceEditSectionDivider";

NSString *const CHDAbsenceEditRowTitle = @"CHDAbsenceEditRowTitle";
NSString *const CHDAbsenceEditRowAllDay = @"CHDAbsenceEditRowAllDay";
NSString *const CHDAbsenceEditRowStartDate = @"CHDAbsenceEditRowStartDate";
NSString *const CHDAbsenceEditRowEndDate = @"CHDAbsenceEditRowEndDate";
NSString *const CHDAbsenceEditRowParish = @"CHDAbsenceEditRowParish";
NSString *const CHDAbsenceEditRowGroup = @"CHDAbsenceEditRowGroup";
NSString *const CHDAbsenceEditRowCategories = @"CHDAbsenceEditRowCategories";
NSString *const CHDAbsenceEditRowLocation = @"CHDAbsenceEditRowLocation";
NSString *const CHDAbsenceEditRowResources = @"CHDAbsenceEditRowResources";
NSString *const CHDAbsenceEditRowUsers = @"CHDAbsenceEditRowUsers";
NSString *const CHDAbsenceEditRowSubstitute = @"CHDAbsenceEditRowSubstitute";
NSString *const CHDAbsenceEditRowComments = @"CHDAbsenceEditRowComments";
NSString *const CHDAbsenceEditRowContributor = @"CHDAbsenceEditRowContributor";
NSString *const CHDAbsenceEditRowPrice = @"CHDAbsenceEditRowPrice";
NSString *const CHDAbsenceEditRowDoubleBooking = @"CHDAbsenceEditRowDoubleBooking";
NSString *const CHDAbsenceEditRowVisibility = @"CHDAbsenceEditRowVisibility";

NSString *const CHDAbsenceEditRowDivider = @"CHDAbsenceEditRowDivider";
@interface CHDEditAbsenceViewModel ()

@property (nonatomic, strong) NSArray *sections;
@property (nonatomic, strong) NSDictionary *sectionRows;
@property (nonatomic, assign) BOOL newAbsence;

@property (nonatomic, strong) CHDEnvironment *environment;
@property (nonatomic, strong) CHDUser *user;

@property (nonatomic, strong) RACCommand *saveCommand;

@end
@implementation CHDEditAbsenceViewModel
- (instancetype)initWithEvent: (CHDEvent*) event {
    self = [super init];
    if (self) {
        _event = event ? [event copy] : [CHDEvent new];
        _event.type = kAbsence;
        _newEvent = event == nil;
        
        if(_newEvent){
            self.event.groupId = [[NSUserDefaults standardUserDefaults] chdDefaultGroupId];
            self.event.siteId = [[NSUserDefaults standardUserDefaults] chdDefaultSiteId];
        }
        
        [self rac_liftSelector:@selector(setEnvironment:) withSignals:[[CHDAPIClient sharedInstance] getEnvironment], nil];
        RACSignal *userSignal = [[CHDAPIClient sharedInstance] getCurrentUser];
        [self rac_liftSelector:@selector(setUser:) withSignals:userSignal, nil];
        
        self.sections = @[ CHDAbsenceEditSectionDate, CHDAbsenceEditSectionRecipients, CHDAbsenceEditSectionBooking, CHDAbsenceEditSectionSubstitute, CHDAbsenceEditSectionComments, CHDAbsenceEditSectionDivider];
        
        self.sectionRows = @{CHDAbsenceEditSectionDate : @[CHDAbsenceEditRowDivider,                    CHDAbsenceEditRowAllDay, CHDAbsenceEditRowStartDate],
                             CHDAbsenceEditSectionRecipients : @[],
                             CHDAbsenceEditSectionBooking : @[],
                             CHDAbsenceEditSectionSubstitute : @[CHDAbsenceEditRowDivider, CHDAbsenceEditRowSubstitute],
                             CHDAbsenceEditSectionComments : @[CHDAbsenceEditRowDivider, CHDAbsenceEditRowComments],
                             //CHDAbsenceEditSectionMisc : @[CHDAbsenceEditRowDivider, CHDAbsenceEditRowContributor, CHDAbsenceEditRowPrice, CHDAbsenceEditRowVisibility],
                             CHDAbsenceEditSectionDivider : @[CHDAbsenceEditRowDivider]};
        
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
    
    NSArray *recipientsRows = _newEvent && user.sites.count > 1 ? @[CHDAbsenceEditRowDivider, CHDAbsenceEditRowParish, CHDAbsenceEditRowGroup, CHDAbsenceEditRowCategories] : @[CHDAbsenceEditRowDivider, CHDAbsenceEditRowGroup, CHDAbsenceEditRowCategories];
    NSArray *bookingRows = @[CHDAbsenceEditRowDivider, CHDAbsenceEditRowUsers];
    
    if(self.event.siteId == nil){
        for(CHDSite *site in user.sites){
            if(site.permissions.canCreateAbsence){
                self.event.siteId = site.siteId;
                break;
            }
        }
    }
    
    if(!self.event.siteId){
        recipientsRows = @[CHDAbsenceEditRowDivider, CHDAbsenceEditRowParish];
        bookingRows = @[];
    }
//    else if([self.event.groupId isEqualToNumber:@0] || !self.event.groupId){
//        bookingRows = @[CHDAbsenceEditRowDivider, CHDAbsenceEditRowResources];
//    }
    
    NSArray *dateRows = self.event.startDate != nil? @[CHDAbsenceEditRowDivider, CHDAbsenceEditRowAllDay, CHDAbsenceEditRowStartDate, CHDAbsenceEditRowEndDate] : @[CHDAbsenceEditRowDivider, CHDAbsenceEditRowAllDay, CHDAbsenceEditRowStartDate];
    //NSArray *miscRows = @[CHDAbsenceEditRowDivider, CHDAbsenceEditRowContributor];
    
    self.sectionRows = @{
                         CHDAbsenceEditSectionDate : dateRows,
                         CHDAbsenceEditSectionRecipients : recipientsRows,
                         CHDAbsenceEditSectionBooking : bookingRows,
                         CHDAbsenceEditSectionSubstitute : @[CHDAbsenceEditRowDivider, CHDAbsenceEditRowSubstitute],
                         CHDAbsenceEditSectionComments : @[CHDAbsenceEditRowDivider, CHDAbsenceEditRowComments],
                         //CHDAbsenceEditSectionMisc : miscRows,
                         CHDAbsenceEditSectionDivider : @[CHDAbsenceEditRowDivider]};
    
}

- (NSArray*)rowsForSectionAtIndex: (NSInteger) section {
    return self.sectionRows[self.sections[section]];
}

- (RACSignal*) saveEvent {
    [self storeDefaults];
    if (self.event.allDayEvent) {
        NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier: NSCalendarIdentifierGregorian];
        NSDateComponents *components = [gregorian components: NSUIntegerMax fromDate: self.event.endDate];
        [components setHour: 23];
        [components setMinute: 59];
        [components setSecond: 59];
        self.event.endDate = [gregorian dateFromComponents: components];
    }
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
