//
//  Created by Peter Gammelgaard on 15/04/14.
//  Copyright (c) 2013 SHAPE A/S. All rights reserved.
//

#import <Foundation/Foundation.h>

@class SHPSideMenuController;

typedef NS_ENUM(NSInteger, SHPSideMenuSide) {
    SHPSideMenuSideCenter,
    SHPSideMenuSideLeft
};

typedef NS_ENUM(NSInteger, SHPSideMenuPanIntention) {
    SHPSideMenuPanIntentionUnknown,
    SHPSideMenuPanIntentionOpening,
    SHPSideMenuPanIntentionClosing
};

typedef NS_ENUM(NSInteger, SHPSideMenuStatusBarBehaviour) {
    SHPSideMenuStatusBarBehaviourNormal = 0,
    SHPSideMenuStatusBarBehaviourMove
};

typedef NS_ENUM(NSInteger, SHPSideMenuPanningBehaviour) {
    SHPSideMenuPanningBehaviourNavigationBar = 0,
    SHPSideMenuPanningBehaviourFullView,
    SHPSideMenuPanningBehaviourOff
};

@interface UIViewController (SHPSideMenuController)
@property(nonatomic) SHPSideMenuController *shp_sideMenuController;
@end

@protocol SHPSideMenuControllerDelegate <NSObject>
@optional
- (void)sideMenuControllerWillOpenSideMenu:(SHPSideMenuController *)sideMenuController;
- (void)sideMenuControllerDidOpenSideMenu:(SHPSideMenuController *)sideMenuController;
- (void)sideMenuControllerWillCloseSideMenu:(SHPSideMenuController *)sideMenuController;
- (void)sideMenuControllerDidCloseSideMenu:(SHPSideMenuController *)sideMenuController;
- (void)sideMenuController:(SHPSideMenuController *)sideMenuController didChangeOffset:(CGFloat)offset withIntention:(SHPSideMenuPanIntention)intention;
@end

@interface SHPSideMenuControllerBuilder : NSObject
@property (nonatomic) CGFloat leftOpenWidth;
@property (nonatomic) CGFloat leftOpenAnimationSpringSpeed;
@property (nonatomic) CGFloat leftOpenSpringBounciness;
@property (nonatomic) CGFloat leftOpenSpringVelocity;
@property (nonatomic) CGFloat leftCloseAnimationSpringSpeed;
@property (nonatomic) CGFloat leftCloseSpringBounciness;
@property (nonatomic) CGFloat leftCloseSpringVelocity;
@property (nonatomic) CGFloat leftParallaxAnimationDuration;
@property (nonatomic) CGFloat leftParallaxFactor;
@property (nonatomic) SHPSideMenuStatusBarBehaviour statusBarBehaviour;
@property (nonatomic) SHPSideMenuPanningBehaviour panningBehaviour;
@end

@interface SHPSideMenuController : UIViewController
@property (nonatomic, strong) UIViewController *selectedViewController;
@property (nonatomic, strong) UIViewController *leftViewController;
@property (nonatomic, readonly) SHPSideMenuSide currentSide;
@property (nonatomic, weak) id <SHPSideMenuControllerDelegate> delegate;

//Parameters
@property (nonatomic, readonly) CGFloat leftOpenWidth;
@property (nonatomic, readonly) CGFloat leftOpenAnimationSpringSpeed;
@property (nonatomic, readonly) CGFloat leftOpenSpringBounciness;
@property (nonatomic, readonly) CGFloat leftOpenSpringVelocity;
@property (nonatomic, readonly) CGFloat leftCloseAnimationSpringSpeed;
@property (nonatomic, readonly) CGFloat leftCloseSpringBounciness;
@property (nonatomic, readonly) CGFloat leftCloseSpringVelocity;
@property (nonatomic, readonly) CGFloat leftParallaxAnimationDuration;
@property (nonatomic, readonly) CGFloat leftParallaxFactor;
@property (nonatomic, readonly) SHPSideMenuStatusBarBehaviour statusBarBehaviour;
@property (nonatomic, assign) SHPSideMenuPanningBehaviour panningBehaviour;


+ (instancetype)sideMenuControllerWithBuilder:(void (^)(SHPSideMenuControllerBuilder *builder))builderBlock;
+ (SHPSideMenuController *)sideMenuControllerWithBuilder:(void (^)(SHPSideMenuControllerBuilder *))builderBlock completion:(void (^)())completion;
- (id)initWithCompletion:(void (^)())completion;
- (void)setupWithBuilder:(SHPSideMenuControllerBuilder *)builder;

- (void)openLeft;
- (void)close;
- (void)toggleLeft;

- (void)setSelectedViewController:(UIViewController *)selectedViewController closeMenu:(BOOL)close;

@end