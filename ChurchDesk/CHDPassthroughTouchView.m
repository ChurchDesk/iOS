//
// Created by Jakob Vinther-Larsen on 20/03/15.
// Copyright (c) 2015 Shape A/S. All rights reserved.
//

#import "CHDPassthroughTouchView.h"


@implementation CHDPassthroughTouchView

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event {
    if(self.touchesPassThrough){
       return NO;
    }

    return [super pointInside:point withEvent:event];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    //
}
@end