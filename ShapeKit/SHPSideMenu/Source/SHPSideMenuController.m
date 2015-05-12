//
//  Created by Peter Gammelgaard on 15/04/14.
//  Copyright (c) 2013 SHAPE A/S. All rights reserved.
//

#import "SHPSideMenuController.h"
#import <objc/runtime.h>
#import <pop/POPSpringAnimation.h>

#define SHPSideMenuControllerLeftOpenWidthDefault 270.0f
#define SHPSideMenuControllerLeftOpenAnimationSpringSpeedDefault 8.f
#define SHPSideMenuControllerLeftOpenSpringBouncinessDefault 1.0f
#define SHPSideMenuControllerLeftOpenSpringVelocityDefault 10.0f

#define SHPSideMenuControllerLeftCloseAnimationSpringSpeedDefault 10.f
#define SHPSideMenuControllerLeftCloseSpringBouncinessDefault 1.0f
#define SHPSideMenuControllerLeftCloseSpringVelocityDefault 10.0f

#define SHPSideMenuControllerLeftParallaxAnimationDurationDefault 0.45f
#define SHPSideMenuControllerLeftParallaxFactorDefault 0.35f
#define SHPSideMenuControllerStatusBarBehaviourDefault SHPSideMenuStatusBarBehaviourNormal;
#define SHPSideMenuControllerPanningBehaviourDefault SHPSideMenuPanningBehaviourFullView;

@implementation UIViewController (SHPSideMenuController)

- (void)setShp_sideMenuController:(SHPSideMenuController *)sideMenuController {
    objc_setAssociatedObject(self, @selector(shp_sideMenuController), sideMenuController, OBJC_ASSOCIATION_ASSIGN);
}

- (SHPSideMenuController *)shp_sideMenuController {
    return objc_getAssociatedObject(self, @selector(shp_sideMenuController));
}

@end

typedef NS_ENUM(NSInteger, SHPSideMenuInteractionState) {
    SHPSideMenuInteractionStateIdle,
    SHPSideMenuInteractionStatePanning,
};

@implementation SHPSideMenuControllerBuilder

- (id)init {
    self = [super init];
    if (self) {
        _leftOpenWidth = SHPSideMenuControllerLeftOpenWidthDefault;
        _leftOpenAnimationSpringSpeed = SHPSideMenuControllerLeftOpenAnimationSpringSpeedDefault;
        _leftOpenSpringBounciness = SHPSideMenuControllerLeftOpenSpringBouncinessDefault;
        _leftOpenSpringVelocity = SHPSideMenuControllerLeftOpenSpringVelocityDefault;
        _leftCloseAnimationSpringSpeed = SHPSideMenuControllerLeftCloseAnimationSpringSpeedDefault;
        _leftCloseSpringBounciness = SHPSideMenuControllerLeftCloseSpringBouncinessDefault;
        _leftCloseSpringVelocity = SHPSideMenuControllerLeftCloseSpringVelocityDefault;
        _leftParallaxAnimationDuration = SHPSideMenuControllerLeftParallaxAnimationDurationDefault;
        _leftParallaxFactor = SHPSideMenuControllerLeftParallaxFactorDefault;
        _statusBarBehaviour = SHPSideMenuControllerStatusBarBehaviourDefault;
        _panningBehaviour = SHPSideMenuControllerPanningBehaviourDefault;
    }

    return self;
}

@end

@interface SHPSideMenuController () <UIGestureRecognizerDelegate>
@property (nonatomic) const CGPoint panPreviousLocation;
@property (nonatomic)  SHPSideMenuPanIntention panIntention;
@property (nonatomic) SHPSideMenuInteractionState interactionState;
@property(nonatomic, copy) void (^completion)();
@end

@implementation SHPSideMenuController {
    UITapGestureRecognizer *_tapGesture;
}

#pragma mark - Lifecycle

- (id)init {
    return [[SHPSideMenuController alloc] initWithCompletion:nil];
}

- (id)initWithCompletion:(void (^)())completion {
    self = [super init];
    if (self) {
        self.completion = completion;
        _interactionState = SHPSideMenuInteractionStateIdle;

        //StatusBar height change
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(statusBarFrameWillChange:) name:UIApplicationWillChangeStatusBarFrameNotification object:nil];
    }

    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillChangeStatusBarFrameNotification object:nil];
    [self removeObserver:self forKeyPath:@"selectedViewController.view.frame"];
}

+ (instancetype)sideMenuControllerWithBuilder:(void (^)(SHPSideMenuControllerBuilder *builder))builderBlock {
    return [SHPSideMenuController sideMenuControllerWithBuilder:builderBlock completion:nil];
}

+ (SHPSideMenuController *)sideMenuControllerWithBuilder:(void (^)(SHPSideMenuControllerBuilder *))builderBlock completion:(void (^)())completion {
    NSParameterAssert(builderBlock);

    SHPSideMenuController *sideMenuController = [[self alloc] initWithCompletion:completion];
    SHPSideMenuControllerBuilder *builder = [SHPSideMenuControllerBuilder new];
    builderBlock(builder);
    [sideMenuController setupWithBuilder:builder];

    return sideMenuController;
}

- (void)setupWithBuilder:(SHPSideMenuControllerBuilder *)builder {
    _leftOpenWidth = builder.leftOpenWidth;
    _leftOpenSpringBounciness = builder.leftOpenSpringBounciness;
    _leftOpenSpringVelocity = builder.leftOpenSpringVelocity;
    _leftOpenAnimationSpringSpeed = builder.leftOpenAnimationSpringSpeed;
    _leftCloseAnimationSpringSpeed = builder.leftCloseAnimationSpringSpeed;
    _leftCloseSpringBounciness = builder.leftCloseSpringBounciness;
    _leftCloseSpringVelocity = builder.leftCloseSpringVelocity;
    _leftParallaxAnimationDuration = builder.leftParallaxAnimationDuration;
    _statusBarBehaviour = builder.statusBarBehaviour;
    _leftParallaxFactor = builder.leftParallaxFactor;
    _panningBehaviour = builder.panningBehaviour;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanGesture:)];
    panGesture.delegate = self;
    [self.view addGestureRecognizer:panGesture];

    _tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapGesture:)];
    _tapGesture.delegate = self;
    [self.view addGestureRecognizer:_tapGesture];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

    if (self.completion) {
        self.completion();
        self.completion = nil;
    }
}

#pragma mark - Public Setters

- (void)setSelectedViewController:(UIViewController *)selectedViewController {
    [self setSelectedViewController:selectedViewController closeMenu:NO];
}

- (void)setSelectedViewController:(UIViewController *)selectedViewController closeMenu:(BOOL)close {
    if(_interactionState == SHPSideMenuInteractionStatePanning) { return; }

    if(_selectedViewController != selectedViewController) {
        if(_selectedViewController) {
            [self removeObserver:self forKeyPath:@"selectedViewController.view.frame"];
            [_selectedViewController willMoveToParentViewController:nil];
            [_selectedViewController.view removeFromSuperview];
        }
        [self setupViewController:selectedViewController];

        [self addChildViewController:selectedViewController];

        CGFloat offsetX = self.currentSide == SHPSideMenuSideLeft ? self.leftOpenWidth : 0;
        selectedViewController.view.frame = CGRectMake(offsetX, 0, self.view.bounds.size.width, self.view.bounds.size.height);

        [self.view addSubview:selectedViewController.view];
        [self.view bringSubviewToFront:selectedViewController.view];

        [selectedViewController didMoveToParentViewController:self];

        [self willChangeValueForKey:@"selectedViewController"];
        _selectedViewController = selectedViewController;
        [self didChangeValueForKey:@"selectedViewController"];

        [self addObserver:self forKeyPath:@"selectedViewController.view.frame" options:NSKeyValueObservingOptionOld context:NULL];
    }

    if(close && self.currentSide != SHPSideMenuSideCenter) {
        [self close];
    } else if ([self currentSide] == SHPSideMenuSideCenter) {
        self.selectedViewController.view.userInteractionEnabled = YES;
    }
}

- (void)setLeftViewController:(UIViewController *)leftViewController {
    if(_leftViewController != leftViewController) {
        if(_leftViewController) {
            [_leftViewController willMoveToParentViewController:nil];
            [_leftViewController.view removeFromSuperview];
            [_leftViewController removeFromParentViewController];
        }

        _leftViewController = leftViewController;

        [self setupViewController:leftViewController];
        [self addChildViewController:leftViewController];
        CGFloat statusBarOffsetMax = MAX([[UIApplication sharedApplication] statusBarFrame].size.height-20, 0);

        CGFloat width =  self.view.bounds.size.width;
        if(_statusBarBehaviour == SHPSideMenuStatusBarBehaviourMove) {
            leftViewController.view.frame = CGRectMake(0, -statusBarOffsetMax, width - (width - SHPSideMenuControllerLeftOpenWidthDefault), self.view.bounds.size.height+statusBarOffsetMax);
        }else {
            leftViewController.view.frame = CGRectMake(0, leftViewController.view.frame.origin.y, width - (width - SHPSideMenuControllerLeftOpenWidthDefault), self.view.bounds.size.height-statusBarOffsetMax*2);
        }

        [self.view addSubview:leftViewController.view];
        [self.view bringSubviewToFront:_selectedViewController.view];

        [leftViewController didMoveToParentViewController:self];
    }
}

- (void)setupViewController:(UIViewController *)viewController {
    if(viewController) {
        if([viewController isKindOfClass:[UINavigationController class]]) {
            UINavigationController *navigationController = (UINavigationController *) viewController;
            UIViewController *vc = [navigationController.viewControllers firstObject];
            vc.shp_sideMenuController = self;
        }else {
            viewController.shp_sideMenuController = self;
        }
    }
}

#pragma mark - Animations

- (void)animateCenterControllerPosition:(CGPoint)position springSpeed:(CGFloat)springSpeed springBounciness:(CGFloat)springBounciness springVelocity:(CGFloat)springVelocity completion:(void(^)(void))completion {
    self.interactionState = SHPSideMenuInteractionStatePanning;

    CGRect rect = self.selectedViewController.view.frame;
    rect.origin = position;

    POPSpringAnimation *selectedViewControllerSpringAnimation = [POPSpringAnimation animationWithPropertyNamed:kPOPViewFrame];
    selectedViewControllerSpringAnimation.toValue = [NSValue valueWithCGRect:rect];
    selectedViewControllerSpringAnimation.velocity = [NSValue valueWithCGRect:CGRectMake(springVelocity, 0, 0, 0)];
    selectedViewControllerSpringAnimation.springBounciness = springBounciness;
    selectedViewControllerSpringAnimation.springSpeed = springSpeed;
    [selectedViewControllerSpringAnimation setCompletionBlock:^(POPAnimation *anim, BOOL finished) {
        if (finished && completion) {
            self.interactionState = SHPSideMenuInteractionStateIdle;
            completion();
        }
    }];
    [self.selectedViewController.view pop_addAnimation:selectedViewControllerSpringAnimation forKey:@"SHPSideMenuControllerAnimation"];

    if(_statusBarBehaviour == SHPSideMenuStatusBarBehaviourMove) {
        UIView *statusBar = [self statusBar];
        CGRect statusBarFrame = [statusBar frame];
        CGRect newStatusBarFrame = CGRectMake(position.x, statusBarFrame.origin.y, statusBar.frame.size.width, statusBar.frame.size.height);
        POPSpringAnimation *statusBarSpringAnimation = [POPSpringAnimation animationWithPropertyNamed:kPOPViewFrame];
        statusBarSpringAnimation.toValue = [NSValue valueWithCGRect:newStatusBarFrame];
        statusBarSpringAnimation.velocity = [NSValue valueWithCGRect:CGRectMake(springVelocity, 0, 0, 0)];
        statusBarSpringAnimation.springBounciness = springBounciness;
        statusBarSpringAnimation.springSpeed = springSpeed;
        [statusBarSpringAnimation setCompletionBlock:^(POPAnimation *anim, BOOL finished) {
            if (finished && completion) {
                self.interactionState = SHPSideMenuInteractionStateIdle;
                completion();
            }
        }];
        [statusBar pop_addAnimation:statusBarSpringAnimation forKey:@"SHPSideMenuControllerAnimation"];
    }
}

#pragma mark - Gestures

- (void)handleTapGesture:(UIGestureRecognizer *)handleTapGesture {
    if (handleTapGesture.state == UIGestureRecognizerStateEnded) {
        if(self.currentSide == SHPSideMenuSideLeft) {
            [self close];
        }
    }
}

- (void)handlePanGesture:(UIGestureRecognizer *)gestureRecognizer {
    CGPoint location = [gestureRecognizer locationInView:self.view];
    switch (gestureRecognizer.state) {
        case UIGestureRecognizerStateBegan:
            [self handlePanBeganGesture:gestureRecognizer];
            self.panPreviousLocation = location;
            break;
        case UIGestureRecognizerStateChanged:
            [self handlePanChangedGesture:gestureRecognizer];
            self.panPreviousLocation = location;
            break;
        case UIGestureRecognizerStateEnded:
        case UIGestureRecognizerStateCancelled:
        case UIGestureRecognizerStateFailed:
            [self handlePanEndedGesture:gestureRecognizer];
            self.panPreviousLocation = CGPointZero;
            self.panIntention = SHPSideMenuPanIntentionUnknown;
            break;
        default:break;
    }
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    if(gestureRecognizer == _tapGesture && _currentSide == SHPSideMenuSideCenter) return NO;

    if ([gestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]]) {
        if (self.panningBehaviour == SHPSideMenuPanningBehaviourOff) {
            return NO;
        }
        UIPanGestureRecognizer *panGestureRecognizer = (UIPanGestureRecognizer *) gestureRecognizer;
        CGPoint velocity = [panGestureRecognizer velocityInView:self.selectedViewController.view];
        if (fabs(velocity.x) < fabs(velocity.y)) {
            return NO;
        }
    }

    CGPoint location = [gestureRecognizer locationInView:self.view];
    BOOL isCenterNavigationController = [_selectedViewController isKindOfClass:[UINavigationController class]];

    if(self.currentSide == SHPSideMenuSideLeft) {
        return location.x>self.leftOpenWidth;
    }else {
        if(isCenterNavigationController) {
            UINavigationController *navigationController = (UINavigationController *) self.selectedViewController;
            BOOL isRootViewController = navigationController.viewControllers.count <= 1;
            if(self.panningBehaviour == SHPSideMenuPanningBehaviourFullView && isRootViewController) {
                return YES;
            } else {
                CGFloat statusBarHeight = [[UIApplication sharedApplication] statusBarFrame].size.height;
                CGFloat navigationBarHeight = navigationController.navigationBar.frame.size.height;
                BOOL isOnNavigationBar = location.y < navigationBarHeight+statusBarHeight;

                return isOnNavigationBar;
            }
        }else {
            return YES;
        }
    }
}

#pragma mark - Handle Gestures

- (void)handlePanBeganGesture:(__unused UIGestureRecognizer *)gestureRecognizer {
    self.interactionState = SHPSideMenuInteractionStatePanning;

    if(self.currentSide == SHPSideMenuSideLeft) {
        if ([self.delegate respondsToSelector:@selector(sideMenuControllerWillOpenSideMenu:)]) {
            [self.delegate sideMenuControllerWillOpenSideMenu:self];
        }
    }else if (self.currentSide == SHPSideMenuSideCenter) {
        if ([self.delegate respondsToSelector:@selector(sideMenuControllerWillCloseSideMenu:)]) {
            [self.delegate sideMenuControllerWillCloseSideMenu:self];
        }
    }
}

- (void)handlePanChangedGesture:(UIGestureRecognizer *)gestureRecognizer {
    CGPoint location = [gestureRecognizer locationInView:self.view];

    CGPoint diffLocation = CGPointZero;
    diffLocation.x = location.x - self.panPreviousLocation.x;
    diffLocation.y = location.y - self.panPreviousLocation.y;

    CGRect rect = self.selectedViewController.view.frame;
    CGFloat newX = rect.origin.x + diffLocation.x;
    newX = MAX(0.0f, MIN(newX, SHPSideMenuControllerLeftOpenWidthDefault));
    rect.origin.x = newX;
    self.selectedViewController.view.frame = rect;

    self.panIntention = (diffLocation.x > 0) ? SHPSideMenuPanIntentionOpening : SHPSideMenuPanIntentionClosing;

    CGFloat percentage = newX / self.leftOpenWidth;
    CGRect leftRect = self.leftViewController.view.frame;
    leftRect.origin.x = -(self.leftOpenWidth * self.leftParallaxFactor) + (self.leftOpenWidth * self.leftParallaxFactor) * percentage;
    self.leftViewController.view.frame = leftRect;

    //StatusBar
    if(_statusBarBehaviour == SHPSideMenuStatusBarBehaviourMove) {
        UIView *statusBar = [self statusBar];
        CGRect statusBarFrame = [statusBar frame];
        statusBar.frame = CGRectMake(newX, statusBarFrame.origin.y, statusBar.frame.size.width, statusBar.frame.size.height);
    }
}

- (void)handlePanEndedGesture:(__unused UIGestureRecognizer *)recognizer {
    switch (self.panIntention) {
        case SHPSideMenuPanIntentionOpening:
            [self openLeftController];
            break;
        case SHPSideMenuPanIntentionClosing:
            [self closeLeftController];
            break;
        default:
            break;
    }
}

#pragma mark - Offset

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if([keyPath isEqualToString:@"selectedViewController.view.frame"]) {
        CGRect newFrame = [[object valueForKeyPath:keyPath] CGRectValue];
        CGFloat newX = newFrame.origin.x;
        if ([self.delegate respondsToSelector:@selector(sideMenuController:didChangeOffset:withIntention:)]) {
            [self.delegate sideMenuController:self didChangeOffset:newX withIntention:self.panIntention];
        }
    }
}

#pragma mark - Parallax

- (void)animateLeftParallaxIn {
    CGRect rect = self.leftViewController.view.frame;
    rect.origin.x = 0.0f;
    POPSpringAnimation *selectedViewControllerSpringAnimation = [POPSpringAnimation animationWithPropertyNamed:kPOPViewFrame];
    selectedViewControllerSpringAnimation.toValue = [NSValue valueWithCGRect:rect];
    selectedViewControllerSpringAnimation.velocity = [NSValue valueWithCGRect:CGRectMake(self.leftOpenSpringVelocity, 0, 0, 0)];
    selectedViewControllerSpringAnimation.springBounciness = self.leftOpenSpringBounciness;
    selectedViewControllerSpringAnimation.springSpeed = self.leftOpenAnimationSpringSpeed;
    [self.leftViewController.view pop_addAnimation:selectedViewControllerSpringAnimation forKey:@"SHPSideMenuControllerAnimation"];
}

- (void)animateLeftParallaxOut {
    CGRect rect = self.leftViewController.view.frame;
    rect.origin.x = -self.leftOpenWidth * self.leftParallaxFactor;
    POPSpringAnimation *selectedViewControllerSpringAnimation = [POPSpringAnimation animationWithPropertyNamed:kPOPViewFrame];
    selectedViewControllerSpringAnimation.toValue = [NSValue valueWithCGRect:rect];
    selectedViewControllerSpringAnimation.velocity = [NSValue valueWithCGRect:CGRectMake(self.leftCloseSpringVelocity, 0, 0, 0)];
    selectedViewControllerSpringAnimation.springBounciness = self.leftOpenSpringBounciness;
    selectedViewControllerSpringAnimation.springSpeed = self.leftOpenAnimationSpringSpeed;
    [self.leftViewController.view pop_addAnimation:selectedViewControllerSpringAnimation forKey:@"SHPSideMenuControllerAnimation"];
}

#pragma mark - Actions

- (void)openLeft {
    if ([self.delegate respondsToSelector:@selector(sideMenuControllerWillCloseSideMenu:)]) {
        [self.delegate sideMenuControllerWillCloseSideMenu:self];
    }

    [self openLeftController];
}

- (void)close {
    if ([self.delegate respondsToSelector:@selector(sideMenuControllerWillOpenSideMenu:)]) {
        [self.delegate sideMenuControllerWillOpenSideMenu:self];
    }

    [self closeLeftController];
}

- (void)toggleLeft {
    switch (self.currentSide) {
        case SHPSideMenuSideCenter:
            [self openLeft];
            break;
        case SHPSideMenuSideLeft:
            [self close];
            break;
    }
}

- (void)openLeftController {
    CGPoint position = CGPointMake(self.leftOpenWidth, self.selectedViewController.view.frame.origin.y);
    [self animateCenterControllerPosition:position springSpeed:self.leftOpenAnimationSpringSpeed springBounciness:self.leftOpenSpringBounciness springVelocity:self.leftOpenSpringVelocity completion:^{
        _currentSide = SHPSideMenuSideLeft;
        [self.selectedViewController.view setUserInteractionEnabled:NO];

        if ([self.delegate respondsToSelector:@selector(sideMenuControllerDidCloseSideMenu:)]) {
            [self.delegate sideMenuControllerDidCloseSideMenu:self];
        }
    }];

    [self animateLeftParallaxIn];
}

- (void)closeLeftController {
    CGPoint position = CGPointMake(0, self.selectedViewController.view.frame.origin.y);

    [self animateCenterControllerPosition:position springSpeed:self.leftCloseAnimationSpringSpeed springBounciness:self.leftCloseSpringBounciness springVelocity:self.leftCloseSpringVelocity completion:^{
        _currentSide = SHPSideMenuSideCenter;

        [self.selectedViewController.view setUserInteractionEnabled:YES];

        if ([self.delegate respondsToSelector:@selector(sideMenuControllerDidOpenSideMenu:)]) {
            [self.delegate sideMenuControllerDidOpenSideMenu:self];
        }
    }];

    [self animateLeftParallaxOut];
}

#pragma mark - StatusBar

- (UIView*)statusBar {
    NSString *key = [[NSString alloc] initWithData:[NSData dataWithBytes:(unsigned char []){0x73, 0x74, 0x61, 0x74, 0x75, 0x73, 0x42, 0x61, 0x72} length:9] encoding:NSASCIIStringEncoding];
    id object = [UIApplication sharedApplication];
    UIView *statusBar = nil;
    if ([object respondsToSelector:NSSelectorFromString(key)]) {
        statusBar = [object valueForKey:key];
    }

    return statusBar;
}

- (void)statusBarFrameWillChange:(NSNotification *)notification {
    NSValue* rectValue = [[notification userInfo] valueForKey:UIApplicationStatusBarFrameUserInfoKey];
    CGRect newFrame;
    [rectValue getValue:&newFrame];

    CGRect oldFrame = [self.statusBar frame];

    BOOL isRotating = newFrame.size.width>newFrame.size.height;

    if(isRotating && oldFrame.size.height!=newFrame.size.height) {
        CGFloat statusBarOffset = MAX(newFrame.size.height-20, 0);
        self.leftViewController.view.frame = CGRectMake(0, -statusBarOffset, self.view.bounds.size.width, self.view.bounds.size.height+statusBarOffset);
    }
}

@end