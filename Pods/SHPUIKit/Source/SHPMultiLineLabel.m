//
// Created by Soren Ulrikkeholm on 05/02/15.
//

#import "SHPMultiLineLabel.h"

@implementation SHPMultiLineLabel

- (id)init {
    if (!(self = [super init])) return nil;

    [self setNumberOfLines:0];
    self.lineBreakMode = NSLineBreakByWordWrapping;

    return self;
}

- (void)setBounds:(CGRect)bounds {
    [super setBounds:bounds];

    // Only do this on versions below iOS 8.0.0
    if (floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_7_1) {
        [self setPreferredMaxLayoutWidth:bounds.size.width];
    }
}

@end