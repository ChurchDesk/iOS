//
//  SHPSegmentButton.m
//  THansen
//
//  Created by Ole Poulsen on 11/11/11.
//  Copyright (c) 2011 Shape ApS. All rights reserved.
//

#import "SHPSegmentButton.h"

@implementation SHPSegmentButton {
	CGSize _originalShadowOffset;
}
- (void)setHighlighted:(BOOL)highlighted {
	// DON'T call super!
}

- (void)setSelected:(BOOL)selected {
	[super setSelected:selected];
	if (_invertShadowOffssetOnHighlight) {
		float factor = selected ? -1.0f : 1.0f;
		self.titleLabel.shadowOffset = CGSizeMake(factor * _originalShadowOffset.width, factor * _originalShadowOffset.height);
	}
}

- (void)setInvertShadowOffssetOnHighlight:(BOOL)invertShadowOffssetOnHighlight {
	_invertShadowOffssetOnHighlight = invertShadowOffssetOnHighlight;
	_originalShadowOffset = self.titleLabel.shadowOffset;
}

@end
