//
//  HWCache.h
//  HWCoreFramework
//
//  Created by 58 on 6/23/16.
//  Copyright © 2016 ParallelWorld. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HWMemoryCache.h"
#import "HWDiskCache.h"


NS_ASSUME_NONNULL_BEGIN

@interface HWCache : NSObject
@property (strong, readonly) HWMemoryCache *memoryCache;
@property (strong, readonly) HWDiskCache *diskCache;
@property (copy, readonly) NSString *name;

- (nullable instancetype)initWithName:(NSString *)name;

- (nullable instancetype)initWithPath:(NSString *)path NS_DESIGNATED_INITIALIZER;
- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;

+ (nullable instancetype)cacheWithName:(NSString *)name;
+ (nullable instancetype)cacheWithPath:(NSString *)path;

#pragma mark - Access methods

- (nullable id<NSCoding>)objectForKey:(NSString *)key;
- (void)objectForKey:(NSString *)key withBlock:(void(^)(NSString *key, id<NSCoding> object))block;

- (void)setObject:(nullable id<NSCoding>)object forKey:(NSString *)key;
- (void)setObject:(nullable id<NSCoding>)object forKey:(NSString *)key withBlock:(void(^)(void))block;

- (void)removeObjectForKey:(NSString *)key;
- (void)removeObjectForKey:(NSString *)key withBlock:(void(^)(NSString *key))block;

- (void)removeAllObjects;
- (void)removeAllObjectsWithBlock:(void(^)(void))block;

@end

NS_ASSUME_NONNULL_END
