//
//  CHDCreatePersonViewModel.m
//  ChurchDesk
//
//  Created by Chirag Sharma on 10/06/16.
//  Copyright © 2016 ChurchDesk ApS. All rights reserved.
//

#import "CHDCreatePersonViewModel.h"

@implementation CHDCreatePersonViewModel

- (instancetype)init {
    RAC(self, canCreatePerson) = [RACSignal combineLatest:@[RACObserve(self, firstName), RACObserve(self, lastName), RACObserve(self, phoneNumber), RACObserve(self, email)]
                                                  reduce:^(NSString *firstName, NSString *lastName, NSString *phoneNumber, NSString *email){
                                                      BOOL validFirstName = !([firstName isEqualToString:@""]);
                                                      BOOL validLastName = !([lastName isEqualToString:@""]);
                                                      BOOL validPhoneNumber = !([phoneNumber isEqualToString:@""]);
                                                      BOOL validEmail = !([email isEqualToString:@""]);
                                                      
                                                      return @(validFirstName || validLastName || validPhoneNumber || validEmail);
                                                  }];
    return self;
}

@end
