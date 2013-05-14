//
//  TutorialViewController.m
//  iOSGGT
//
//  Created by Mihnea Barboi on 5/13/13.
//  Copyright (c) 2013 Mihnea Barboi. All rights reserved.
//

#import "TutorialViewController.h"
#import "QuartzCore/QuartzCore.h"

@interface TutorialViewController () {
    NSArray *imageArray;
}

@end

@implementation TutorialViewController

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
    imageArray = [[NSArray alloc] initWithObjects:@"tut_root", @"tut_landscape", @"tut_main", @"tut_account" ,@"tut_directory", nil];
    
    for (int i = 0; i < [imageArray count]; i++) {
        //We'll create an imageView object in every 'page' of our scrollView.
        CGRect frame;
        frame.origin.x = scrollView.frame.size.width * i;
        frame.origin.y = 0;
        frame.size = scrollView.frame.size;
        frame.size.height -= 100;
        
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:frame];
        
        if ([[imageArray objectAtIndex:i] isEqualToString:@"tut_landscape"]) 
            imageView.image = [self scaleAndRotateImage:[UIImage imageNamed:[imageArray objectAtIndex:i]]];
        else 
            imageView.image = [UIImage imageNamed:[imageArray objectAtIndex:i]];
        
        [scrollView addSubview:imageView];
    }
    
    //Set the content size of our scrollview according to the total width of our imageView objects.
    scrollView.contentSize = CGSizeMake(scrollView.frame.size.width * [imageArray count], scrollView.frame.size.height);
    
    labelDetails.text = @"Tap the blue bar to start selecting events to add to your calendar"; //first description
    
}

#pragma mark - UIScrollView Delegate
- (void)scrollViewDidScroll:(UIScrollView *)sender
{
    // Update the page when more than 50% of the previous/next page is visible
    CGFloat pageWidth = scrollView.frame.size.width;
    int page = floor((scrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
    pageControl.currentPage = page;
    NSString *labelText;
    switch (page) {
        case 0:
            labelText = @"Tap each entry to see grant details. Rotate to see graph.";
            break;
        case 1:
            labelText = @"Tap labels to hide graphs. Pinch to zoom. End date is dotted line.";
            break;
        case 2:
            labelText = @"Scroll through labels on left. Touch any pieslice to see account details";
            break;
        case 3:
            labelText = @"Tap each cell to see the provided description.";
            break;
        case 4:
            labelText = @"Set a nickname, add a new Excel directory, edit directories.";
            break;
            
        default:
            labelText = @"";
            break;
    }
    
    labelDetails.text = labelText;
}

- (UIImage *)scaleAndRotateImage:(UIImage *)image  {
    
    CGImageRef imgRef = image.CGImage;
    
    CGFloat width = CGImageGetWidth(imgRef);
    CGFloat height = CGImageGetHeight(imgRef);
    
    CGAffineTransform transform = CGAffineTransformIdentity;
    CGRect bounds = CGRectMake(0, 0, width, height);
    
    CGFloat boundHeight;
    
    boundHeight = bounds.size.height;
    bounds.size.height = bounds.size.width;
    bounds.size.width = boundHeight;
    transform = CGAffineTransformMakeScale(-1.0, 1.0);
    transform = CGAffineTransformRotate(transform, M_PI / 2.0); //use angle/360 *MPI
    
    UIGraphicsBeginImageContext(bounds.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextConcatCTM(context, transform);
    CGContextDrawImage(context, CGRectMake(0, 0, width, height), imgRef);
    UIImage *imageCopy = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return imageCopy;   
    
}

-(BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return NO;
}

- (BOOL)shouldAutorotate
{
    return NO;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)buttonDone:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}
@end
