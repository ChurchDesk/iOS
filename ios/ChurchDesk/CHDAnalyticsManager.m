//
// Created by philip on 08/12/14.
//
// Copyright SHAPE A/S
//

#import "CHDAnalyticsManager.h"
#import "GAI.h"
#import "GAILogger.h"
#import "GAIDictionaryBuilder.h"
#import "GAIFields.h"

@interface CHDAnalyticsManager ()

@end

@implementation CHDAnalyticsManager

+ (CHDAnalyticsManager *)sharedInstance {
    static CHDAnalyticsManager *sharedInstance = nil;
    static dispatch_once_t pred;

    if (sharedInstance) return sharedInstance;

    dispatch_once(&pred, ^{
        sharedInstance = [CHDAnalyticsManager alloc];
        sharedInstance = [sharedInstance init];
    });

    return sharedInstance;
}

- (void)startGoogleAnalytics {
#if TARGET_IPHONE_SIMULATOR
    // Optional: set Logger to VERBOSE for debug information.
//    [[[GAI sharedInstance] logger] setLogLevel:kGAILogLevelVerbose];
#endif

    [[GAI sharedInstance] trackerWithTrackingId:@"UA-61679466-1"];
}

- (void)trackVisitToScreen:(NSString *)screenName {
    id tracker = [[GAI sharedInstance] defaultTracker];
    [tracker set:kGAIScreenName value:screenName];
    [tracker send:[[GAIDictionaryBuilder createScreenView] build]];
}

- (void)trackEventWithCategory:(NSString *)category action:(NSString *)action label:(NSString *)label {
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:category action:action label:label value:nil] build]];
}

- (void)trackTimingWithCategory:(NSString *)category name:name label:(NSString *)label block:(void(^)())block {
    CFTimeInterval startTime = CACurrentMediaTime();
    block();
    CFTimeInterval endTime = CACurrentMediaTime();
    CFTimeInterval executionTime = endTime - startTime;
    NSUInteger executionTimeInMs = (NSUInteger) (executionTime * 1000);

    id tracker = [[GAI sharedInstance] defaultTracker];
    [tracker send:[[GAIDictionaryBuilder createTimingWithCategory:category interval:@((NSUInteger)executionTimeInMs) name:name label:label] build]];
}

- (void)trackTimedEventWithCategory:(NSString *)category name:(NSString *)name label:(NSString *)label interval:(NSUInteger)executionTimeInMs {
    id tracker = [[GAI sharedInstance] defaultTracker];
    [tracker send:[[GAIDictionaryBuilder createTimingWithCategory:category interval:@((NSUInteger)executionTimeInMs) name:name label:label] build]];
}

@end
