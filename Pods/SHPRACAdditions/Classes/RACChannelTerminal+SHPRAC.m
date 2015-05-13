//
//  RACChannelTerminal+SHPRAC.m
//  Pods
//
//  Created by Mikkel Selsøe Sørensen on 07/01/15.
//
//

#import "RACChannelTerminal+SHPRAC.h"
#import "ReactiveCocoa.h"

@implementation RACChannelTerminal (SHPRAC)

- (void) shprac_connectTo: (RACChannelTerminal*) terminal {
    [self subscribe:terminal];
    [[terminal skip:1] subscribe:self]; // Ignores terminal value and lets self determine value
}

- (void) shprac_connectWithMap:(id (^)(id value))map to:(RACChannelTerminal*)terminal withMap:(id (^)(id value))otherMap {
    [[self map:map] subscribe:terminal];
    [[[terminal skip:1] map:otherMap] subscribe:self];
}

@end
