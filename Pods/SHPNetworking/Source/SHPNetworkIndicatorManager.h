//
// Created by kronborg on 09/01/13.
//


#import <Foundation/Foundation.h>


@interface SHPNetworkIndicatorManager : NSObject
+ (instancetype)sharedNetworkIndicatorManager;
- (void)addNetworkOperationQueue:(NSOperationQueue *)queue;
@end