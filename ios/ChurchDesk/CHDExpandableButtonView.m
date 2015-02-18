//
//  CHDExpandableButtonView.m
//  ChurchDesk
//
//  Created by Mikkel Selsøe Sørensen on 17/02/15.
//  Copyright (c) 2015 Shape A/S. All rights reserved.
//

#import "CHDExpandableButtonView.h"

static const CGFloat k45Degrees = -0.785398163f;
static const CGPoint kDefaultCenterPoint = {34.0f, 27.0f};

@interface CHDExpandableButtonView ()

@property (nonatomic, strong) UIView *buttonContainer;
@property (nonatomic, strong) UIButton *toggleButton;
@property (nonatomic, strong) UIButton *addEventButton;
@property (nonatomic, strong) UIButton *addMessageButton;

@property (nonatomic, strong) MASConstraint *eventCenterConstraint;
@property (nonatomic, strong) MASConstraint *messageCenterConstraint;

@end

@implementation CHDExpandableButtonView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupSubviews];
        [self makeConstraints];
    }
    return self;
}

- (void) setupSubviews {
    [self addSubview:self.buttonContainer];
    [self.buttonContainer addSubview:self.addEventButton];
    [self.buttonContainer addSubview:self.addMessageButton];
    [self addSubview:self.toggleButton];
}

- (void) makeConstraints {
    [self.buttonContainer mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self);
        make.width.equalTo(@153);
        make.height.equalTo(@123);
    }];
    
    NSValue *vCenterPoint = [NSValue valueWithCGPoint:kDefaultCenterPoint];
    
    [self.toggleButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(vCenterPoint);
    }];
    
    [self.addEventButton mas_makeConstraints:^(MASConstraintMaker *make) {
        self.eventCenterConstraint = make.center.equalTo(vCenterPoint);
    }];
    
    [self.addMessageButton mas_makeConstraints:^(MASConstraintMaker *make) {
        self.messageCenterConstraint = make.center.equalTo(vCenterPoint);
    }];
}

#pragma mark - Actions

- (void) toggleButtonAction: (id) sender {
    BOOL toggleOn = CGAffineTransformEqualToTransform(self.buttonContainer.transform, CGAffineTransformIdentity);
    CGAffineTransform transform = toggleOn ? CGAffineTransformMakeRotation(-k45Degrees) : CGAffineTransformIdentity;
    
    CGPoint eventOffset = toggleOn ? CGPointMake(-7, 33) : kDefaultCenterPoint;
    CGPoint messageOffset = toggleOn ? CGPointMake(-7, -41) : kDefaultCenterPoint;
    [self.eventCenterConstraint setCenterOffset:eventOffset];
    [self.messageCenterConstraint setCenterOffset:messageOffset];
    
    [UIView animateWithDuration:toggleOn ? 0.7 : 0.4 delay:0 usingSpringWithDamping:toggleOn ? 0.6 : 0.8 initialSpringVelocity:1.0 options: UIViewAnimationOptionAllowUserInteraction animations:^{
        self.toggleButton.transform = transform;
        self.buttonContainer.transform = transform;
        [self layoutIfNeeded];
    } completion:nil];
}

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
        [_toggleButton setImage:kImgAddActionButton forState:UIControlStateNormal];
        [_toggleButton addTarget:self action:@selector(toggleButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _toggleButton;
}

- (UIButton *)addEventButton {
    if (!_addEventButton) {
        _addEventButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_addEventButton setImage:kImgAddEventButton forState:UIControlStateNormal];
        _addEventButton.transform = CGAffineTransformRotate(CGAffineTransformIdentity, k45Degrees);
    }
    return _addEventButton;
}

- (UIButton *)addMessageButton {
    if (!_addMessageButton) {
        _addMessageButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_addMessageButton setImage:kImgAddMessageButton forState:UIControlStateNormal];
        _addMessageButton.transform = CGAffineTransformRotate(CGAffineTransformIdentity, k45Degrees);
    }
    return _addMessageButton;
}


@end
