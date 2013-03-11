//
//  PhotoTitleTVC.m
//  SPoT
//
//  Created by David Davis on 2/24/13.
//  Copyright (c) 2013 David Davis. All rights reserved.
//

#import "PhotoTitlesTVC.h"
#import "PhotoImageVC.h"
#import "SharedDocument.h"
#import "PhotoInfo.h"
#import "NetworkActivity.h"


@interface PhotoTitlesTVC ()

@end


@implementation PhotoTitlesTVC


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    PhotoImageVC* vc = (PhotoImageVC*)segue.destinationViewController;
    UITableViewCell* cell = (UITableViewCell*)sender;
    PhotoInfo* photoInfo = [self.fetchedResultsController objectAtIndexPath:[self.tableView indexPathForCell:cell]];

    vc.title = cell.textLabel.text;
    vc.cacheKey = photoInfo.flickrID;
    vc.imageUrl = [NSURL URLWithString:photoInfo.flickrImageURL];
    if (self.trackRecentlyViewed)
        photoInfo.lastUsed = [NSDate date];
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
    }];
}

- (void)viewDidLoad
{
    [super viewDidLoad];

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
    PhotoInfo* photoInfo = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
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
        NSURL* url = [NSURL URLWithString:photoInfo.flickrImageIconURL];
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^
        {
            [NetworkActivity startIndicator];

            NSData* data = [NSData dataWithContentsOfURL:url];

            [NetworkActivity stopIndicator];

            dispatch_async(dispatch_get_main_queue(), ^
            {
                photoInfo.flickrImageIcon = data;
                //[self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            });
        });
    }

    return cell;
}

@end
