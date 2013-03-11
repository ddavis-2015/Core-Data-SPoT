//
//  PhotoTitleTVC.h
//  SPoT
//
//  Created by David Davis on 2/24/13.
//  Copyright (c) 2013 David Davis. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CoreDataTableViewController.h"


@interface PhotoTitlesTVC : CoreDataTableViewController

@property (strong, nonatomic) NSFetchRequest* fetchRequest;
@property (nonatomic) BOOL trackRecentlyViewed;
@property (strong, nonatomic) NSString* sectionNameKeyPath;

@end
