//
//  PhotoRecentsTVC.m
//  SPoT
//
//  Created by David Davis on 2/24/13.
//  Copyright (c) 2013 David Davis. All rights reserved.
//

#import "PhotoRecentsTVC.h"
#import "PhotoInfo.h"
#import "SharedDocument.h"


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
    self.sectionNameKeyPath = nil;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle != UITableViewCellEditingStyleDelete)
        return;

    PhotoInfo* photoInfo = [self.fetchedResultsController objectAtIndexPath:indexPath];

    photoInfo.lastUsed = nil;
    assert([[SharedDocument sharedInstance].managedObjectContext save:nil]);
}

@end
