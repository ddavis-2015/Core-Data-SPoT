//
//  SharedDocument.h
//  Core Data SPoT
//
//  Created by David Davis on 3/9/13.
//  Copyright (c) 2013 David Davis. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface SharedDocument : NSObject

@property (strong, atomic, readonly) NSManagedObjectContext* managedObjectContext;

+ (SharedDocument*)sharedInstance;

- (void)whenReadyPerformBlock:(void (^)(void))completion; // completion executed in main thread
- (void)update:(BOOL)clearDB completion:(void (^)(void))completion; // completion executed in main thread

@end
