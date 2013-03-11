//
//  PhotoInfo.h
//  Core Data SPoT
//
//  Created by David Davis on 3/10/13.
//  Copyright (c) 2013 David Davis. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class PhotoTag;

@interface PhotoInfo : NSManagedObject

@property (nonatomic, retain) NSString * flickrTitle;
@property (nonatomic, retain) NSString * flickrImageURL;
@property (nonatomic, retain) NSString * flickrDescription;
@property (nonatomic, retain) NSString * flickrID;
@property (nonatomic, retain) NSData * flickrImageIcon;
@property (nonatomic, retain) NSString * sectionName;
@property (nonatomic, retain) NSDate * lastUsed;
@property (nonatomic, retain) NSDate * lastUpdated;
@property (nonatomic, retain) NSString * flickrImageIconURL;
@property (nonatomic, retain) NSSet *tags;
@end

@interface PhotoInfo (CoreDataGeneratedAccessors)

- (void)addTagsObject:(PhotoTag *)value;
- (void)removeTagsObject:(PhotoTag *)value;
- (void)addTags:(NSSet *)values;
- (void)removeTags:(NSSet *)values;

@end
