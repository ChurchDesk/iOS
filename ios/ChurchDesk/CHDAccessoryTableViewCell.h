//
//  CHDAccessoryTableViewCell.h
//  ChurchDesk
//
//  Created by Jakob Vinther-Larsen on 23/02/15.
//  Copyright (c) 2015 Shape A/S. All rights reserved.
//

#import "CHDTableViewCell.h"

@interface CHDAccessoryTableViewCell : CHDTableViewCell <UIScrollViewDelegate, UIGestureRecognizerDelegate>
/**
* Instead of adding content to self.contentView
* Use the scrollContentView
*/
@property (nonatomic, readonly) UIView *scrollContentView;
@property (nonatomic, readonly) NSMutableArray *accessoryButtons;
@property (nonatomic) BOOL accessoryEnabled;
-(void) setAccessoryWithTitles: (NSArray*) buttonTitles backgroundColors: (NSArray*) buttonColors buttonWidth:(CGFloat) btnWidth;
-(void) closeAccessoryAnimated: (BOOL) animated;
-(void) openAccessoryAnimated: (BOOL) animated;
@end
