//
//  FlickrConfig.m
//  Core Data SPoT
//
//  Created by David Davis on 12/1/19.
//  Copyright © 2019 David Davis. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FlickrConfig.h"

@implementation FlickrConfig

- (id)init
{
    self = nil;

    return self;
}

- (id)_init
{
    self = [super init];

    NSURL* url = [[NSBundle mainBundle] URLForResource:@"flickr_config" withExtension:@"json"];
    NSData* data = [NSData dataWithContentsOfURL:url];
    NSDictionary* json = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
    _apiKey = [json valueForKeyPath:@"keys.api_key"];

    return self;
}

+ (FlickrConfig *)sharedInstance
{
    static FlickrConfig* sharedInstance;

    @synchronized(self)
    {
        if (!sharedInstance)
            sharedInstance = [[FlickrConfig alloc] _init];
    }

    return sharedInstance;
}

@end
