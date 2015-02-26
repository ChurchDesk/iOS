//
//  CHDInputAccessoryObserveView.m
//  ChurchDesk
//
//  Created by Jakob Vinther-Larsen on 26/02/15.
//  Copyright (c) 2015 Shape A/S. All rights reserved.
//

#import "CHDInputAccessoryObserveView.h"
NSString * const CHDInputAccessoryViewKeyboardFrameDidChangeNotification = @"CHDInputAccessoryViewKeyboardFrameDidChangeNotification";

@implementation CHDInputAccessoryObserveView

- (void)willMoveToSuperview:(UIView *)newSuperview {
    if(self.superview){
        [self.superview removeObserver:self forKeyPath:@"center"];
    }

    [newSuperview addObserver:self forKeyPath:@"center" options:0 context:nil];

    [super willMoveToSuperview:newSuperview];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if (object == self.superview && [keyPath isEqualToString:@"center"]) {
        //NSLog(@"Keyboard center changed frame %f %f", self.superview.center.x, self.superview.center.y);

        [[NSNotificationCenter defaultCenter] postNotificationName:CHDInputAccessoryViewKeyboardFrameDidChangeNotification
                                                            object:self];
    }
}
@end
