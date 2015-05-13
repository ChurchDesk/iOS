//  Created by Philip Bruce on 26/06/11.
//  Copyright 2011 Shape ApS. All rights reserved.

/**
 Custom button class which fixes a problem present in UIButton where the normal state image is shown when the button is selected and the user holds his finger on it.
 
 UIButton has a strange behavior when the button is in the selected state and the user holds his finger on the button. In this case the button will show the normal state image instead of the highlighted image as would normally be expected.
 
 This class solves the problem by effectively adjusting the button so that it shows the highlighted image when it is selected and the user holds his finger on the button
 
 Just use SHPButton where you would normally use a UIButton and you will get the functionality for free.
 
 The class also adds support for a generic instance that can be customized. All new instances of the class will automatically get the style of the generic instance.
 
 If you want to subclass you should implement initGeneric and customize how the default style of the generic instance should be.
 
 To customize the generic backgroundimages you do the following:
    [[SHPButton generic] setBackgroundImage:[UIImage imageNamed:@"button"] forState:UIControlStateNormal];
    [[SHPButton generic] setBackgroundImage:[UIImage imageNamed:@"buttonHighlighted"] forState:UIControlStateHighlighted];
 
 If you have instances that should have a uniqe style you can afterwards customize them normally:
    SHPButton *button = [SHPButton alloc] init];
    [button setBackgroundImage:[UIImage imageNamed:@"buttonSpeciel"] forState:UIControlStateNormal];
 
 
 The generic instance is at the moment not supported with Interface Builder. If you have created a button in IB and want to style it with the generic style you can use the method styleGeneric.
 
*/

@interface SHPButton : UIButton {

}


/// ---------------------------------------------------------------------
/// @name Setup button style
/// ---------------------------------------------------------------------
/**
 Style the button with the generic style
 */
- (void)styleGeneric;


/**
 Styles the button with the style from another button.
 */
- (void)styleButtonWithButton:(UIButton*)button;

/**
 Returns whenever new instances always should use the generic style.
 
 Used when creating a button in Interface Builder. If YES changes made in IB will be overruled by the generic instance. Will return NO as default for this class.
 */
+ (BOOL)alwaysUseGenericStyle;

/// ---------------------------------------------------------------------
/// @name Generic instance
/// ---------------------------------------------------------------------

/**
Initialise and setup the custom style for the generic buton.
 
 Should only be called as [super initGeneric] when creating subclasses. To get a generic instance of this class use the generic method.
 */
- (id)initGeneric;



/**
 Returns the generic instance for the class. Customization to this instance will reflect all new objects of the Class. It will not reflect subclasses.
 */
+ (id)generic;



@end
