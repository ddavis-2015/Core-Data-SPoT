//
//  PhotoImageVC.m
//  SPoT
//
//  Created by David Davis on 2/24/13.
//  Copyright (c) 2013 David Davis. All rights reserved.
//

#import "PhotoImageVC.h"
#import "PhotoSplitVC.h"
#import "NetworkActivity.h"
#import "CachedURL.h"


@interface PhotoImageVC () <UIScrollViewDelegate>

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *barButtonTitle;
@property (weak, nonatomic) IBOutlet UIToolbar *toolbar;
@property (weak, nonatomic) IBOutlet UILabel *backgroundLabel;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;

@property (nonatomic) BOOL zooming;

@end


@implementation PhotoImageVC

- (void)resetZoom
{
    float imageWidth = self.imageView.image.size.width;
    float imageHeight = self.imageView.image.size.height;
    float scrollWidth = self.scrollView.bounds.size.width;
    float scrollHeight = self.scrollView.bounds.size.height;
    float scale = 1 + MAX((scrollWidth / imageWidth) - 1, (scrollHeight / imageHeight) - 1);

    self.scrollView.zoomScale = scale;
}

- (IBAction)cancelZoom:(UITapGestureRecognizer *)sender
{
    [self resetZoom];
}

- (void)reloadImage
{
    if (!self.scrollView || !self.imageView)
        return;

    self.backgroundLabel.hidden = YES;
    [self.activityIndicator startAnimating];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^
    {
        NSData* data = [NSData dataWithContentsOfURL:[[CachedURL sharedInstance] URLForKey:self.cacheKey]];

        if (!data)
        {
            [NetworkActivity startIndicator];
            data = [NSData dataWithContentsOfURL:self.imageUrl];
            [NetworkActivity stopIndicator];
            if (data)
            {
                [CachedURL sharedInstance].itemLimit = 5;
                [[CachedURL sharedInstance] addData:data forKey:self.cacheKey];
            }
        }

        dispatch_async(dispatch_get_main_queue(), ^
        {
            UIImage* image = [UIImage imageWithData:data];

            if (image)
            {
                self.scrollView.zoomScale = 1.0;
                self.scrollView.contentSize = image.size;
                self.imageView.image = image;
                self.imageView.frame = CGRectMake(0, 0, image.size.width, image.size.height);
                [self resetZoom];
            }
            else
            {
                self.backgroundLabel.hidden = NO;
            }
            
            [self.activityIndicator stopAnimating];
        });
    });
}

- (NSArray *)toolbarItems
{
    return self.toolbar.items;
}

- (void)setToolbarItems:(NSArray *)toolbarItems
{
    self.toolbar.items = toolbarItems;
}

- (void)setTitle:(NSString *)title
{
    super.title = title;
    self.barButtonTitle.title = title;
}

- (void)setImageUrl:(NSURL *)imageUrl
{
    _imageUrl = imageUrl;
    [self reloadImage];
}

- (void)scrollViewWillBeginZooming:(UIScrollView *)scrollView withView:(UIView *)view
{
    self.zooming = YES;
}

- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(float)scale
{
    self.zooming = NO;
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return self.imageView;
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];

    if (!self.zooming)
        [self resetZoom];
    [self.view layoutSubviews];
}

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

    //
    // In order to keep the constraints, the UIImageView must be created programatically
    // (and thus has no constraints dependancies vis-a-vis other views).
    //
    [self.imageView removeConstraints:[self.imageView constraints]];
    [self.scrollView removeConstraints:[self.scrollView constraints]];
    [self.activityIndicator removeConstraints:[self.activityIndicator constraints]];
    [self.backgroundLabel removeConstraints:[self.backgroundLabel constraints]];
    [self.toolbar removeConstraints:[self.toolbar constraints]];

    self.scrollView.delegate = self;
    self.title = self.title;
    [self reloadImage];
    [(PhotoSplitVC*)self.splitViewController detailViewDidLoad];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
