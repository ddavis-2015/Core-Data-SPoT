//
//  PhotoSplitVC.m
//  SPoT
//
//  Created by David Davis on 2/27/13.
//  Copyright (c) 2013 David Davis. All rights reserved.
//

#import "PhotoSplitVC.h"


@interface PhotoSplitVC () <UISplitViewControllerDelegate>

@property (strong, nonatomic) UIBarButtonItem* button;
@property (strong, nonatomic) UIPopoverController* popover;

@end


@implementation PhotoSplitVC

- (void)detailViewDidLoad
{
    if (UIInterfaceOrientationIsPortrait(self.interfaceOrientation) && self.button)
    {
        UIViewController* detail = self.viewControllers[1];
        
        detail.toolbarItems = [@[self.button] arrayByAddingObjectsFromArray:detail.toolbarItems];
    }

    [self.popover dismissPopoverAnimated:YES];
}

- (void)splitViewController:(UISplitViewController *)svc
     willHideViewController:(UIViewController *)aViewController
          withBarButtonItem:(UIBarButtonItem *)barButtonItem
       forPopoverController:(UIPopoverController *)pc
{
    UIViewController* detail = self.viewControllers[1];
    NSArray* items = [@[barButtonItem] arrayByAddingObjectsFromArray:detail.toolbarItems];

    barButtonItem.title = @"SPoT";
    detail.toolbarItems = items;
    self.popover = pc; // old-style popover requires the UIPopoverController not be owned by the UISplitView class
    self.button = barButtonItem;
}

- (void)splitViewController:(UISplitViewController *)svc
     willShowViewController:(UIViewController *)aViewController
  invalidatingBarButtonItem:(UIBarButtonItem *)barButtonItem
{
    UIViewController* detail = self.viewControllers[1];
    NSMutableArray* items = [detail.toolbarItems mutableCopy];

    [items removeObject:barButtonItem];
    detail.toolbarItems = items;
    self.popover = nil;
    self.button = nil;
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
    self.delegate = self;
    self.presentsWithGesture = NO;  // no left->right swipe to show master in portrait orientation
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
