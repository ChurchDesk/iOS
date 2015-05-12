//
// Created by kronborg on 09/01/13.
//


#import "SHPNetworkIndicatorManager.h"


@implementation SHPNetworkIndicatorManager
{
    NSMutableArray *_queues;
//    BOOL _isNetworkActivityIndicatorVisible;
}

+ (instancetype)sharedNetworkIndicatorManager
{
    __strong static SHPNetworkIndicatorManager *_sharedObject = nil;

    static dispatch_once_t token = 0;
    dispatch_once(&token, ^{
        _sharedObject = [[self alloc] init];
    });

    return _sharedObject;
}

- (instancetype)init
{
    if (!(self = [super init])) return nil;

    _queues = [[NSMutableArray alloc] init];

    return self;
}

- (void)addNetworkOperationQueue:(NSOperationQueue *)queue
{
    [queue addObserver:self forKeyPath:@"operations" options:(NSKeyValueObservingOptions) 0 context:nil];

    [_queues addObject:queue];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"operations"]) {
        BOOL hasRunningOperation = NO;
        for (NSOperationQueue *queue in _queues) {
            if ([queue operationCount] > 0) {
                hasRunningOperation = YES;
                break;
            }
        }

        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:hasRunningOperation];
        }];
    }
}

@end