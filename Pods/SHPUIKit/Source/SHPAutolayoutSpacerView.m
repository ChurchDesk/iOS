//
//  Created by Ole Gammelgaard Poulsen on 14/03/13.
//  Copyright (c) 2012 SHAPE A/S. All rights reserved.
//

#import "SHPAutolayoutSpacerView.h"


@implementation SHPAutolayoutSpacerView {

}

- (id)init {
	self = [super init];
	if (self) {
		self.translatesAutoresizingMaskIntoConstraints = NO;
//		self.backgroundColor = [UIColor orangeColor];

	}

	return self;
}

- (CGSize)intrinsicContentSize {
	return (CGSize){10, 6};
}

@end