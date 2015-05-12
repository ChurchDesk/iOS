//
// Created by philip on 06/09/12.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import "SHPUtilities.h"

static NSString *const kDateFormatterKey = @"SHPLOG_DATE_FORMATTER";

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
NSString *SHPCreateUUID() {
    Class uuidClass = NSClassFromString(@"NSUUID");
    if (uuidClass) {
        // class exists
        return [[uuidClass performSelector:NSSelectorFromString(@"UUID")] performSelector:NSSelectorFromString(@"UUIDString")];
    } else {
        CFUUIDRef udid = CFUUIDCreate(kCFAllocatorDefault);
        NSString *uuidString = (__bridge_transfer NSString *)CFUUIDCreateString(kCFAllocatorDefault, udid);
        CFRelease(udid);
        return uuidString;
    }
}

#pragma clang diagnostic pop

dispatch_queue_t SHPCreateSerialQueueWithRandomName() {
    NSString *queueName = SHPCreateUUID();
    dispatch_queue_t queue = dispatch_queue_create([queueName cStringUsingEncoding:NSASCIIStringEncoding], DISPATCH_QUEUE_SERIAL);
    return queue;
}

dispatch_source_t SHPCreateDispatchTimer(uint64_t interval, uint64_t leeway, dispatch_queue_t queue, dispatch_block_t block) {
    dispatch_source_t timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue);
    if (timer) {
        dispatch_source_set_timer(timer, dispatch_walltime(NULL, 0), interval * NSEC_PER_SEC, leeway * NSEC_PER_SEC);
        dispatch_source_set_event_handler(timer, block);

        double delayInSeconds = interval;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
        dispatch_after(popTime, queue, ^(void){
            dispatch_resume(timer);
        });
    }
    return timer;
}


NSDateFormatter *ThreadLocalLogDateFormatter() {
    NSMutableDictionary *threadCache = [[NSThread currentThread] threadDictionary];
    NSDateFormatter *df = threadCache[kDateFormatterKey];
    if (!df) {
        df = [[NSDateFormatter alloc] init];
        df.dateFormat = @"HH:mm:ss.SSS";
        threadCache[kDateFormatterKey] = df;
    }
    return df;
}

void SHPLogFunction(NSString *format, NSString *file, NSUInteger line, ...) {
    NSDateFormatter *df = ThreadLocalLogDateFormatter();
    NSString *timeStr = [df stringFromDate:[NSDate date]];

    va_list args;
    va_start(args, format);
    NSString *logStr = [[NSString alloc] initWithFormat:format arguments:args];
    NSString *withTimeStr = [[NSString alloc] initWithFormat:@"%@ : %@ (%@:%d)", timeStr, logStr, file, line];
    CFShow((__bridge CFStringRef)withTimeStr);
    va_end(args);
}
