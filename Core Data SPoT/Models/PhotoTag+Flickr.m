//
//  PhotoTag+Flickr.m
//  Core Data SPoT
//
//  Created by David Davis on 3/9/13.
//  Copyright (c) 2013 David Davis. All rights reserved.
//

#import "PhotoTag+Flickr.h"
#import "FlickrFetcher.h"


@implementation PhotoTag (Flickr)

+ (NSSet*)addPhotoTags:(NSDictionary*)flickr managedObjectContext:(NSManagedObjectContext*)context
{
    if (![flickr[FLICKR_TAGS] isKindOfClass:[NSString class]])
        return nil;

    NSArray* tags = [flickr[FLICKR_TAGS] componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];

    if (![tags count])
        return nil;

    NSString* className = NSStringFromClass([self class]);
    NSFetchRequest* fetch = [NSFetchRequest fetchRequestWithEntityName:className];
    NSMutableSet* photoTags = [[NSMutableSet alloc] init];

    for (NSString* tag in tags)
    {
        [fetch setPredicate:[NSPredicate predicateWithFormat:@"flickrName == %@", tag]];

        NSArray* results = [context executeFetchRequest:fetch error:nil];

        assert(results);
        assert([results count] <= 1);

        PhotoTag* photoTag = [results lastObject];

        if (!photoTag)
        {
            photoTag = [NSEntityDescription insertNewObjectForEntityForName:className inManagedObjectContext:context];
            assert(photoTag);
        }

        photoTag.flickrName = tag;
        photoTag.sectionName = [[tag substringToIndex:1] uppercaseStringWithLocale:[NSLocale currentLocale]];
        [photoTags addObject:photoTag];
    }

    return photoTags;
}

@end
