//  Created by Philip Bruce on 06/09/12
//  Copyright 2011 Shape ApS. All rights reserved.

/**
 Utilities class with miscelaneous utility c functions

 See the documentation for each method for more information
 */


#import <Foundation/Foundation.h>

CGFloat RoundToPixel(CGFloat f);
CGFloat FloorToPixel(CGFloat f);
CGFloat CeilToPixel(CGFloat f);

BOOL OSVersionGreaterThanOrEqualTo(NSString* systemVersion);
BOOL OSVersionLessThanOrEqualTo(NSString* systemVersion);