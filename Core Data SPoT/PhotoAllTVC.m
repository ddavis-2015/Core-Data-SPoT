//
//  PhotoAllTVC.m
//  Core Data SPoT
//
//  Created by David Davis on 3/12/13.
//  Copyright (c) 2013 David Davis. All rights reserved.
//

#import "PhotoAllTVC.h"
#import "PhotoTag.h"
#import "PhotoInfo.h"
#import "PhotoImageVC.h"
#import "NetworkActivity.h"
#import "SharedDocument.h"


@interface PhotoAllTVC () <UISearchBarDelegate>

@property (strong, nonatomic) NSFetchRequest* fetchRequest;
@property (strong, nonatomic) IBOutlet UISearchBar *searchBar;
@property (strong, nonatomic) IBOutlet UITapGestureRecognizer *deactivateSearchTap;
@property (strong, nonatomic) NSPredicate* predicate;
@property (strong, nonatomic) NSPredicate* tagFilter;
@property (strong, nonatomic) NSPredicate* photoFilter;

@end


@implementation PhotoAllTVC

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)reloadFetchedResultsController
{
    if (self.tagFilter)
    {
        [self.fetchRequest setPredicate:[NSCompoundPredicate andPredicateWithSubpredicates:@[self.predicate, self.tagFilter]]];
    }
    else
    {
        [self.fetchRequest setPredicate:self.predicate];
    }

    [[SharedDocument sharedInstance] whenReadyPerformBlock:^
    {
        self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:self.fetchRequest
                                                                            managedObjectContext:[[SharedDocument sharedInstance] managedObjectContext]
                                                                              sectionNameKeyPath:@"flickrName"
                                                                                       cacheName:nil];
        assert(self.fetchedResultsController.fetchedObjects);
    }];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    [self reloadFetchedResultsController];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.

    NSFetchRequest* fetch = [NSFetchRequest fetchRequestWithEntityName:@"PhotoTag"];
    NSSortDescriptor* sortName = [NSSortDescriptor sortDescriptorWithKey:@"flickrName"
                                                               ascending:YES
                                                                selector:@selector(localizedCaseInsensitiveCompare:)];
    self.predicate = [NSPredicate predicateWithFormat:@"!(flickrName in %@)", @[@"Cs193Pspot", @"Portrait", @"Landscape", @"All"]];

    [fetch setSortDescriptors:@[sortName]];

    self.fetchRequest = fetch;
    self.tableView.sectionIndexMinimumDisplayRowCount = NSIntegerMax;
    self.tableView.tableHeaderView = nil;
    self.deactivateSearchTap.enabled = NO;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSArray*)allPhotosForTag:(PhotoTag*)photoTag
{
    NSFetchRequest* fetch = [NSFetchRequest fetchRequestWithEntityName:@"PhotoInfo"];
    NSSortDescriptor* sortTitle = [NSSortDescriptor sortDescriptorWithKey:@"flickrTitle"
                                                                ascending:YES
                                                                 selector:@selector(localizedCaseInsensitiveCompare:)];
    NSSortDescriptor* sortDescription = [NSSortDescriptor sortDescriptorWithKey:@"flickrDescription"
                                                                      ascending:YES
                                                                       selector:@selector(localizedCaseInsensitiveCompare:)];
    NSPredicate* predicate = [NSPredicate predicateWithFormat:@"SELF in %@", photoTag.photos];

    if (self.photoFilter)
    {
        [fetch setPredicate:[NSCompoundPredicate andPredicateWithSubpredicates:@[predicate, self.photoFilter]]];
    }
    else
    {
        [fetch setPredicate:predicate];
    }
    [fetch setSortDescriptors:@[sortTitle, sortDescription]];

    NSArray* photos = [[SharedDocument sharedInstance].managedObjectContext executeFetchRequest:fetch error:nil];

    assert(photos);

    return photos;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    PhotoTag* photoTag = self.fetchedResultsController.fetchedObjects[indexPath.section];
    PhotoInfo* photoInfo = [self allPhotosForTag:photoTag][indexPath.row];
    
    // Configure the cell...
    cell.textLabel.text = [photoInfo.flickrTitle capitalizedStringWithLocale:[NSLocale currentLocale]];
    cell.detailTextLabel.text = [photoInfo.flickrDescription capitalizedStringWithLocale:[NSLocale currentLocale]];

    UIImage* image = [UIImage imageWithData:photoInfo.flickrImageIcon];

    if (image)
    {
        cell.imageView.image = image;
    }
    else
    {
        cell.imageView.image = nil;

        NSURL* url = [NSURL URLWithString:photoInfo.flickrImageIconURL];

        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^
        {
            [NetworkActivity startIndicator];

            NSData* data = [NSData dataWithContentsOfURL:url];

            [NetworkActivity stopIndicator];

            dispatch_async(dispatch_get_main_queue(), ^
            {
                photoInfo.flickrImageIcon = data;
            });
        });
    }

    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    PhotoTag* photoTag = self.fetchedResultsController.fetchedObjects[section];

    return [[self allPhotosForTag:photoTag] count];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    PhotoImageVC* vc = (PhotoImageVC*)segue.destinationViewController;
    UITableViewCell* cell = (UITableViewCell*)sender;
    NSIndexPath* indexPath = [self.tableView indexPathForCell:cell];
    PhotoTag* photoTag = self.fetchedResultsController.fetchedObjects[indexPath.section];
    PhotoInfo* photoInfo = [self allPhotosForTag:photoTag][indexPath.row];
    
    vc.title = cell.textLabel.text;
    vc.cacheKey = photoInfo.flickrID;
    vc.imageUrl = [NSURL URLWithString:photoInfo.flickrImageURL];
    photoInfo.lastUsed = [NSDate date];
    assert([[SharedDocument sharedInstance].managedObjectContext save:nil]);

    // this is for very long tap in the tableview while search active
    if ([self.navigationController navigationBar].hidden)
        [self deactivateSearch:nil];
}

- (void)updateFilters:(NSString*)text
{
    if (!text || ![text length])
    {
        self.tagFilter = nil;
        self.photoFilter = nil;
    }
    else
    {
        self.tagFilter = [NSPredicate predicateWithFormat:
                          @"photos.flickrTitle contains[c] %@ || photos.flickrDescription contains[c] %@"
                          @" || flickrName contains[c] %@",
                          text, text, text];
        self.photoFilter = [NSPredicate predicateWithFormat:@"flickrTitle contains[c] %@ || flickrDescription contains[c] %@", text, text];
    }

    [self reloadFetchedResultsController];
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    [self updateFilters:searchText];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    [self deactivateSearch:searchBar];
}

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar
{
    [self searchBar:searchBar textDidChange:searchBar.text];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [self deactivateSearch:searchBar];
}

- (IBAction)activateSearch:(id)sender
{
    (void)[self.searchBar becomeFirstResponder];
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    self.tableView.tableHeaderView = self.searchBar;
    self.deactivateSearchTap.enabled = YES;
    [self.tableView scrollRectToVisible:self.searchBar.frame animated:NO];
}

- (IBAction)deactivateSearch:(id)sender
{
    (void)[self.searchBar resignFirstResponder];
    [self.navigationController setNavigationBarHidden:NO animated:(sender ? YES : NO)];
    self.tableView.tableHeaderView = nil;
    self.deactivateSearchTap.enabled = NO;
}

@end
