SHPSideMenu
===========
SHPSideMenu provides a simple but powerfull side menu. It has the following features

* Move statusbar automatically with selected ViewController
* Customizable
* Supports in-app call status bar.
* ~> iOS7

Relevant methods and properties are named prefixed with 'left' because of the possible of an updated version with support for a right side menu.

If you have any problems please look at the sample code or ask!

#Setting it up

Install using CocoaPods

	pod 'SHPSideMenu'
	
#Using it

Create and setup ``SHPSideMenuController``

	SHPSideMenuController *sideMenuController = [SHPSideMenuController sideMenuControllerWithBuilder:^(SHPSideMenuControllerBuilder *builder) {
		builder.statusBarBehaviour = SHPSideMenuStatusBarBehaviourMove;
		// More customizations
    }];
    sideMenuController.leftViewController = leftViewController;
    
Set selected ViewController

	[sideMenuController setSelectedViewController:viewController];
	
	
Or from the left ViewController and any ViewController added to the side menu using property

	[self.shp_sideMenuController setSelectedViewController:viewController]

Open or close menu

	[self.shp_sideMenuController openLeft]; //Open the left menu
	[self.shp_sideMenuController close]; //Close the menu
	[self.shp_sideMenuController toggleLeft];// Toggle between close and open
	
#Delegate callbacks
Get callbacks when various events happen. Implement ``SHPSideMenuControllerDelegate`` and set `delegate` property.

	
Called when the side menu is about to be opened.
	
	- (void)sideMenuControllerWillOpenSideMenu:(SHPSideMenuController *)sideMenuController;

Called when the side menu did open.

	- (void)sideMenuControllerDidOpenSideMenu:(SHPSideMenuController *)sideMenuController;

Called when the side menu is about to me closed.

	- (void)sideMenuControllerWillCloseSideMenu:(SHPSideMenuController *)sideMenuController;

Called when the side menu did close.

	- (void)sideMenuControllerDidCloseSideMenu:(SHPSideMenuController *)sideMenuController;
	
Called when the offset of the side menu changes.
	
	- (void)sideMenuController:(SHPSideMenuController *)sideMenuController didChangeOffset:(CGFloat)offset withIntention:(SHPSideMenuPanIntention)intention;
	
	
UIViewControllers added to the ``SHPSideMenuController`` will receive the normal view callback according to the ``UIViewController`` lifecycle.

#Customizing it
When creating it many options can be customized.

###CGFloat leftOpenWidth
The width of the left ViewController when opened.
Default value is ``270.0``.

###GFloat leftOpenAnimationDuration
Duration of the opening animation of the left ViewController.
Default value is ``0.35``.

###GFloat leftCloseAnimationDuration
Duration of the close animation of the left ViewController.
Default value is ``0.45``.

###CGFloat leftOpenSpringDamping
Spring damping of the opening animation of the left ViewController.
Default value is ``1.0``.

###CGFloat leftCloseSpringDamping
Spring damping of the close animation of the left ViewController.
Default value is ``1.0``.

###CGFloat leftOpenSpringVelocity
Spring velocity of the opening animation of the left ViewController.
Default value is ``0.0``.

###CGFloat leftCloseSpringVelocity
Spring velocity of the close animation of the left ViewController.
Default value is ``0.0``.

###CGFloat leftParallaxAnimationDuration
Duration of the parallax animation for the left ViewController.
Default value is ``0.45``.

###CGFloat leftParallaxFactor
Factor of the parallax animation for the left ViewController.
Set to ``0.0`` to turn of parallaxing.
Default value is ``0.35``.

###SHPSideMenuStatusBarBehaviour statusBarBehaviour

Possible Values

	SHPSideMenuStatusBarBehaviourNormal //StatusBar has normal iOS behaviour
	SHPSideMenuStatusBarBehaviourMove //StatusBar moves with selectedViewController

Default value is ``SHPSideMenuStatusBarBehaviourNormal``

###SHPSideMenuPanningBehaviour panningBehaviour

Possible Values

	SHPSideMenuPanningBehaviourNavigationBar //Panning allowed in navigation bar only
	SHPSideMenuPanningBehaviourFullView //Panning allowed in fullview for rootViewController and navigationBar for other ViewController

Default value is ``SHPSideMenuPanningBehaviourFullView``
