//
//  PhotoInfo+Flickr.h
//  Core Data SPoT
//
//  Created by David Davis on 3/9/13.
//  Copyright (c) 2013 David Davis. All rights reserved.
//

#import "PhotoInfo.h"


@interface PhotoInfo (Flickr)

+ (PhotoInfo*)addPhotoInfo:(NSDictionary*)flickr managedObjectContext:(NSManagedObjectContext*)context;
+ (void)removeAllWithManagedObjectContext:(NSManagedObjectContext*)context;

@end
