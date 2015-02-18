//
//  CHDExpandableButtonView.m
//  ChurchDesk
//
//  Created by Mikkel Selsøe Sørensen on 17/02/15.
//  Copyright (c) 2015 Shape A/S. All rights reserved.
//

#import "CHDExpandableButtonView.h"
#import "POP.h"

@interface CHDExpandableButtonView ()

@property (nonatomic, strong) UIView *buttonContainer;
@property (nonatomic, strong) UIButton *toggleButton;
@property (nonatomic, strong) UIButton *addEventButton;
@property (nonatomic, strong) UIButton *addMessageButton;

@end

@implementation CHDExpandableButtonView

#pragma mark - Lazy Initialization

- (UIView *)buttonContainer {
    if (!_buttonContainer) {
        _buttonContainer = [UIView new];
    }
    return _buttonContainer;
}

- (UIButton *)toggleButton {
    if (!_toggleButton) {
        _toggleButton = [UIButton buttonWithType:UIButtonTypeCustom];
//        [_toggleButton setImage:kimg forState:<#(UIControlState)#>]
    }
    return _toggleButton;
}

@end
