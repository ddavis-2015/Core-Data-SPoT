//
//  PhotoTag+Flickr.h
//  Core Data SPoT
//
//  Created by David Davis on 3/9/13.
//  Copyright (c) 2013 David Davis. All rights reserved.
//

#import "PhotoTag.h"


@interface PhotoTag (Flickr)

+ (NSSet*)addPhotoTags:(NSDictionary*)flickr managedObjectContext:(NSManagedObjectContext*)context; // PhotoTag*

@end
