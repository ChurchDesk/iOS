//
//  RACChannelTerminal+SHPRAC.h
//  Pods
//
//  Created by Mikkel Selsøe Sørensen on 07/01/15.
//
//

#import "RACChannel.h"

@class RACChannelTerminal;

@interface RACChannelTerminal (SHPRAC)

- (void) shprac_connectTo: (RACChannelTerminal*) terminal;

- (void) shprac_connectWithMap:(id (^)(id value))map to:(RACChannelTerminal*)terminal withMap:(id (^)(id value))otherMap;

@end
