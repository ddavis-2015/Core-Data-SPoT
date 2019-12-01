//
//  SharedDocument.m
//  Core Data SPoT
//
//  Created by David Davis on 3/9/13.
//  Copyright (c) 2013 David Davis. All rights reserved.
//

#import "SharedDocument.h"
#import "FlickrFetcher.h"
#import "PhotoInfo+Flickr.h"
#import "PhotoTag+Flickr.h"
#import "NetworkActivity.h"


@interface SharedDocument()

@property (strong, atomic) UIManagedDocument* document;
@property (atomic, readonly) BOOL isDocumentReady;
@property (strong, nonatomic) dispatch_queue_t queue;

@end


@implementation SharedDocument

- (NSManagedObjectContext *)managedObjectContext
{
    assert(self.isDocumentReady);
    assert(self.document.managedObjectContext);

    return self.document.managedObjectContext;
}

- (BOOL)isDocumentReady
{
    return (self.document && (self.document.documentState == UIDocumentStateNormal));
}

- (id)init
{
    self = nil;

    return self;
}

- (id)_init
{
    self = [super init];
    if (self)
    {
        _queue = dispatch_queue_create("SharedDocument", DISPATCH_QUEUE_SERIAL);
        assert(_queue);
        dispatch_suspend(_queue);
        dispatch_set_target_queue(_queue, dispatch_get_main_queue());
        
        NSURL* _databaseURL = [[NSFileManager defaultManager] URLForDirectory:NSDocumentDirectory
                                                                     inDomain:NSUserDomainMask
                                                            appropriateForURL:nil
                                                                       create:YES
                                                                        error:nil];
        _databaseURL = [_databaseURL URLByAppendingPathComponent:@"Core Data SPoT"];
        _document = [[UIManagedDocument alloc] initWithFileURL:_databaseURL];
        assert(_document);

        void (^completion)(BOOL) = ^(BOOL success)
        {
            assert(success);
            assert(self.isDocumentReady);
            dispatch_resume(self.queue);
        };

        if ([[NSFileManager defaultManager] fileExistsAtPath:[_databaseURL path]])
        {
            [_document openWithCompletionHandler:completion];
        }
        else
        {
            [_document saveToURL:_databaseURL forSaveOperation:UIDocumentSaveForCreating completionHandler:completion];
        }
    }

    return self;
}

+ (SharedDocument*)sharedInstance
{
    @synchronized(self)
    {
        static SharedDocument* instance;

        if (!instance)
            instance = [[SharedDocument alloc] _init];

        return instance;
    }
}

- (void)whenReadyPerformBlock:(void (^)(void))completion
{
    dispatch_async(self.queue, ^
    {
        completion();
    });
}

- (void)update:(BOOL)clearDB completion:(void (^)(void))completion
{
    [self whenReadyPerformBlock:^
    {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^
        {
            [NetworkActivity startIndicator];
            
            NSArray* photos = [FlickrFetcher stanfordPhotos];

            [NetworkActivity stopIndicator];

            NSManagedObjectContext* context = [self.managedObjectContext parentContext];

            [context performBlock:^
            {
                if (clearDB)
                {
                    [PhotoInfo removeAllWithManagedObjectContext:context];
                    [PhotoTag removeAllWithManagedObjectContext:context];
                }
                [self processFlickrData:photos managedObjectContext:context];
                assert([context save:nil]);
                dispatch_async(dispatch_get_main_queue(), ^
                {
                    completion();
                });
            }];
        });
    }];
}

- (void)processFlickrData:(NSArray*)photos managedObjectContext:(NSManagedObjectContext*)context
{
    NSDate* now = [NSDate date];

    PhotoTag* allTag = [PhotoTag addPhotoTagAllInManagedObjectContext:context];

    if (allTag.photos)
        [allTag removePhotos:allTag.photos];
    
    for (NSDictionary* photo in photos)
    {
        PhotoInfo* photoInfo = [PhotoInfo addPhotoInfo:photo managedObjectContext:context];
        NSSet* photoTags = [PhotoTag addPhotoTags:photo managedObjectContext:context];

        if (photoInfo.tags)
            [photoInfo removeTags:photoInfo.tags];
        if (photoTags)
            [photoInfo addTags:photoTags];
        photoInfo.lastUpdated = now;

        [allTag addPhotosObject:photoInfo];
    }
}

@end
