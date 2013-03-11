//
//  PhotoInfo+Flickr.m
//  Core Data SPoT
//
//  Created by David Davis on 3/9/13.
//  Copyright (c) 2013 David Davis. All rights reserved.
//

#import "PhotoInfo+Flickr.h"
#import "FlickrFetcher.h"


@implementation PhotoInfo (Flickr)

+ (PhotoInfo*)addPhotoInfo:(NSDictionary*)flickr managedObjectContext:(NSManagedObjectContext*)context
{
    NSString* className = NSStringFromClass([self class]);
    NSFetchRequest* fetch = [NSFetchRequest fetchRequestWithEntityName:className];

    [fetch setPredicate:[NSPredicate predicateWithFormat:@"flickrID == %@", flickr[FLICKR_PHOTO_ID]]];
    
    NSArray* results = [context executeFetchRequest:fetch error:nil];
    
    assert(results);
    assert([results count] <= 1);
    
    PhotoInfo* photoInfo = [results lastObject];
    
    if (!photoInfo)
    {
        photoInfo = [NSEntityDescription insertNewObjectForEntityForName:className inManagedObjectContext:context];
        assert(photoInfo);
    }

    id value;

    value = [flickr valueForKeyPath:FLICKR_PHOTO_DESCRIPTION];
    if ([value isKindOfClass:[NSString class]])
        photoInfo.flickrDescription = value;
    
    value = flickr[FLICKR_PHOTO_ID];
    if ([value isKindOfClass:[NSString class]])
        photoInfo.flickrID = value;
    
    value = flickr[FLICKR_PHOTO_TITLE];
    if ([value isKindOfClass:[NSString class]])
        photoInfo.flickrTitle = value;

    if ([photoInfo.flickrTitle length])
        photoInfo.sectionName = [[photoInfo.flickrTitle substringToIndex:1] uppercaseStringWithLocale:[NSLocale currentLocale]];

    photoInfo.flickrImageURL = [[FlickrFetcher urlForPhoto:flickr format:FlickrPhotoFormatLarge] absoluteString];
    photoInfo.flickrImageIconURL = [[FlickrFetcher urlForPhoto:flickr format:FlickrPhotoFormatSquare] absoluteString];
    
    return photoInfo;
}

@end
