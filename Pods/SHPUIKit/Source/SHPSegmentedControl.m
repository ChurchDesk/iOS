//
//  SHPSegmentedControl.m
//  THansen
//
//  Created by Ole Poulsen on 10/11/11.
//  Copyright (c) 2011 Shape ApS. All rights reserved.
//

#import "SHPSegmentedControl.h"
#import "SHPSegmentButton.h"

@interface SHPSegmentedControl () {
@private

}

@property (nonatomic, strong) NSArray *imageViews;

@end

@implementation SHPSegmentedControl
@synthesize images = _images;
@synthesize selectedIndex = _selectedIndex;
@synthesize imageViews = _imageViews;
@synthesize buttons = _buttons;


- (id)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    if (self) {

    }
    return self;
}

- (void)setImages:(NSArray *)images {
	if (images != _images) {
		_images = images;

		CGSize size = [(UIImage *)[images firstObject] size];
		self.bounds = CGRectMake(0, 0, size.width, size.height);

		// add image subviews
		NSMutableArray *imgViews = [NSMutableArray array];
		for (UIImage *img in images) {
			UIImageView *imgView = [[UIImageView alloc] initWithImage:img];
			[self addSubview:imgView];
			[imgViews addObject:imgView];
		}
		_imageViews = [imgViews copy];

		// add invisible buttons
		NSMutableArray *btns = [NSMutableArray array];
		CGFloat buttonX = 0.0f;
		for (UIImage *img in images) {
			SHPSegmentButton *btn = [SHPSegmentButton buttonWithType:UIButtonTypeCustom];
			[btn addTarget:self action:@selector(pressedButton:) forControlEvents:UIControlEventTouchDown];
			CGFloat buttonWidth = roundf(self.bounds.size.width / [images count]);
			btn.frame = CGRectMake(buttonX, 0, buttonWidth, self.bounds.size.height);
			buttonX += buttonWidth;

			[btns addObject:btn];
			[self addSubview:btn];
		}
		_buttons = [btns copy];

		[self setSelectedIndex:0];
	}
}

- (void)pressedButton:(UIButton *)sender {
	int index = [_buttons indexOfObject:sender];
	[self setSelectedIndex:index];
}

- (void)setSelectedIndex:(NSUInteger)newSelectedIndex {
	_selectedIndex = newSelectedIndex;
	UIImageView *imgView = [self.imageViews objectAtIndex:_selectedIndex];
	[self bringSubviewToFront:imgView];

	SHPSegmentButton *selectedButton = [_buttons objectAtIndex:_selectedIndex];
	for (UIButton *btn in _buttons) {
		[self bringSubviewToFront:btn];
		[btn setSelected:(btn == selectedButton)];

	}

	// fire target-action event
	[self sendActionsForControlEvents:UIControlEventValueChanged];
}


@end
