//
//  SHPCache.m
//  SHPNetworking
//
//  Created by Kasper Kronborg on 06/12/12.
//  Copyright (c) 2012 SHAPE A/S. All rights reserved.
//

#import "SHPCache.h"
#import "SHPCacheObject.h"

static NSString *const kFileFolderName = @"SHPNetworking";
static NSString *const kDataFileName = @"cache.data";
static NSString *const kManifestFileName = @"manifest.data";
static NSSearchPathDirectory const kSearchPathDirectory = NSCachesDirectory;

@interface SHPCache () <NSCacheDelegate>

@property (nonatomic, strong) NSURL *cacheFileURL;
@property (nonatomic, strong) NSURL *cacheManifestFileURL;
@property (nonatomic, strong) NSOperationQueue *fileOperationQueue;
@property (nonatomic, strong) NSArray *fileCacheKeyPatterns;
@property (nonatomic, strong) NSSet *cachedKeys; // Used to look up keys existing in file cache before it is loaded from disk
@property (nonatomic, assign) BOOL diskCacheReady;

@end

@implementation SHPCache
{
    NSMutableDictionary *_cache;
}

- (id)init
{
    if (!(self = [super init])) return nil;

    _cache = [[NSMutableDictionary alloc] init];
    [self loadCacheFromDisk];

    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)cacheObject:(id)object forKey:(NSString *)key withInterval:(NSTimeInterval)interval
{
    if (key) {
        @synchronized(self) {
            SHPCacheObject *cacheObject = [[SHPCacheObject alloc] init];
            [cacheObject setKey:key];
            [cacheObject setDate:[NSDate date]];
            [cacheObject setInterval:interval];
            [cacheObject setContent:object];

            [_cache setObject:cacheObject forKey:key];
        }
    }
}

- (id)cachedObjectForKey:(NSString *)key
{
    @synchronized(self) {
        SHPCacheObject *cachedObject = [_cache objectForKey:key];
        if (cachedObject) {
            if (![cachedObject isExpired]) {
                if (cachedObject.content) {
                    return cachedObject.content;
                }
            }
        }

        return nil;
    }
}

- (BOOL) cacheContainsObjectForKey: (NSString*) key {
    if (self.diskCacheReady) {
        return [self cachedObjectForKey:key] != nil;
    }
    return [self.cachedKeys containsObject:key];
}

- (void)invalidateAllObjects
{
    @synchronized(self) {
        [_cache removeAllObjects];
    }
}

- (void)invalidateObjectsMatchingRegex:(NSString *)regex
{
    @synchronized(self) {
        [_cache removeObjectsForKeys:[self keysMatchingRegex:regex]];
    }
}

- (NSArray *)allKeys
{
    @synchronized(self) {
        return [_cache allKeys];
    }
}

- (NSArray *)keysMatchingRegex:(NSString *)regexPattern
{
	NSArray *keys = [self allKeys];

    NSMutableArray *mMatches = [NSMutableArray arrayWithCapacity:[keys count]];
    for (NSString *k in keys) {
        NSError *error = nil;
        NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:regexPattern options:NSRegularExpressionCaseInsensitive error:&error];
        NSTextCheckingResult *match = [regex firstMatchInString:k options:0 range:NSMakeRange(0, [k length])];
        if (match != nil) {
            [mMatches addObject:k];
        }
    };
    NSArray *matches = [mMatches copy];

    return matches;
}

#pragma mark - Disk Cache

- (void) setEnableDiskCacheForKeysMatchingRegexes: (NSArray*) regexes {
    self.fileCacheKeyPatterns = [regexes copy];

#if TARGET_IPHONE_SIMULATOR
    if (regexes.count) {
        NSLog(@"SHPNetworking: Note that SHPNetworking will only persist the disk cache when app is sent to the background. Hit Cmd+Shift+H in the simulator to enforce. Happy coding!");
    }
#endif

    // Ensure no more than one observer at all times.
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidEnterBackgroundNotification object:[UIApplication sharedApplication]];
    if (self.fileCacheKeyPatterns.count) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillEnterBackground:) name:UIApplicationDidEnterBackgroundNotification object:[UIApplication sharedApplication]];
    }
}

#pragma mark Private

- (void) saveToDisk {
    NSDictionary *cacheCopy = [_cache copy];

    NSMutableDictionary *cacheToPersist = [NSMutableDictionary new];
    NSMutableSet *keysToPersist = [NSMutableSet new];
    for (NSString *pattern in self.fileCacheKeyPatterns) {
        [keysToPersist addObjectsFromArray:[self keysMatchingRegex:pattern]];
    }

    [self.fileOperationQueue addOperationWithBlock:^{
        [cacheCopy enumerateKeysAndObjectsUsingBlock:^(NSString *key, SHPCacheObject *cachedObject, BOOL *stop) {
            if (![self cacheObjectIsExpiredForDiskCache:cachedObject] && [keysToPersist containsObject:key]) {
                [cacheToPersist setObject:cachedObject forKey:key];
            }
        }];

        if ([self createCacheDirectoryIfNeeded] && ![NSKeyedArchiver archiveRootObject:cacheToPersist toFile:self.cacheFileURL.path]) {
            NSLog(@"Failed to archive SHPNetworking disk cache");
        }
        if (![NSKeyedArchiver archiveRootObject:keysToPersist toFile:self.cacheManifestFileURL.path]) {
            NSLog(@"Failed to archive SHPNetworking manifest disk cache");
        }
    }];
}

- (void) loadCacheFromDisk {
    if (![self fileCacheExists]) {
        self.diskCacheReady = YES;
        return;
    }

    self.cachedKeys = [NSKeyedUnarchiver unarchiveObjectWithFile:self.cacheManifestFileURL.path];

    [self.fileOperationQueue addOperationWithBlock:^{

        NSData *cacheData = [NSData dataWithContentsOfURL:self.cacheFileURL];
        NSDictionary *cache = nil;

        @try {
            cache = cacheData.length ? [NSKeyedUnarchiver unarchiveObjectWithData:cacheData] : nil;
        }
        @catch (NSException *exception) {
            NSLog(@"Error loading SHPNetworking cache from disk: %@", exception);
            cache = nil;
        }

        NSMutableDictionary *mutableCache = [cache mutableCopy];

        [[NSOperationQueue mainQueue] addOperationWithBlock:^{

            [cache enumerateKeysAndObjectsUsingBlock:^(NSString* key, SHPCacheObject *cacheObject, BOOL *stop) {
                // reset the cache date so that the object will
                // live on for the specified caching interval
                cacheObject.date = [NSDate date];

                if ([_cache objectForKey:key] != nil) {
                    // Handle case where we got a server response and
                    // cached it before the disk cache is ready
                    [mutableCache removeObjectForKey:key];
                }
            }];

            if (_cache && mutableCache) {
                [_cache addEntriesFromDictionary:mutableCache];
            }
            self.diskCacheReady = YES;
        }];
    }];
}

- (BOOL) cacheObjectIsExpiredForDiskCache: (SHPCacheObject*) cacheObject {
    if (self.diskCacheAgeLimit == 0) {
        return NO;
    }

    NSTimeInterval secondsOld = -[cacheObject.date timeIntervalSinceNow];
    if (secondsOld < self.diskCacheAgeLimit) {
        return NO;
    }
    return YES;
}

- (void) applicationWillEnterBackground: (NSNotification*) notification {
    [self saveToDisk];
}

- (NSURL *)cacheFileURL {
    if (!_cacheFileURL) {
        _cacheFileURL = [[self cacheDirectoryURL] URLByAppendingPathComponent:kDataFileName];
    }
    return _cacheFileURL;
}

- (NSURL *)cacheManifestFileURL {
    if (!_cacheManifestFileURL) {
        _cacheManifestFileURL = [[self cacheDirectoryURL] URLByAppendingPathComponent:kManifestFileName];
    }
    return _cacheManifestFileURL;
}

- (NSURL*) cacheDirectoryURL {
    NSArray *urls = [[NSFileManager defaultManager] URLsForDirectory:kSearchPathDirectory inDomains:NSUserDomainMask];

    NSURL *docsURL = urls.firstObject;
    docsURL = [docsURL URLByAppendingPathComponent:kFileFolderName isDirectory:YES];
    return docsURL;
}

- (BOOL) createCacheDirectoryIfNeeded {
    NSError *error = nil;
    BOOL success = [[NSFileManager defaultManager] createDirectoryAtURL:[self cacheDirectoryURL] withIntermediateDirectories:YES attributes:nil error:&error];
    if (!success) {
        NSLog(@"Error creating incoming files folder: %@", error);
    }
    return success;
}

- (BOOL) fileCacheExists {
    return [[NSFileManager defaultManager] fileExistsAtPath:self.cacheFileURL.path];
}

- (NSOperationQueue *)fileOperationQueue {
    if (!_fileOperationQueue) {
        _fileOperationQueue = [[NSOperationQueue alloc] init];
        _fileOperationQueue.name = @"SHPNetworking file cache queue";
        _fileOperationQueue.maxConcurrentOperationCount = 1;
    }
    return _fileOperationQueue;
}

@end
