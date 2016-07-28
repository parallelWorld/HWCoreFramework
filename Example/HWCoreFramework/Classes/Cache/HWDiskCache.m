//
//  HWDiskCache.m
//  HWCoreFramework
//
//  Created by 58 on 7/25/16.
//  Copyright © 2016 ParallelWorld. All rights reserved.
//

#import "HWDiskCache.h"
#import <CommonCrypto/CommonCrypto.h>


#define LOCK() dispatch_semaphore_wait(self->_lock, DISPATCH_TIME_FOREVER)
#define UNLOCK() dispatch_semaphore_signal(self->_lock)


/// Free disk space in bytes.
static int64_t _HWDiskSpaceFree() {
    NSError *error = nil;
    NSDictionary *attrs = [[NSFileManager defaultManager] attributesOfFileSystemForPath:NSHomeDirectory() error:&error];
    if (error) return -1;
    int64_t space = [attrs[NSFileSystemFreeSize] longLongValue];
    if (space < 0) space = -1;
    return space;
}

/// String's md5 hash.
static NSString *_HWNSStringMD5(NSString *string) {
    if (!string) return nil;
    NSData *data = [string dataUsingEncoding:NSUTF8StringEncoding];
    unsigned char result[CC_MD5_DIGEST_LENGTH];
    CC_MD5(data.bytes, (CC_LONG)data.length, result);
    return [NSString stringWithFormat:
            @"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
            result[0],  result[1],  result[2],  result[3],
            result[4],  result[5],  result[6],  result[7],
            result[8],  result[9],  result[10], result[11],
            result[12], result[13], result[14], result[15]
            ];
}

/// Weak reference for all instances
static NSMapTable *_globalInstances;
/// Keep disk cache to be unique.
static dispatch_semaphore_t _globalInstancesLock;

static void _HWDiskCacheInitGlobal() {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _globalInstancesLock = dispatch_semaphore_create(1);
        _globalInstances = [[NSMapTable alloc] initWithKeyOptions:NSPointerFunctionsStrongMemory valueOptions:NSPointerFunctionsWeakMemory capacity:0];
    });
}

static HWDiskCache *_HWDiskCacheGetGlobal(NSString *path) {
    if (path.length == 0) return nil;
    _HWDiskCacheInitGlobal();
    dispatch_semaphore_wait(_globalInstancesLock, DISPATCH_TIME_FOREVER);
    id cache = [_globalInstances objectForKey:path];
    dispatch_semaphore_signal(_globalInstancesLock);
    return cache;
}

static void _HWDiskCacheSetGlobal(HWDiskCache *cache) {
    if (cache.path.length == 0) return;
    _HWDiskCacheInitGlobal();
    dispatch_semaphore_wait(_globalInstancesLock, DISPATCH_TIME_FOREVER);
    [_globalInstances setObject:cache forKey:cache.path];
    dispatch_semaphore_signal(_globalInstancesLock);
}


@implementation HWDiskCache {
    dispatch_semaphore_t _lock;
    dispatch_queue_t _queue;
}

- (void)dealloc {}

- (instancetype)initWithPath:(NSString *)path {
    self = [super init];
    if (!self) return nil;
    
    HWDiskCache *globalCache = _HWDiskCacheGetGlobal(path);
    if (globalCache) return globalCache;
    
    _path = path;
    _lock = dispatch_semaphore_create(1);
    _queue = dispatch_queue_create("com.parallelworld.cache.disk", DISPATCH_QUEUE_CONCURRENT);
    [self p_createCacheDirectory];
    _HWDiskCacheSetGlobal(self);
    
    return self;
}

#pragma mark - Public

- (id<NSCoding>)objectForKey:(NSString *)key {
    if (!key) return nil;
    
    LOCK();
    NSString *filePath = [self p_encodedFileURLForKey:key];
    id<NSCoding> object = nil;
    if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
        @try {
            object = [NSKeyedUnarchiver unarchiveObjectWithFile:filePath];
        } @catch (NSException *exception) {
            // TODO
        }
    }
    UNLOCK();
    
    return object;
}

- (void)objectForKey:(NSString *)key withBlock:(void (^)(NSString *, id<NSCoding>))block {
    if (!block) return;
    __weak typeof(self) _self = self;
    dispatch_async(_queue, ^{
        __strong typeof(_self) self = _self;
        id<NSCoding> object = [self objectForKey:key];
        block(key, object);
    });
}

- (void)setObject:(id<NSCoding>)object forKey:(NSString *)key {
    if (!key) return;
    if (!object) {
        [self removeObjectForKey:key];
        return;
    }
    
    LOCK();
    NSString *filePath = [self p_encodedFileURLForKey:key];
    [NSKeyedArchiver archiveRootObject:object toFile:filePath];
    UNLOCK();
}

- (void)setObject:(id<NSCoding>)object forKey:(NSString *)key withBlock:(void (^)(void))block {
    if (!block) return;
    __weak typeof(self) _self = self;
    dispatch_async(_queue, ^{
        __strong typeof(_self) self = _self;
        [self setObject:object forKey:key];
        block();
    });
}

- (void)removeObjectForKey:(NSString *)key {
    if (!key) return;
    
    LOCK();
    NSString *filePath = [self p_encodedFileURLForKey:key];
    if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
        [[NSFileManager defaultManager] removeItemAtPath:filePath error:NULL];
    }
    UNLOCK();
}

- (void)removeObjectForKey:(NSString *)key withBlock:(void (^)(NSString *))block {
    if (!block) return;
    __weak typeof(self) _self = self;
    dispatch_async(_queue, ^{
        __strong typeof(_self) self = _self;
        [self removeObjectForKey:key];
        block(key);
    });
}

- (void)removeAllObjects {
    LOCK();
    [self p_createCacheDirectory];
    UNLOCK();
}

- (void)removeAllObjectsWithBlock:(void (^)(void))block {
    if (!block) return;
    __weak typeof(self) _self = self;
    dispatch_async(_queue, ^{
        __strong typeof(_self) self = _self;
        [self removeAllObjects];
        block();
    });
}

#pragma mark - Private

- (NSString *)p_encodedFileURLForKey:(NSString *)key {
    if (key.length == 0) return nil;
    return [_path stringByAppendingPathComponent:key];
}

- (void)p_createCacheDirectory {
    if ([[NSFileManager defaultManager] fileExistsAtPath:_path]) return;
    [[NSFileManager defaultManager] createDirectoryAtPath:_path withIntermediateDirectories:YES attributes:nil error:NULL];
}

@end
