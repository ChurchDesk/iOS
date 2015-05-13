//
//  UIView+DTDebug.m
//  DTFoundation
//
//  Created by Stefan Gugarel on 2/8/13.
//  Copyright (c) 2013 Cocoanetics. All rights reserved.
//

#import <objc/runtime.h>
#import "UIView+DTDebug.h"

@implementation UIView (DTDebug)

- (void)shpui_methodCalledNotFromMainThread:(NSString *)methodName
{
	NSLog(@"-[%@ %@] being called on background queue. Break on -[UIView shpui_methodCalledNotFromMainThread:] to find out where", NSStringFromClass([self class]), methodName);
}

- (void)_setNeedsLayout_MainThreadCheck
{
	if (![NSThread isMainThread])
	{
        [self shpui_methodCalledNotFromMainThread:NSStringFromSelector(_cmd)];
	}

	// not really an endless loop, this calls the original
	[self _setNeedsLayout_MainThreadCheck];
}

- (void)_setNeedsDisplay_MainThreadCheck
{
	if (![NSThread isMainThread])
	{
        [self shpui_methodCalledNotFromMainThread:NSStringFromSelector(_cmd)];
	}

	// not really an endless loop, this calls the original
	[self _setNeedsDisplay_MainThreadCheck];
}

- (void)_setNeedsDisplayInRect_MainThreadCheck:(CGRect)rect
{
	if (![NSThread isMainThread])
	{
        [self shpui_methodCalledNotFromMainThread:NSStringFromSelector(_cmd)];
	}

	// not really an endless loop, this calls the original
	[self _setNeedsDisplayInRect_MainThreadCheck:rect];
}

+ (void)shpui_toggleViewMainThreadChecking
{
	[UIView DTswizzleMethod:@selector(setNeedsLayout) withMethod:@selector(_setNeedsLayout_MainThreadCheck)];
	[UIView DTswizzleMethod:@selector(setNeedsDisplay) withMethod:@selector(_setNeedsDisplay_MainThreadCheck)];
	[UIView DTswizzleMethod:@selector(setNeedsDisplayInRect:) withMethod:@selector(_setNeedsDisplayInRect_MainThreadCheck:)];
}

#pragma mark - Method Swizzling

+ (void)DTswizzleMethod:(SEL)selector withMethod:(SEL)otherSelector
{
	// my own class is being targetted
	Class c = [self class];

	// get the methods from the selectors
	Method originalMethod = class_getInstanceMethod(c, selector);
	Method otherMethod = class_getInstanceMethod(c, otherSelector);

	if (class_addMethod(c, selector, method_getImplementation(otherMethod), method_getTypeEncoding(otherMethod)))
	{
		class_replaceMethod(c, otherSelector, method_getImplementation(originalMethod), method_getTypeEncoding(originalMethod));
	}
	else
	{
		method_exchangeImplementations(originalMethod, otherMethod);
	}
}

+ (void)DTswizzleClassMethod:(SEL)selector withMethod:(SEL)otherSelector
{
	// my own class is being targetted
	Class c = [self class];

	// get the methods from the selectors
	Method originalMethod = class_getClassMethod(c, selector);
	Method otherMethod = class_getClassMethod(c, otherSelector);
	method_exchangeImplementations(originalMethod, otherMethod);

}

@end
