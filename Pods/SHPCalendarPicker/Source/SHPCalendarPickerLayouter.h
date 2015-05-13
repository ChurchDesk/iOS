//
//  Created by Peter Gammelgaard on 20/10/14.
//  Copyright (c) 2014 SHAPE A/S. All rights reserved.
//

// Examples:
//   [x.isu_layout.center.equal toValue:10]
//   [y.isu_layout.left.right.equal toView:z]
//   [z.isu_layout.top.equal toAttributes:y.isu_bottom
//                                 offset:10]

// Priorities: for-loop over returned constraints manually



#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#pragma mark - Forward declarations

@class SHPCalendarPickerLayouter;

#pragma mark - Interface

@interface SHPCalendarPickerLayoutAttributes : NSObject

#pragma mark - Instance methods

- (instancetype)initWithView:(UIView *)view;

#pragma mark - Attributes

- (SHPCalendarPickerLayoutAttributes *)left;

- (SHPCalendarPickerLayoutAttributes *)right;

- (SHPCalendarPickerLayoutAttributes *)top;

- (SHPCalendarPickerLayoutAttributes *)bottom;

- (SHPCalendarPickerLayoutAttributes *)width;

- (SHPCalendarPickerLayoutAttributes *)height;

- (SHPCalendarPickerLayoutAttributes *)centerX;

- (SHPCalendarPickerLayoutAttributes *)centerY;

- (SHPCalendarPickerLayoutAttributes *)leading;

- (SHPCalendarPickerLayoutAttributes *)trailing;

- (SHPCalendarPickerLayoutAttributes *)baseline;

- (SHPCalendarPickerLayoutAttributes *)edges;

- (SHPCalendarPickerLayoutAttributes *)size;

- (SHPCalendarPickerLayoutAttributes *)center;

#pragma mark - Relations

- (SHPCalendarPickerLayouter *)equal;

- (SHPCalendarPickerLayouter *)lessThanOrEqual;

- (SHPCalendarPickerLayouter *)greaterThanOrEqual;

@end



#pragma mark - Interface

@interface SHPCalendarPickerLayouter : NSObject

#pragma mark - Instance methods

- (instancetype)initWithAttributes:(SHPCalendarPickerLayoutAttributes *)layoutAttributes
                          relation:(NSLayoutRelation)layoutRelation;

#pragma mark - Value

- (NSArray *)toValue:(CGFloat)value;

#pragma mark - View

- (NSArray *)toView:(UIView *)otherView;

- (NSArray *)toView:(UIView *)otherView
             offset:(CGFloat)offset;

- (NSArray *)toView:(UIView *)otherView
       multipliedBy:(CGFloat)multiplier;

- (NSArray *)toView:(UIView *)otherView
       multipliedBy:(CGFloat)multiplier
             offset:(CGFloat)offset;

- (NSArray *)toView:(UIView *)otherView
          dividedBy:(CGFloat)divisor;

- (NSArray *)toView:(UIView *)otherView
          dividedBy:(CGFloat)divisor
             offset:(CGFloat)offset;


#pragma mark - Attributes

- (NSArray *)toAttributes:(SHPCalendarPickerLayoutAttributes *)attributes;

- (NSArray *)toAttributes:(SHPCalendarPickerLayoutAttributes *)attributes
                   offset:(CGFloat)offset;

- (NSArray *)toAttributes:(SHPCalendarPickerLayoutAttributes *)attributes
             multipliedBy:(CGFloat)multiplier;

- (NSArray *)toAttributes:(SHPCalendarPickerLayoutAttributes *)attributes
             multipliedBy:(CGFloat)multiplier
                   offset:(CGFloat)offset;

- (NSArray *)toAttributes:(SHPCalendarPickerLayoutAttributes *)attributes
                dividedBy:(CGFloat)divisor;

- (NSArray *)toAttributes:(SHPCalendarPickerLayoutAttributes *)attributes
                dividedBy:(CGFloat)divisor
                   offset:(CGFloat)offset;

@end
