//  Created by Philip Bruce on 26/06/11.
//  Copyright 2011 Shape ApS. All rights reserved.

#import "SHPButton.h"

@interface SHPButton()

@property (nonatomic, strong) UIImage *normalStateImage;
@property (nonatomic, strong) UIColor *normalStateTextColor;
@property (nonatomic, strong) UIColor *normalStateShadowColor;

+ (id)genericWithClassString:(NSString*) classString;
+ (BOOL)hasGeneric;

@end

@implementation SHPButton
@synthesize normalStateImage = _normalStateImage;
@synthesize normalStateTextColor = _normalStateTextColor;
@synthesize normalStateShadowColor = _normalStateShadowColor;

static NSMutableDictionary *dict;

- (id)init {
    self = [super init];
    if (self) {
        [self styleGeneric];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self styleGeneric];
    }
    return self;
}

- (id)initGeneric {
    self = [super init];
    if (self) {

    }
    return self;
}

- (void)awakeFromNib {
    NSString *classString = NSStringFromClass([self class]);
    if ([NSClassFromString(classString) alwaysUseGenericStyle]) {
        [self styleGeneric];
    }
}


- (void)styleGeneric {
    NSString *classString = NSStringFromClass([self class]);
    if ([NSClassFromString(classString) hasGeneric]) {
        [self styleButtonWithButton:[NSClassFromString(classString) generic]];
    }
}

- (void)styleButtonWithButton:(UIButton*)button {
    UIImage *backgroundImage = [button backgroundImageForState:UIControlStateNormal];
    [self setBackgroundImage:backgroundImage forState:UIControlStateNormal];
    UIImage *selectedBackgroundImage = [button backgroundImageForState:UIControlStateSelected];
    [self setBackgroundImage:selectedBackgroundImage forState:UIControlStateSelected];
    UIImage *highlightedBackgroundImage = [button backgroundImageForState:UIControlStateHighlighted];
    [self setBackgroundImage:highlightedBackgroundImage forState:UIControlStateHighlighted];
    UIImage *disabledBackgroundImage = [button backgroundImageForState:UIControlStateDisabled];
    [self setBackgroundImage:disabledBackgroundImage forState:UIControlStateDisabled];
    UIImage *reservedBackgroundImage = [button backgroundImageForState:UIControlStateReserved];
    [self setBackgroundImage:reservedBackgroundImage forState:UIControlStateReserved];
    UIImage *applicationBackgroundImage = [button backgroundImageForState:UIControlStateApplication];
    [self setBackgroundImage:applicationBackgroundImage forState:UIControlStateApplication];
    
    //set the colors
    UIColor *normalColor = [button titleColorForState:UIControlStateNormal];
    [self setTitleColor:normalColor forState:UIControlStateNormal];
    UIColor *selectedColor = [button titleColorForState:UIControlStateSelected];
    [self setTitleColor:selectedColor forState:UIControlStateSelected];
    UIColor *highlightedColor = [button titleColorForState:UIControlStateHighlighted];
    [self setTitleColor:highlightedColor forState:UIControlStateHighlighted];
    UIColor *disabledColor = [button titleColorForState:UIControlStateDisabled];
    [self setTitleColor:disabledColor forState:UIControlStateDisabled];
    UIColor *reservedColor = [button titleColorForState:UIControlStateReserved];
    [self setTitleColor:reservedColor forState:UIControlStateReserved];
    UIColor *applicationColor = [button titleColorForState:UIControlStateApplication];
    [self setTitleColor:applicationColor forState:UIControlStateApplication];
    
    //set the shadow color
    UIColor *normalShadowColor = [button titleShadowColorForState:UIControlStateNormal];
    [self setTitleShadowColor:normalShadowColor forState:UIControlStateNormal];
    UIColor *highlightedShadowColor = [button titleShadowColorForState:UIControlStateHighlighted];
    [self setTitleShadowColor:highlightedShadowColor forState:UIControlStateHighlighted];
    UIColor *selectedShadowColor = [button titleShadowColorForState:UIControlStateSelected];
    [self setTitleShadowColor:selectedShadowColor forState:UIControlStateSelected];
    UIColor *disabledShadowColor = [button titleShadowColorForState:UIControlStateDisabled];
    [self setTitleShadowColor:disabledShadowColor forState:UIControlStateDisabled];
    UIColor *reservedShadowColor = [button titleShadowColorForState:UIControlStateReserved];
    [self setTitleShadowColor:reservedShadowColor forState:UIControlStateReserved];
    UIColor *applicationShadowColor = [button titleShadowColorForState:UIControlStateApplication];
    [self setTitleShadowColor:applicationShadowColor forState:UIControlStateApplication];
    
    //set shadow offset
    CGSize shadowOffset = [[button titleLabel] shadowOffset];
    [[self titleLabel] setShadowOffset:shadowOffset];
    
    //set the font
    UIFont *font = [[button titleLabel] font];
    [[self titleLabel] setFont:font];
    
    //show touch on highlight
    BOOL showTouchOnHighlight = [button showsTouchWhenHighlighted];
    [self setShowsTouchWhenHighlighted:showTouchOnHighlight];
    
    //reverse title shadow when highlighted
    BOOL reversesTitleShadowWhenHighlighted = [button reversesTitleShadowWhenHighlighted];
    [self setReversesTitleShadowWhenHighlighted:reversesTitleShadowWhenHighlighted];
    
    //content mode
    [self setContentMode:[button contentMode]];
    
    //alpha
    [self setAlpha:[button alpha]];
    
    //backgroundcolor
    [self setBackgroundColor:[button backgroundColor]];
    
    //Autoresize
    [self setAutoresizesSubviews:[button autoresizesSubviews]];
    
    //autoresize mask
    [self setAutoresizingMask:[button autoresizingMask]];
    
    //content stretch
    [self setContentStretch:[button contentStretch]];
    
    //enabled
    [self setEnabled:[button isEnabled]];
    
    [self setAdjustsImageWhenDisabled:[button adjustsImageWhenDisabled]];
    
    [self setAdjustsImageWhenHighlighted:[button adjustsImageWhenHighlighted]];
}

- (void)setSelected:(BOOL)selected {
    [super setSelected:selected];
    
    if (!_normalStateImage) {
        [self setNormalStateImage:[self backgroundImageForState:UIControlStateNormal]];
        [self setNormalStateTextColor:[self titleColorForState:UIControlStateNormal]];
        [self setNormalStateShadowColor:[self titleShadowColorForState:UIControlStateNormal]];
    }
    
    if (selected) {
        UIImage *image = [self backgroundImageForState:UIControlStateHighlighted];
        [self setBackgroundImage:image forState:UIControlStateNormal];
        [self setTitleColor:[self titleColorForState:UIControlStateHighlighted] forState:UIControlStateNormal];
        [self setTitleShadowColor:[self titleShadowColorForState:UIControlStateHighlighted] forState:UIControlStateNormal];
    } else {
        UIImage *image = _normalStateImage;
        [self setBackgroundImage:image forState:UIControlStateNormal];
        [self setTitleColor:_normalStateTextColor forState:UIControlStateNormal];
        [self setTitleShadowColor:_normalStateShadowColor forState:UIControlStateNormal];
    }
}

+ (id)generic {
    NSString *classString = NSStringFromClass([self class]);
    return [SHPButton genericWithClassString:classString];
}

+ (id)genericWithClassString:(NSString*) classString {
    if (!dict) {
        dict = [[NSMutableDictionary alloc] init];
    }
    id object = [dict objectForKey:classString];
    
    if (object) {
        return object;
    } else {
        id newObject = [[NSClassFromString(classString) alloc] initGeneric];
        [dict setObject:newObject forKey:classString];
        return newObject;
    }
}

+ (BOOL)hasGeneric{
    if (dict) {
        NSString *classString = NSStringFromClass([self class]);
        if ([dict objectForKey:classString]) {
            return YES;
        }
    }
    
    return NO;
}

+ (BOOL)alwaysUseGenericStyle {
    return NO;
}


@end
