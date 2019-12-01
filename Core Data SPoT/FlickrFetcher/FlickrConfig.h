//
//  FlickrConfig.h
//  Core Data SPoT
//
//  Created by David Davis on 11/30/19.
//  Copyright © 2019 David Davis. All rights reserved.
//

#ifndef FlickrConfig_h
#define FlickrConfig_h

#import <Foundation/Foundation.h>


@interface FlickrConfig : NSObject

@property (nonatomic, strong, readonly) NSString* apiKey;

+ (FlickrConfig*)sharedInstance;

@end

#endif /* FlickrConfig_h */
