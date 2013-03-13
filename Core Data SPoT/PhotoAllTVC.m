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


@interface PhotoAllTVC ()

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

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.

    NSPredicate* predicate = [NSPredicate predicateWithFormat:@"flickrName != 'All'"];

    [self.fetchRequest setPredicate:[NSCompoundPredicate andPredicateWithSubpredicates:@[self.fetchRequest.predicate, predicate]]];
    self.sectionNameKeyPath = @"flickrName";
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    PhotoTag* photoTag = self.fetchedResultsController.fetchedObjects[indexPath.section];
    NSSortDescriptor* sortTitle = [NSSortDescriptor sortDescriptorWithKey:@"flickrTitle"
                                                                ascending:YES
                                                                 selector:@selector(localizedCaseInsensitiveCompare:)];
    NSSortDescriptor* sortDescription = [NSSortDescriptor sortDescriptorWithKey:@"flickrDescription"
                                                                      ascending:YES
                                                                       selector:@selector(localizedCaseInsensitiveCompare:)];
    PhotoInfo* photoInfo = [[photoTag.photos allObjects] sortedArrayUsingDescriptors:@[sortTitle, sortDescription]][indexPath.row];
    
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

    return [photoTag.photos count];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    PhotoImageVC* vc = (PhotoImageVC*)segue.destinationViewController;
    UITableViewCell* cell = (UITableViewCell*)sender;
    NSIndexPath* indexPath = [self.tableView indexPathForCell:cell];
    PhotoTag* photoTag = self.fetchedResultsController.fetchedObjects[indexPath.section];
    NSSortDescriptor* sortTitle = [NSSortDescriptor sortDescriptorWithKey:@"flickrTitle"
                                                                ascending:YES
                                                                 selector:@selector(localizedCaseInsensitiveCompare:)];
    NSSortDescriptor* sortDescription = [NSSortDescriptor sortDescriptorWithKey:@"flickrDescription"
                                                                      ascending:YES
                                                                       selector:@selector(localizedCaseInsensitiveCompare:)];
    PhotoInfo* photoInfo = [[photoTag.photos allObjects] sortedArrayUsingDescriptors:@[sortTitle, sortDescription]][indexPath.row];
    
    vc.title = cell.textLabel.text;
    vc.cacheKey = photoInfo.flickrID;
    vc.imageUrl = [NSURL URLWithString:photoInfo.flickrImageURL];
    photoInfo.lastUsed = [NSDate date];
    assert([[SharedDocument sharedInstance].managedObjectContext save:nil]);
}

@end
