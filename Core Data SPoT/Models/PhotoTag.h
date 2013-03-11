//
//  PhotoTag.h
//  Core Data SPoT
//
//  Created by David Davis on 3/10/13.
//  Copyright (c) 2013 David Davis. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class PhotoInfo;

@interface PhotoTag : NSManagedObject

@property (nonatomic, retain) NSString * flickrName;
@property (nonatomic, retain) NSString * sectionName;
@property (nonatomic, retain) NSSet *photos;
@end

@interface PhotoTag (CoreDataGeneratedAccessors)

- (void)addPhotosObject:(PhotoInfo *)value;
- (void)removePhotosObject:(PhotoInfo *)value;
- (void)addPhotos:(NSSet *)values;
- (void)removePhotos:(NSSet *)values;

@end
