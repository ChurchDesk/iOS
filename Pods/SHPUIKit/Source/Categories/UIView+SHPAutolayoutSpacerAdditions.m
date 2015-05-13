//
//  Created by Ole Gammelgaard Poulsen on 14/03/13.
//  Copyright (c) 2012 SHAPE A/S. All rights reserved.
//

#import "UIView+SHPAutolayoutSpacerAdditions.h"
#import "SHPAutolayoutSpacerView.h"

@implementation UIView (SHPAutolayoutSpacerAdditions)

- (NSDictionary *)shpui_addSpacerViewsCount:(NSUInteger)numSpacers {
	[self removeFromSuperview];

    NSMutableArray *mSpacerViews = [NSMutableArray arrayWithCapacity:numSpacers];
    for (NSUInteger i = 0; i < numSpacers; i++) {
        SHPAutolayoutSpacerView *spacer = [SHPAutolayoutSpacerView new];
        spacer.tag = i;
        [mSpacerViews addObject:spacer];
    }
    NSArray *spacerViews = [mSpacerViews copy];

	[spacerViews enumerateObjectsUsingBlock:^(SHPAutolayoutSpacerView *spacer, NSUInteger idx, BOOL *stop) {
		[self addSubview:spacer];
	}];

    NSMutableArray *mKeys = [NSMutableArray arrayWithCapacity:numSpacers];
    for (NSUInteger i = 0; i < numSpacers; i++) {
        [mKeys addObject:[NSString stringWithFormat:@"spacer%d", i]];
    }
    NSArray *keys = [mKeys copy];

	NSDictionary *bindings = [NSDictionary dictionaryWithObjects:spacerViews forKeys:keys];
	return bindings;
}

- (void)shpui_removeSpacerViews {
	[self.subviews enumerateObjectsUsingBlock:^(UIView *v, NSUInteger idx, BOOL *stop) {
		if ([v isKindOfClass:[SHPAutolayoutSpacerView class]]) {
			[v removeFromSuperview];
		}
	}];
}

@end
