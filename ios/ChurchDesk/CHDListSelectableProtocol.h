//
//  CHDListSelectableProtocol.h
//  ChurchDesk
//
//  Created by Jakob Vinther-Larsen on 02/03/15.
//  Copyright (c) 2015 Shape A/S. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol CHDListSelectableProtocol <NSObject>
@property (nonatomic) BOOL selected;
@property (nonatomic, assign) UIColor* dotColor;
@property (nonatomic, assign) NSString* title;
@end
