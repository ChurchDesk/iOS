//
//  CHDCommonTableViewCell.h
//  ChurchDesk
//
//  Created by Mikkel Selsøe Sørensen on 26/02/15.
//  Copyright (c) 2015 Shape A/S. All rights reserved.
//

#import <UIKit/UIKit.h>

extern CGFloat const kSideMargin;
extern CGFloat const kIndentedRightMargin;

@interface CHDCommonTableViewCell : UITableViewCell

@property (nonatomic, assign) BOOL dividerLineHidden;
@property (nonatomic, assign) BOOL disclosureArrowHidden;

@end
