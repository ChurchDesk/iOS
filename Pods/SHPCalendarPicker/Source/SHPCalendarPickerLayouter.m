//
//  Created by Peter Gammelgaard on 20/10/14.
//  Copyright (c) 2014 SHAPE A/S. All rights reserved.
//

#pragma mark - Imports

#import "SHPCalendarPickerLayouter.h"


#pragma mark - Extension

@interface SHPCalendarPickerLayoutAttributes ()

@property (nonatomic, strong) UIView *view;

@property (nonatomic, strong) NSMutableArray *attributes;

@end


#pragma mark - Implementation

@implementation SHPCalendarPickerLayoutAttributes

- (instancetype)initWithView:(UIView *)view
{
    self = [super init];
    if (self) {
        self.view = view;
        self.attributes = [NSMutableArray array];
    }
    return self;
}

#pragma mark - Attributes

- (void)addAttribute:(NSLayoutAttribute)attribute
{
    NSNumber *value = @(attribute);
    if (self.attributes) {
        [self.attributes addObject:value];
    } else {
        self.attributes = [NSMutableArray arrayWithObject:value];
    }
}

- (SHPCalendarPickerLayoutAttributes *)left
{
    [self addAttribute:NSLayoutAttributeLeft];
    return self;
}

- (SHPCalendarPickerLayoutAttributes *)right
{
    [self addAttribute:NSLayoutAttributeRight];
    return self;
}

- (SHPCalendarPickerLayoutAttributes *)top
{
    [self addAttribute:NSLayoutAttributeTop];
    return self;
}

- (SHPCalendarPickerLayoutAttributes *)bottom
{
    [self addAttribute:NSLayoutAttributeBottom];
    return self;
}

- (SHPCalendarPickerLayoutAttributes *)width
{
    [self addAttribute:NSLayoutAttributeWidth];
    return self;
}

- (SHPCalendarPickerLayoutAttributes *)height
{
    [self addAttribute:NSLayoutAttributeHeight];
    return self;
}

- (SHPCalendarPickerLayoutAttributes *)centerX
{
    [self addAttribute:NSLayoutAttributeCenterX];
    return self;
}

- (SHPCalendarPickerLayoutAttributes *)centerY
{
    [self addAttribute:NSLayoutAttributeCenterY];
    return self;
}

- (SHPCalendarPickerLayoutAttributes *)leading
{
    [self addAttribute:NSLayoutAttributeLeading];
    return self;
}

- (SHPCalendarPickerLayoutAttributes *)trailing
{
    [self addAttribute:NSLayoutAttributeTrailing];
    return self;
}

- (SHPCalendarPickerLayoutAttributes *)baseline
{
    [self addAttribute:NSLayoutAttributeBaseline];
    return self;
}

- (SHPCalendarPickerLayoutAttributes *)edges
{
    return self.left.right.top.bottom;
}

- (SHPCalendarPickerLayoutAttributes *)size
{
    return self.width.height;
}

- (SHPCalendarPickerLayoutAttributes *)center
{
    return self.centerX.centerY;
}

#pragma mark - Relations

- (SHPCalendarPickerLayouter *)newLayouterWithRelation:(NSLayoutRelation)relation
{
    return [[SHPCalendarPickerLayouter alloc] initWithAttributes:self
                                          relation:relation];
}

- (SHPCalendarPickerLayouter *)equal
{
    return [self newLayouterWithRelation:NSLayoutRelationEqual];
}

- (SHPCalendarPickerLayouter *)lessThanOrEqual
{
    return [self newLayouterWithRelation:NSLayoutRelationLessThanOrEqual];
}

- (SHPCalendarPickerLayouter *)greaterThanOrEqual
{
    return [self newLayouterWithRelation:NSLayoutRelationGreaterThanOrEqual];
}

@end





#pragma mark - Extension

@interface SHPCalendarPickerLayouter ()

@property (nonatomic, strong) SHPCalendarPickerLayoutAttributes *layoutAttributes;

@property (nonatomic, assign) NSLayoutRelation layoutRelation;

@end


#pragma mark - Implementation

@implementation SHPCalendarPickerLayouter

#pragma mark - Class methods

+ (UIView *)closestCommonSuperviewOfView:(UIView *)selfView
                               otherView:(UIView *)otherView
{
    UIView *closestCommonSuperview = nil;

    UIView *secondViewSuperview = otherView;
    while (!closestCommonSuperview && secondViewSuperview) {
        UIView *firstViewSuperview = selfView;
        while (!closestCommonSuperview && firstViewSuperview) {
            if (secondViewSuperview == firstViewSuperview) {
                closestCommonSuperview = secondViewSuperview;
            }
            firstViewSuperview = firstViewSuperview.superview;
        }
        secondViewSuperview = secondViewSuperview.superview;
    }
    return closestCommonSuperview;
}

#pragma mark - Instance methods

- (instancetype)initWithAttributes:(SHPCalendarPickerLayoutAttributes *)layoutAttributes
                          relation:(NSLayoutRelation)layoutRelation
{
    self = [super init];
    if (self) {
        self.layoutAttributes = layoutAttributes;
        self.layoutRelation = layoutRelation;
    }
    return self;
}


#pragma mark - Value

- (NSArray *)toValue:(CGFloat)value
{
    return [self addConstraintsToOtherView:nil
                            otherAttribute:@(NSLayoutAttributeNotAnAttribute)
                                multiplier:1.f
                                  constant:value];
}

#pragma mark - View

- (NSArray *)toView:(UIView *)otherView
{
    return [self toView:otherView
             multiplier:1.f
               constant:0.f];
}

- (NSArray *)toView:(UIView *)otherView
             offset:(CGFloat)offset
{
    return [self toView:otherView
             multiplier:1.f
               constant:offset];
}

- (NSArray *)toView:(UIView *)otherView
       multipliedBy:(CGFloat)multiplier
{
    return [self toView:otherView
             multiplier:multiplier
               constant:0.f];
}

- (NSArray *)toView:(UIView *)otherView
       multipliedBy:(CGFloat)multiplier
             offset:(CGFloat)offset
{
    return [self toView:otherView
             multiplier:multiplier
               constant:offset];
}

- (NSArray *)toView:(UIView *)otherView
          dividedBy:(CGFloat)divisor
{
    return [self toView:otherView
             multiplier:(1.f / divisor)
               constant:0.f];
}

- (NSArray *)toView:(UIView *)otherView
          dividedBy:(CGFloat)divisor
             offset:(CGFloat)offset
{
    return [self toView:otherView
             multiplier:(1.f / divisor)
               constant:offset];
}

- (NSArray *)toView:(UIView *)otherView
         multiplier:(CGFloat)multiplier
           constant:(CGFloat)constant
{
    return [self addConstraintsToOtherView:otherView
                            otherAttribute:nil
                                multiplier:multiplier
                                  constant:constant];
}


#pragma mark - Attributes

- (NSArray *)toAttributes:(SHPCalendarPickerLayoutAttributes *)attributes
{
    return [self toAttributes:attributes
                   multiplier:1.f
                     constant:0.f];
}

- (NSArray *)toAttributes:(SHPCalendarPickerLayoutAttributes *)attributes
                   offset:(CGFloat)offset
{
    return [self toAttributes:attributes
                   multiplier:1.f
                     constant:offset];
}

- (NSArray *)toAttributes:(SHPCalendarPickerLayoutAttributes *)attributes
             multipliedBy:(CGFloat)multiplier
{
    return [self toAttributes:attributes
                   multiplier:multiplier
                     constant:0.f];
}

- (NSArray *)toAttributes:(SHPCalendarPickerLayoutAttributes *)attributes
                dividedBy:(CGFloat)divisor
{
    return [self toAttributes:attributes
                   multiplier:(1.f / divisor)
                     constant:0.f];
}

- (NSArray *)toAttributes:(SHPCalendarPickerLayoutAttributes *)attributes
             multipliedBy:(CGFloat)multiplier
                   offset:(CGFloat)offset
{
    return [self toAttributes:attributes
                   multiplier:multiplier
                     constant:offset];
}

- (NSArray *)toAttributes:(SHPCalendarPickerLayoutAttributes *)attributes
                dividedBy:(CGFloat)divisor
                   offset:(CGFloat)offset
{
    return [self toAttributes:attributes
                   multiplier:(1.f / divisor)
                     constant:offset];
}

- (NSArray *)toAttributes:(SHPCalendarPickerLayoutAttributes *)attributes
               multiplier:(CGFloat)multiplier
                 constant:(CGFloat)constant
{
    NSMutableArray *allConstraints = [NSMutableArray array];

    for (NSNumber *attributeValue in attributes.attributes) {
        NSArray *constraints =
            [self addConstraintsToOtherView:attributes.view
                             otherAttribute:attributeValue
                                 multiplier:multiplier
                                   constant:constant];
        [allConstraints addObjectsFromArray:constraints];
    }
    return allConstraints;
}

#pragma mark - Installation


- (NSArray *)addConstraintsToOtherView:(UIView *)otherView
                        otherAttribute:(NSNumber *)otherAttributeValue
                            multiplier:(CGFloat)multiplier
                              constant:(CGFloat)constant
{
    UIView *view = self.layoutAttributes.view;

    NSMutableArray *constraints = [NSMutableArray array];
    
    for (NSNumber *attributeValue in self.layoutAttributes.attributes) {
        NSLayoutAttribute attribute = [attributeValue integerValue];
        NSLayoutAttribute otherAttribute = (otherAttributeValue
                                            ? [otherAttributeValue integerValue]
                                            : attribute);
        NSLayoutConstraint *constraint =
            [NSLayoutConstraint constraintWithItem:view
                                         attribute:attribute
                                         relatedBy:self.layoutRelation
                                            toItem:otherView
                                         attribute:otherAttribute
                                        multiplier:multiplier
                                          constant:constant];
        [constraints addObject:constraint];
    }

    UIView *targetView = view;
    if (otherView) {
        targetView = [self.class closestCommonSuperviewOfView:view
                                                    otherView:otherView];
        NSAssert(targetView,
                 @"common superview for %@ and %@ required", view, otherView);
    }
    view.translatesAutoresizingMaskIntoConstraints = NO;
    [targetView addConstraints:constraints];
    return constraints;
}

@end
