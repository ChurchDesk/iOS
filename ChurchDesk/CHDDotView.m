//
//  CHDDotView.m
//  ChurchDesk
//
//  Created by Jakob Vinther-Larsen on 19/02/15.
//  Copyright (c) 2015 Shape A/S. All rights reserved.
//

#import "CHDDotView.h"
@interface CHDDotView()
@property(nonatomic, strong) CAShapeLayer *circle;
@end

@implementation CHDDotView

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.dotColor = [UIColor chd_categoryBlueColor];
        self.opaque = NO;
        [self makeLayers];
        
        [self rac_liftSelector:@selector(colorDot:bounds:) withSignals:RACObserve(self, dotColor), RACObserve(self, bounds), nil];
    }
    return self;
}

-(void) makeLayers {
    [self.layer addSublayer:self.circle];
}

-(CAShapeLayer*)circle {
    if(!_circle){
        _circle = [CAShapeLayer new];
    }
    //_circle.fillColor = self.dotColor.CGColor;
    return _circle;
}

- (void)colorDot: (UIColor*) color bounds: (CGRect) bounds {
        UIColor *dotColor = color ?: [UIColor clearColor];
    
    // Drawing code
    UIBezierPath *circlePath = [UIBezierPath bezierPathWithOvalInRect:bounds];

    self.circle.path = circlePath.CGPath;
    self.circle.fillColor = dotColor.CGColor;
}


@end
