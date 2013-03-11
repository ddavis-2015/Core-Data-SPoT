//
//  CachedURL.h
//  SPoT
//
//  Created by David Davis on 3/1/13.
//  Copyright (c) 2013 David Davis. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface CachedURL : NSObject

@property (nonatomic) NSUInteger itemLimit;

+ (CachedURL*)sharedInstance;

- (NSURL*)URLForKey:(NSString*)key;
- (void)addData:(NSData*)content forKey:(NSString*)key;
- (void)removeAll;

@end
