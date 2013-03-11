//
//  PhotoTagTVCViewController.m
//  SPoT
//
//  Created by David Davis on 2/24/13.
//  Copyright (c) 2013 David Davis. All rights reserved.
//

#import "PhotoTagsTVC.h"
#import "PhotoTitlesTVC.h"
#import "SharedDocument.h"
#import "PhotoTag.h"


@interface PhotoTagsTVC ()

@end


@implementation PhotoTagsTVC

- (void)reloadPhotos
{
    [self.refreshControl beginRefreshing];
    [[SharedDocument sharedInstance] update:^
    {
        [self.refreshControl endRefreshing];
    }];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    PhotoTitlesTVC* vc = (PhotoTitlesTVC*)segue.destinationViewController;
    UITableViewCell* cell = (UITableViewCell*)sender;
    PhotoTag* photoTag = [self.fetchedResultsController objectAtIndexPath:[self.tableView indexPathForCell:cell]];
    NSFetchRequest* fetch = [NSFetchRequest fetchRequestWithEntityName:@"PhotoInfo"];
    NSSortDescriptor* sortTitle = [NSSortDescriptor sortDescriptorWithKey:@"flickrTitle"
                                                                ascending:YES
                                                                 selector:@selector(localizedCaseInsensitiveCompare:)];
    NSSortDescriptor* sortDescription = [NSSortDescriptor sortDescriptorWithKey:@"flickrDescription"
                                                                      ascending:YES
                                                                       selector:@selector(localizedCaseInsensitiveCompare:)];
    NSPredicate* predicate = [NSPredicate predicateWithFormat:@"SELF in %@", photoTag.photos];

    [fetch setPredicate:predicate];
    [fetch setSortDescriptors:@[sortTitle, sortDescription]];

    vc.title = cell.textLabel.text;
    vc.fetchRequest = fetch;
    vc.trackRecentlyViewed = YES;
    vc.sectionNameKeyPath = @"sectionName";
}

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    [[SharedDocument sharedInstance] whenReadyPerformBlock:^
    {
        NSFetchRequest* fetch = [NSFetchRequest fetchRequestWithEntityName:@"PhotoTag"];
        NSSortDescriptor* sortName = [NSSortDescriptor sortDescriptorWithKey:@"flickrName"
                                                                   ascending:YES
                                                                    selector:@selector(localizedCaseInsensitiveCompare:)];
        NSPredicate* predicate = [NSPredicate predicateWithFormat:@"!(flickrName in %@)", @[@"cs193pspot", @"portrait", @"landscape"]];

        [fetch setPredicate:predicate];
        [fetch setSortDescriptors:@[sortName]];
        self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetch
                                                                            managedObjectContext:[[SharedDocument sharedInstance] managedObjectContext]
                                                                              sectionNameKeyPath:@"sectionName"
                                                                                       cacheName:nil];
        assert(self.fetchedResultsController.fetchedObjects);
        if (![self.fetchedResultsController.fetchedObjects count])
            [self reloadPhotos];
    }];
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    [self.refreshControl addTarget:self action:@selector(reloadPhotos) forControlEvents:UIControlEventValueChanged];
    self.tableView.sectionIndexMinimumDisplayRowCount = NSIntegerMax;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    PhotoTag* photoTag = [self.fetchedResultsController objectAtIndexPath:indexPath];
    NSUInteger count = [photoTag.photos count];
    
    // Configure the cell...
    cell.textLabel.text = [photoTag.flickrName capitalizedStringWithLocale:[NSLocale currentLocale]];
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%u photo%@", count, count > 1 ? @"s" : @""];
    
    return cell;
}

@end
