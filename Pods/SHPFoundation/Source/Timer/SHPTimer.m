//  Created by Philip Bruce on 21/02/11.
//  Copyright 2011 Shape ApS. All rights reserved.

#import "SHPTimer.h"

@interface SHPTimer() {
    NSMutableArray *_timers;   
}

@property (nonatomic, strong) NSMutableArray *timers;

@end

@implementation SHPTimer
@synthesize timers = _timers;

#pragma mark - Init / dealloc

- (id)init {
    if (!(self = [super init])) {
        return nil;
    }
    
    [self setTimers:[NSMutableArray array]];
    
    return self;
}


#pragma mark - Timers

- (void)addTimerWithTag:(NSString *)tag interval:(NSTimeInterval)interval target:(id)target selector:(SEL)selector repeats:(BOOL)repeats {
    NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:interval target:target selector:selector userInfo:tag repeats:repeats];
    NSDictionary *timerDict = [NSDictionary dictionaryWithObject:timer forKey:tag];
    [_timers addObject:timerDict];

}

- (void)removeTimerWithTag:(NSString *)tag {
    for (NSDictionary *timerDict in _timers) {
        NSTimer *timer = [timerDict objectForKey:tag];
        if (timer) {
            [timer invalidate];
            [_timers removeObject:timerDict];
            break;
        }
    }
}

#pragma mark - Singleton

+(SHPTimer *)sharedInstance {   
    static SHPTimer *sharedInstance = nil;
    static dispatch_once_t pred;
    
    if (sharedInstance) return sharedInstance;
    
    dispatch_once(&pred, ^{
        sharedInstance = [SHPTimer alloc];
        sharedInstance = [sharedInstance init];
    });
    
    return sharedInstance;
}

@end
