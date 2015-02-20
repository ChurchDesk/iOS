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

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {

    // Drawing code
    UIBezierPath *circlePath = [UIBezierPath bezierPathWithOvalInRect:self.bounds];

    self.circle.path = circlePath.CGPath;
    self.circle.fillColor = self.dotColor.CGColor;
}


@end
