//
//  CHDSelectorImageTableViewCell.h
//  ChurchDesk
//
//  Created by Jakob Vinther-Larsen on 27/04/15.
//  Copyright (c) 2015 Shape A/S. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CHDCommonTableViewCell.h"

@interface CHDSelectorImageTableViewCell : CHDCommonTableViewCell

@property (nonatomic, readonly) UIImageView *thumbnailImageView;
@property (nonatomic, readonly) UILabel *nameLabel;
@property (nonatomic, assign) BOOL topLineHidden;
@property (nonatomic, assign) BOOL bottomLineFull;

@end
