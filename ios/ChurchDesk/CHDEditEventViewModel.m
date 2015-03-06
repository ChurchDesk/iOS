//
//  CHDEditEventViewModel.m
//  ChurchDesk
//
//  Created by Mikkel Selsøe Sørensen on 06/03/15.
//  Copyright (c) 2015 Shape A/S. All rights reserved.
//

#import "CHDEditEventViewModel.h"
#import "CHDEvent.h"

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
NSString *const CHDEventEditRowVisibility = @"CHDEventEditRowVisibility";

NSString *const CHDEventEditRowDivider = @"CHDEventEditRowDivider";

@interface CHDEditEventViewModel ()

@property (nonatomic, strong) NSArray *sections;
@property (nonatomic, strong) NSDictionary *sectionRows;

@end

@implementation CHDEditEventViewModel

- (instancetype)initWithEvent: (CHDEvent*) event {
    self = [super init];
    if (self) {
        _event = event;
        
        self.sections = @[CHDEventEditSectionTitle, CHDEventEditSectionDate, CHDEventEditSectionRecipients, CHDEventEditSectionLocation, CHDEventEditSectionBooking, CHDEventEditSectionInternalNote, CHDEventEditSectionDescription, CHDEventEditSectionMisc];
        self.sectionRows = @{CHDEventEditSectionTitle : @[CHDEventEditRowDivider, CHDEventEditRowTitle],
                             CHDEventEditSectionDate : @[CHDEventEditRowDivider, CHDEventEditRowStartDate, CHDEventEditRowEndDate],
                             CHDEventEditSectionRecipients : @[CHDEventEditRowDivider, CHDEventEditRowParish, CHDEventEditRowGroup, CHDEventEditRowCategories],
                             CHDEventEditSectionLocation : @[CHDEventEditRowDivider, CHDEventEditRowLocation],
                             CHDEventEditSectionBooking : @[CHDEventEditRowDivider, CHDEventEditRowResources, CHDEventEditRowUsers],
                             CHDEventEditSectionInternalNote : @[CHDEventEditRowDivider, CHDEventEditRowInternalNote],
                             CHDEventEditSectionDescription : @[CHDEventEditRowDivider, CHDEventEditRowDescription],
                             CHDEventEditSectionMisc : @[CHDEventEditRowDivider, CHDEventEditRowContributor, CHDEventEditRowPrice, CHDEventEditRowVisibility]};
    }
    return self;
}

- (NSArray*)rowsForSectionAtIndex: (NSInteger) section {
    return self.sectionRows[self.sections[section]];
}

@end
