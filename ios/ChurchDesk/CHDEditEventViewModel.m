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
        
        [self rac_liftSelector:@selector(setEnvironment:) withSignals:[[CHDAPIClient sharedInstance] getEnvironment], nil];
        [self rac_liftSelector:@selector(setUser:) withSignals:[[CHDAPIClient sharedInstance] getCurrentUser], nil];
        
        self.sections = @[CHDEventEditSectionTitle, CHDEventEditSectionDate, CHDEventEditSectionRecipients, CHDEventEditSectionLocation, CHDEventEditSectionBooking, CHDEventEditSectionInternalNote, CHDEventEditSectionDescription, CHDEventEditSectionMisc, CHDEventEditSectionDivider];
        
        NSArray *recipientsRows = _newEvent ? @[CHDEventEditRowDivider, CHDEventEditRowParish, CHDEventEditRowGroup, CHDEventEditRowCategories] : @[CHDEventEditRowDivider, CHDEventEditRowGroup, CHDEventEditRowCategories];
        
        self.sectionRows = @{CHDEventEditSectionTitle : @[CHDEventEditRowDivider, CHDEventEditRowTitle],
                             CHDEventEditSectionDate : @[CHDEventEditRowDivider, CHDEventEditRowStartDate, CHDEventEditRowEndDate],
                             CHDEventEditSectionRecipients : recipientsRows,
                             CHDEventEditSectionLocation : @[CHDEventEditRowDivider, CHDEventEditRowLocation],
                             CHDEventEditSectionBooking : @[CHDEventEditRowDivider, CHDEventEditRowResources, CHDEventEditRowUsers],
                             CHDEventEditSectionInternalNote : @[CHDEventEditRowDivider, CHDEventEditRowInternalNote],
                             CHDEventEditSectionDescription : @[CHDEventEditRowDivider, CHDEventEditRowDescription],
                             CHDEventEditSectionMisc : @[CHDEventEditRowDivider, CHDEventEditRowContributor, CHDEventEditRowPrice, CHDEventEditRowDoubleBooking, CHDEventEditRowVisibility],
                             CHDEventEditSectionDivider : @[CHDEventEditRowDivider]};
    }
    return self;
}

- (NSArray*)rowsForSectionAtIndex: (NSInteger) section {
    return self.sectionRows[self.sections[section]];
}

- (RACSignal*) saveEvent {
    return [self.saveCommand execute:RACTuplePack(@(self.newEvent), self.event)];
}

#pragma mark - Lazy Initialization

- (RACCommand *)saveCommand {
    if (!_saveCommand) {
        _saveCommand = [[RACCommand alloc] initWithSignalBlock:^RACSignal *(RACTuple *tuple) {
            BOOL newEvent = [tuple.first boolValue];
            CHDEvent *event = tuple.second;
            if (newEvent) {
                return [[CHDAPIClient sharedInstance] createEventWithDictionary: [event dictionaryRepresentation]];
            }
            else {
                
                return [[CHDAPIClient sharedInstance] updateEventWithId:event.eventId siteId:event.siteId dictionary:[event dictionaryRepresentation]];
            }
        }];
    }
    return _saveCommand;
}

@end
