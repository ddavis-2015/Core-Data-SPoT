//
//  PhotoImageVC.h
//  SPoT
//
//  Created by David Davis on 2/24/13.
//  Copyright (c) 2013 David Davis. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface PhotoImageVC : UIViewController

@property (strong, nonatomic) NSURL* imageUrl;
@property (strong, nonatomic) NSString* cacheKey;

@end
