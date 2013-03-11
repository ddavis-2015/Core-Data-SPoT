//
//  CachedURL.m
//  SPoT
//
//  Created by David Davis on 3/1/13.
//  Copyright (c) 2013 David Davis. All rights reserved.
//

#import "CachedURL.h"


@interface CachedURL()

@property (strong, nonatomic) dispatch_queue_t queue;
@property (strong, nonatomic) NSURL* cacheURL;

@end


@implementation CachedURL

- (id)init
{
    self = nil;

    return self;
}

- (id)_init
{
    self = [super init];

    return self;
}

- (void)setItemLimit:(NSUInteger)itemLimit
{
    @synchronized(self)
    {
        NSUInteger oldLimit = _itemLimit;

        _itemLimit = itemLimit;
        if (oldLimit != itemLimit)
        {
            dispatch_async(self.queue, ^
            {
                [self trimCache:itemLimit];
            });
        }
    }
}

- (dispatch_queue_t)queue
{
    @synchronized(self)
    {
        if (!_queue)
        {
            _queue = dispatch_queue_create("CachedURL", DISPATCH_QUEUE_SERIAL);
            dispatch_set_target_queue(_queue, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0));
        }
    }

    return _queue;
}

- (NSURL *)cacheURL
{
    @synchronized(self)
    {
        if (!_cacheURL)
        {
            _cacheURL = [[NSFileManager defaultManager] URLForDirectory:NSCachesDirectory
                                                               inDomain:NSUserDomainMask
                                                      appropriateForURL:nil
                                                                 create:YES
                                                                  error:nil];
            _cacheURL = [_cacheURL URLByAppendingPathComponent:NSStringFromClass([self class]) isDirectory:YES];
            dispatch_async(self.queue, ^
            {
                (void)[[NSFileManager defaultManager] createDirectoryAtURL:_cacheURL
                                               withIntermediateDirectories:YES
                                                                attributes:nil
                                                                     error:nil];
            });
        }
    }

    return _cacheURL;
}

+ (CachedURL *)sharedInstance
{
    static CachedURL* sharedInstance;

    @synchronized(self)
    {
        if (!sharedInstance)
            sharedInstance = [[CachedURL alloc] _init];
    }

    return sharedInstance;
}

- (NSURL *)URLForKey:(NSString *)key
{
    if (!key)
        return nil;
    
    return [self.cacheURL URLByAppendingPathComponent:key];
}

-(void)addData:(NSData *)content forKey:(NSString *)key
{
    dispatch_async(self.queue, ^
    {
        NSURL* url = [self URLForKey:key];
        
        if (![[NSFileManager defaultManager] fileExistsAtPath:[url path]])
        {
            [content writeToURL:url atomically:YES];
            [self trimCache:self.itemLimit];
        }
    });
}

- (void)removeAll
{
    dispatch_async(self.queue, ^
    {
        NSArray* items = [self allCacheItemsWithAttributes:nil];

        for (NSURL* url in items)
             (void)[[NSFileManager defaultManager] removeItemAtURL:url error:nil];
    });
}

- (NSArray*)allCacheItemsWithAttributes:(NSArray*)attributes
{    
    return [[NSFileManager defaultManager] contentsOfDirectoryAtURL:self.cacheURL
                                         includingPropertiesForKeys:attributes
                                                            options:NSDirectoryEnumerationSkipsHiddenFiles
                                                              error:nil];
}

- (void)trimCache:(NSUInteger)itemLimit
{
    NSArray* items = [self allCacheItemsWithAttributes:@[NSURLContentAccessDateKey]];

    if ([items count] <= itemLimit)
        return;

    items = [items sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2)
    {
        NSURL* url1 = (NSURL*)obj1;
        NSURL* url2 = (NSURL*)obj2;
        NSDate* date1;
        NSDate* date2;

        (void)[url1 getResourceValue:&date1 forKey:NSURLContentAccessDateKey error:nil];
        (void)[url2 getResourceValue:&date2 forKey:NSURLContentAccessDateKey error:nil];

        return [date1 compare:date2];
    }];

    for (int i = 0; i < [items count] - itemLimit; i++)
    {
        (void)[[NSFileManager defaultManager] removeItemAtURL:items[i] error:nil];
    }
}

@end
