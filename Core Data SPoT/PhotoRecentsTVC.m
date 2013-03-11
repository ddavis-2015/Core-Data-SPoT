//
//  PhotoRecentsTVC.m
//  SPoT
//
//  Created by David Davis on 2/24/13.
//  Copyright (c) 2013 David Davis. All rights reserved.
//

#import "PhotoRecentsTVC.h"
#import "PhotoInfo.h"


@interface PhotoRecentsTVC ()

@end


@implementation PhotoRecentsTVC

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];    
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    NSFetchRequest* fetch = [NSFetchRequest fetchRequestWithEntityName:@"PhotoInfo"];
    NSSortDescriptor* sortDate = [NSSortDescriptor sortDescriptorWithKey:@"lastUsed"
                                                               ascending:NO
                                                                selector:@selector(compare:)];
    NSPredicate* predicate = [NSPredicate predicateWithFormat:@"lastUsed != nil"];

    [fetch setPredicate:predicate];
    [fetch setSortDescriptors:@[sortDate]];
    [fetch setFetchLimit:20];

    self.fetchRequest = fetch;
    self.trackRecentlyViewed = NO;
    self.sectionNameKeyPath = nil;
}

@end
