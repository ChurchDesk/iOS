//
//  CHDExpandableButtonView.m
//  ChurchDesk
//
//  Created by Mikkel Selsøe Sørensen on 17/02/15.
//  Copyright (c) 2015 Shape A/S. All rights reserved.
//

#import "CHDExpandableButtonView.h"

static const CGFloat k45Degrees = -0.785398163f;
//static const CGFloat k45Degrees = 0.0f;
static const CGPoint kDefaultCenterPoint = {124.0f, 117.0f};

@interface CHDExpandableButtonView () <UIGestureRecognizerDelegate>

@property (nonatomic, strong) UIView *buttonContainer;
@property (nonatomic, strong) UIButton *toggleButton;
@property (nonatomic, strong) UIButton *addEventButton;
@property (nonatomic, strong) UIButton *addAbsenceButton;
@property (nonatomic, strong) UIButton *addMessageButton;

@property (nonatomic, strong) MASConstraint *eventCenterConstraint;
@property (nonatomic, strong) MASConstraint *messageCenterConstraint;
@property (nonatomic, strong) MASConstraint *absenceCenterConstraint;

@property (nonatomic, assign) BOOL isExpanded;
@property (nonatomic, strong) UIGestureRecognizer *gestureRecognizer;

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

- (void)dealloc
{
    [self.superview removeGestureRecognizer:self.gestureRecognizer];
    self.gestureRecognizer = nil;
}

- (void)didMoveToSuperview
{
    [super didMoveToSuperview];
    
    self.gestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(superViewTapped:)];
    self.gestureRecognizer.delegate = self;
    self.gestureRecognizer.cancelsTouchesInView = YES;
    [self.superview addGestureRecognizer:self.gestureRecognizer];
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    return self.isExpanded;
}

- (void)superViewTapped:(UITapGestureRecognizer*)gest
{
    [self buttonOn:NO];
}

- (void) setupSubviews {
    [self addSubview:self.buttonContainer];
    [self.buttonContainer addSubview:self.addEventButton];
    [self.buttonContainer addSubview:self.addAbsenceButton];
    [self.buttonContainer addSubview:self.addMessageButton];
    [self addSubview:self.toggleButton];
    self.buttonContainer.hidden = true;
}

- (void) makeConstraints {
    [self.buttonContainer mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self);
        make.width.equalTo(@353);
        make.height.equalTo(@323);
    }];
    
    NSValue *vCenterPoint = [NSValue valueWithCGPoint:kDefaultCenterPoint];
    
    [self.toggleButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(vCenterPoint);
    }];
    
    [self.addEventButton mas_makeConstraints:^(MASConstraintMaker *make) {
        self.eventCenterConstraint = make.center.equalTo(vCenterPoint);
    }];
    
    [self.addAbsenceButton mas_makeConstraints:^(MASConstraintMaker *make) {
        self.absenceCenterConstraint = make.center.equalTo(vCenterPoint);
    }];
    
    [self.addMessageButton mas_makeConstraints:^(MASConstraintMaker *make) {
        self.messageCenterConstraint = make.center.equalTo(vCenterPoint);
    }];
}

#pragma mark - Actions

- (void) toggleButtonAction: (id) sender {
    BOOL toggleOn = CGAffineTransformEqualToTransform(self.buttonContainer.transform, CGAffineTransformIdentity);
    [self buttonOn:toggleOn];
}

-(void) buttonOn: (BOOL) on {
    self.isExpanded = on;
    
    CGAffineTransform transform = on ? CGAffineTransformMakeRotation(-k45Degrees) : CGAffineTransformIdentity;
    CGPoint eventOffset = on ? CGPointMake(125, -53) : kDefaultCenterPoint;
    CGPoint messageOffset = on ? CGPointMake(85, -93) : kDefaultCenterPoint;
    CGPoint absenceOffset = on ? CGPointMake(45, -133) : kDefaultCenterPoint;
    if (on) {
        self.buttonContainer.hidden = false;
    }
    [self.eventCenterConstraint setCenterOffset:eventOffset];
    [self.messageCenterConstraint setCenterOffset:messageOffset];
    [self.absenceCenterConstraint setCenterOffset:absenceOffset];
    
    [UIView animateWithDuration:on ? 0.7 : 0.4 delay:0 usingSpringWithDamping:on ? 0.6 : 0.8 initialSpringVelocity:1.0 options: UIViewAnimationOptionAllowUserInteraction animations:^{
        self.toggleButton.transform = transform;
        self.buttonContainer.transform = transform;
        [self layoutIfNeeded];
    } completion:^(BOOL finished) {
        if (!on) {
            self.buttonContainer.hidden = true;
        }
    }];
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
        [_toggleButton setImage:kImgCreatePassive forState:UIControlStateNormal];
        [_toggleButton setImage:kImgCreateActive forState:UIControlStateSelected];
        [_toggleButton addTarget:self action:@selector(toggleButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        [_toggleButton shprac_liftSelector:@selector(setSelected:) withSignal:RACObserve(self, isExpanded)];
    }
    return _toggleButton;
}

- (UIButton *)addEventButton {
    if (!_addEventButton) {
        _addEventButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_addEventButton setImage:kImgCreateEvent forState:UIControlStateNormal];
        _addEventButton.transform = CGAffineTransformRotate(CGAffineTransformIdentity, k45Degrees);
        [_addEventButton addTarget:self action:@selector(toggleButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _addEventButton;
}

- (UIButton *)addAbsenceButton {
    if (!_addAbsenceButton) {
        _addAbsenceButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_addAbsenceButton setImage:kImgCreateAbsence forState:UIControlStateNormal];
        _addAbsenceButton.transform = CGAffineTransformRotate(CGAffineTransformIdentity, k45Degrees);
        [_addAbsenceButton addTarget:self action:@selector(toggleButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _addAbsenceButton;
}

- (UIButton *)addMessageButton {
    if (!_addMessageButton) {
        _addMessageButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_addMessageButton setImage:kImgCreateMessage forState:UIControlStateNormal];
        _addMessageButton.transform = CGAffineTransformRotate(CGAffineTransformIdentity, k45Degrees);
        [_addMessageButton addTarget:self action:@selector(toggleButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _addMessageButton;
}

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event {
    // UIView will be "transparent" for touch events if we return NO
    return (!self.buttonContainer.hidden || CGRectContainsPoint(self.toggleButton.frame, point));
}
@end
