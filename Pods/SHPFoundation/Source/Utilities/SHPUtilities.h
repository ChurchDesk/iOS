//  Created by Philip Bruce on 06/09/12
//  Copyright 2011 Shape ApS. All rights reserved.

/**
 Utilities class with miscelaneous utility c functions

 See the documentation for each method for more information
 */

/**
 Assertion macro which prints to the console, unlike the normal NSAssert macro.

 It's only defined when NS_BLOCK_ASSERTIONS is not - just like a normal NSAssert,
 meaning it's not included in release builds
*/
#ifndef NS_BLOCK_ASSERTIONS
    #define SHPAssert(expression, ...) \
        do { \
            if(!(expression)) { \
                NSString *__SHPAssert_temp_string = [NSString stringWithFormat: @"Assertion failure: %s in %s on line %s:%d. %@", #expression, __func__, __FILE__, __LINE__, [NSString stringWithFormat: @"" __VA_ARGS__]]; \
                NSLog(@"%@", __SHPAssert_temp_string); \
                abort(); \
            } \
        } while(0)
#else
    #define SHPAssert(expression, ...) // Shouldn't do anything when building for release
#endif

#import <Foundation/Foundation.h>

/// ---------------------------------------------------------------------
/// @name UDIDs
/// ---------------------------------------------------------------------

/**
 Creates a random UDID and returns it as an NSString
*/
NSString *SHPCreateUUID();

/// ---------------------------------------------------------------------
/// @name Dispatch queues
/// ---------------------------------------------------------------------

/**
 Creates a serial dispatch queue with a random name
*/
dispatch_queue_t SHPCreateSerialQueueWithRandomName();

/**
 Creates a dispatch timer with the given properties

 The documentation for this method should be expanded
*/
dispatch_source_t SHPCreateDispatchTimer(uint64_t interval, uint64_t leeway, dispatch_queue_t queue, dispatch_block_t block);


/**
* Log a line prefixing with additional info 'context' and 'log level', e.g. [SHPFoundation] [DEBUG] It's all gone wrong!
*
* You can use all normal format specifiers for the actual string to log just like with NSLog
* You can pass in 'nil' for the log level if you don't want to show it
*/

#define SHPContextLogLevelNone nil
#define SHPContextLogLevelDebug @"DEBUG"
#define SHPContextLogLevelInfo @"INFO"
#define SHPContextLogLevelError @"ERROR"

#define SHPContextLog(context, logLevel, format, ...) \
    { \
    NSString *formattedLogLevel = (logLevel == nil) ? @" " : [NSString stringWithFormat:@" [%@] ", logLevel]; \
    NSString *contextAndFormat = [NSString stringWithFormat:@"[%@]%@%@", context, formattedLogLevel, format]; \
    SHPLogFunction(contextAndFormat, [@""__FILE__ lastPathComponent], __LINE__, ##__VA_ARGS__); \
    }

/**
* Log a line using the context logger, and use the current class name, i.e. [self class] as the context
*/
#define SHPClassContextLog(logLevel, format, ...) SHPContextLog(NSStringFromClass([self class]), logLevel, format, ##__VA_ARGS__)

#define SHPLog(format,...) SHPLogFunction(format, [@""__FILE__ lastPathComponent], __LINE__, ##__VA_ARGS__);
void SHPLogFunction(NSString *format, NSString *file, NSUInteger line, ...);
