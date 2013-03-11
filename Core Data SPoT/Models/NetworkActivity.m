//
//  NetworkActivity.m
//  SPoT
//
//  Created by David Davis on 2/28/13.
//  Copyright (c) 2013 David Davis. All rights reserved.
//

#import "NetworkActivity.h"


@implementation NetworkActivity

static BOOL indicatorCount;


+ (void)startIndicator
{
    @synchronized(self)
    {
        indicatorCount++;
        [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    }
}

+ (void)stopIndicator
{
    @synchronized(self)
    {
        if (--indicatorCount == 0)
            [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    }
}

@end
