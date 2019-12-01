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
#import "CachedURL.h"


@interface PhotoTagsTVC ()

@end


@implementation PhotoTagsTVC

- (void)reloadPhotos
{
    [self reloadPhotosShouldClearDB:YES];
}

- (void)reloadPhotosShouldClearDB:(BOOL)clearDB
{
    [self.refreshControl beginRefreshing];
    if (clearDB)
        [[CachedURL sharedInstance] removeAll];
    [[SharedDocument sharedInstance] update:clearDB completion:^
    {
        [self performFetch];
        [self.refreshControl endRefreshing];
    }];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    UITableViewCell* cell = (UITableViewCell*)sender;

    if (![cell.reuseIdentifier isEqualToString:@"Cell"])
    {
        [segue.destinationViewController setTitle:cell.textLabel.text];
        return;
    }

    PhotoTitlesTVC* vc = (PhotoTitlesTVC*)segue.destinationViewController;
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
        self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:self.fetchRequest
                                                                            managedObjectContext:[[SharedDocument sharedInstance] managedObjectContext]
                                                                              sectionNameKeyPath:self.sectionNameKeyPath
                                                                                       cacheName:nil];
        assert(self.fetchedResultsController.fetchedObjects);
        if (![self.fetchedResultsController.fetchedObjects count])
            [self reloadPhotosShouldClearDB:NO];
    }];
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    NSFetchRequest* fetch = [NSFetchRequest fetchRequestWithEntityName:@"PhotoTag"];
    NSSortDescriptor* sortName = [NSSortDescriptor sortDescriptorWithKey:@"flickrName"
                                                               ascending:YES
                                                                selector:@selector(localizedCaseInsensitiveCompare:)];
    NSPredicate* predicate = [NSPredicate predicateWithFormat:@"!(flickrName in %@)", @[@"Cs193Pspot", @"Portrait", @"Landscape"]];

    [fetch setPredicate:predicate];
    [fetch setSortDescriptors:@[sortName]];

    self.fetchRequest = fetch;
    self.sectionNameKeyPath = @"sectionName";
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
    static NSString *CellIdentifier;
    PhotoTag* photoTag = [self.fetchedResultsController objectAtIndexPath:indexPath];
    NSUInteger count;

    if (indexPath.section == 0 && indexPath.row == 0)
    {
        CellIdentifier = @"All";

        NSFetchRequest* fetch = [NSFetchRequest fetchRequestWithEntityName:@"PhotoInfo"];
        NSPredicate* predicate = [NSPredicate predicateWithFormat:@"!(any tags.flickrName in %@)", @[@"Cs193Pspot", @"Portrait", @"Landscape", @"All"]];

        [fetch setPredicate:predicate];
        count = [[SharedDocument sharedInstance].managedObjectContext countForFetchRequest:fetch error:nil];
        assert(count != NSNotFound);
    }
    else
    {
        CellIdentifier = @"Cell";
        count = [photoTag.photos count];
    }
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    // Configure the cell...
    cell.textLabel.text = photoTag.flickrName;
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%lu photo%@", count, count > 1 ? @"s" : @""];
    
    return cell;
}

@end
